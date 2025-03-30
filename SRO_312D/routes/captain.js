const express = require('express');
const router = express.Router();
const Company = require('../models/Company');

// Middleware to check if captain is authenticated
const isCaptainAuthenticated = (req, res, next) => {
    if (req.session.captainAuthenticated) {
        return next();
    }
    res.redirect('/captain/login');
};

// Captain login page
router.get('/login', (req, res) => {
    res.render('captain/login', { error: null });
});

// Process captain login
router.post('/login', async (req, res) => {
    try {
        const { shipId, pin } = req.body;
        
        console.log('Captain login attempt:', { shipId, pin });
        
        // Find company that has this boat
        const company = await Company.findOne({ 
            "Boat_Coordinates.id": shipId,
            "Boat_Coordinates.pin": pin 
        });
        
        if (!company) {
            return res.render('captain/login', { error: 'Invalid Ship ID or PIN. Please try again.' });
        }
        
        // Find the specific boat
        const boat = company.Boat_Coordinates.find(b => b.id === shipId && b.pin === pin);
        
        if (!boat) {
            return res.render('captain/login', { error: 'Ship data not found.' });
        }
        
        // Set authenticated session for captain
        req.session.captainAuthenticated = true;
        req.session.shipId = shipId;
        req.session.companyId = company.companyId;
        req.session.shipName = boat.name;
        
        res.redirect('/captain/dashboard');
    } catch (error) {
        console.error('Captain login error:', error);
        res.render('captain/login', { error: 'An error occurred. Please try again.' });
    }
});

// Captain dashboard (protected route)
router.get('/dashboard', isCaptainAuthenticated, async (req, res) => {
    try {
        const companyId = req.session.companyId;
        const shipId = req.session.shipId;
        
        // Get the company and boat data
        const company = await Company.findOne({ companyId });
        
        if (!company) {
            req.session.destroy();
            return res.redirect('/captain/login');
        }
        
        // Get the specific boat
        const boat = company.Boat_Coordinates.find(b => b.id === shipId);
        
        if (!boat) {
            req.session.destroy();
            return res.redirect('/captain/login');
        }
        
        res.render('captain/dashboard', {
            shipName: boat.name,
            shipId: boat.id,
            shipData: boat,
            companyName: company.companyName
        });
    } catch (error) {
        console.error('Error fetching captain dashboard data:', error);
        res.status(500).render('error', { message: 'Internal Server Error' });
    }
});

// Update boat location and destination
router.post('/update-location', isCaptainAuthenticated, async (req, res) => {
    try {
        const companyId = req.session.companyId;
        const shipId = req.session.shipId;
        const { latitude, longitude, destinationPort, status } = req.body;
        
        console.log('Captain update location:', { shipId, latitude, longitude, destinationPort, status });
        
        // Update the boat data
        const company = await Company.findOne({ companyId });
        
        if (!company) {
            return res.status(404).json({ success: false, message: 'Company not found' });
        }
        
        // Find the boat index
        const boatIndex = company.Boat_Coordinates.findIndex(b => b.id === shipId);
        
        if (boatIndex === -1) {
            return res.status(404).json({ success: false, message: 'Ship not found' });
        }
        
        // Update the boat data
        if (latitude) company.Boat_Coordinates[boatIndex].latitude = parseFloat(latitude);
        if (longitude) company.Boat_Coordinates[boatIndex].longitude = parseFloat(longitude);
        if (destinationPort) company.Boat_Coordinates[boatIndex].portName = destinationPort;
        if (status) company.Boat_Coordinates[boatIndex].status = status;
        
        // Update lastUpdated
        company.Boat_Coordinates[boatIndex].lastUpdated = new Date();
        
        await company.save();
        
        return res.redirect('/captain/dashboard');
    } catch (error) {
        console.error('Error updating ship location:', error);
        res.status(500).render('error', { message: 'Internal Server Error' });
    }
});

// Captain logout
router.get('/logout', (req, res) => {
    req.session.destroy();
    res.redirect('/captain/login');
});

module.exports = router; 