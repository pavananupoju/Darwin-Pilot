import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/boat.dart';
import '../widgets/ship_details_card.dart';
import '../widgets/weather_legend.dart';
import 'ships_screen.dart';
import 'statistics_screen.dart';

// Global key to access the dashboard state from anywhere
final GlobalKey<DashboardScreenState> dashboardKey = GlobalKey<DashboardScreenState>();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  // Boat data
  List<Boat> boats = Boat.sampleBoats;
  Set<Marker> _markers = {};
  
  // Map controller
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  
  // Map view states
  bool _showMap = true;
  MapType _currentMapType = MapType.normal;
  bool _showWeatherOverlay = false;
  bool _showSatelliteView = false;
  Set<Polyline> _polylines = {};
  
  // Search and filter
  String _searchQuery = '';
  Set<String> _selectedTypes = {};
  bool _showSearchPanel = false;
  Boat? _selectedBoat;
  
  // Distance measurement
  bool _isMeasuringDistance = false;
  LatLng? _distanceStart;
  LatLng? _distanceEnd;
  
  // Map position
  static const LatLng _center = LatLng(-20.0, 80.0);
  final CameraPosition _initialPosition = const CameraPosition(
    target: _center,
    zoom: 5,
  );

  int _selectedIndex = 0;

  void showBoatOnMap(Boat boat) {
    setState(() {
      _selectedIndex = 0; // Switch to map view
      _selectedBoat = boat;
    });
    
    // Wait for the map to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusOnBoat(boat);
    });
  }

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  void _updateMarkers() {
    setState(() {
      _markers = boats.map((boat) => _createMarker(boat)).toSet();
    });
  }

  Marker _createMarker(Boat boat) {
    return Marker(
      markerId: MarkerId(boat.id),
      position: LatLng(boat.latitude, boat.longitude),
      infoWindow: InfoWindow(
        title: boat.name,
        snippet: '${boat.code} - ${boat.status}',
      ),
      onTap: () => _handleMarkerTap(boat),
    );
  }

  void _handleMarkerTap(Boat boat) {
    setState(() {
      _selectedBoat = boat;
    });
    showModalBottomSheet(
      context: context,
      builder: (context) => ShipDetailsCard(boat: boat),
    );
  }

  void _toggleSearchPanel() {
    setState(() {
      _showSearchPanel = !_showSearchPanel;
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _updateFilteredMarkers();
    });
  }

  void _toggleTypeFilter(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _updateFilteredMarkers();
    });
  }

  void _updateFilteredMarkers() {
    setState(() {
      _markers = boats.where((boat) {
        final matchesSearch = boat.name.toLowerCase().contains(_searchQuery) ||
            boat.code.toLowerCase().contains(_searchQuery) ||
            (boat.portName?.toLowerCase() ?? '').contains(_searchQuery);

        final matchesType = _selectedTypes.isEmpty ||
            _selectedTypes.contains(boat.boatType?.toLowerCase() ?? 'unknown');

        return matchesSearch && matchesType;
      }).map((boat) => _createMarker(boat)).toSet();
    });
  }

  double _calculateHaversineDistance(LatLng start, LatLng end) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((end.latitude - start.latitude) * p)/2 + 
            c(start.latitude * p) * c(end.latitude * p) * 
            (1 - c((end.longitude - start.longitude) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  void _handleMapTap(LatLng position) {
    if (_isMeasuringDistance) {
      setState(() {
        if (_distanceStart == null) {
          _distanceStart = position;
        } else if (_distanceEnd == null) {
          _distanceEnd = position;
          _polylines.add(
            Polyline(
              polylineId: PolylineId('distance_line'),
              points: [_distanceStart!, _distanceEnd!],
              color: Colors.red,
              width: 3,
            ),
          );
          double distance = _calculateHaversineDistance(_distanceStart!, _distanceEnd!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Distance: ${distance.toStringAsFixed(2)} km'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          _distanceStart = null;
          _distanceEnd = null;
          _polylines.clear();
        }
      });
    }
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        setState(() {
          _mapController = controller;
          _isMapReady = true;
          
          // If there's a selected boat when the map is created, focus on it
          if (_selectedBoat != null) {
            // Use a slight delay to ensure the map is fully loaded
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted && _selectedBoat != null) {
                _focusOnBoat(_selectedBoat!);
              }
            });
          }
        });
      },
      initialCameraPosition: _initialPosition,
      markers: _markers,
      polylines: _polylines,
      mapType: _showSatelliteView ? MapType.satellite : MapType.normal,
      onTap: _handleMapTap,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  Widget _buildWeatherOverlay() {
    if (!_showWeatherOverlay) return SizedBox.shrink();
    return Positioned.fill(
      child: Opacity(
        opacity: 0.3,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.blue.withOpacity(0.2),
            BlendMode.overlay,
          ),
          child: Image.network(
            'https://maptiler.com/media/weather-layer.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'weather',
            onPressed: () => setState(() => _showWeatherOverlay = !_showWeatherOverlay),
            child: Icon(_showWeatherOverlay ? Icons.cloud_off : Icons.cloud),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'satellite',
            onPressed: () => setState(() => _showSatelliteView = !_showSatelliteView),
            child: Icon(_showSatelliteView ? Icons.map : Icons.satellite),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'measure',
            onPressed: () => setState(() {
              _isMeasuringDistance = !_isMeasuringDistance;
              if (!_isMeasuringDistance) {
                _distanceStart = null;
                _distanceEnd = null;
                _polylines.clear();
              }
            }),
            child: Icon(_isMeasuringDistance ? Icons.close : Icons.straighten),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            onChanged: _updateSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search ships...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Cargo', 'Tanker', 'Fishing', 'Passenger'].map((type) {
              return FilterChip(
                label: Text(type),
                selected: _selectedTypes.contains(type.toLowerCase()),
                onSelected: (_) => _toggleTypeFilter(type.toLowerCase()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ship Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Filter, search, and analyze ships',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(_showSearchPanel ? Icons.search_off : Icons.search),
            title: Text('Search & Filter'),
            onTap: () {
              _toggleSearchPanel();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(_showWeatherOverlay ? Icons.cloud_off : Icons.cloud),
            title: Text('Weather Overlay'),
            onTap: () {
              setState(() {
                _showWeatherOverlay = !_showWeatherOverlay;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(_showSatelliteView ? Icons.map : Icons.satellite),
            title: Text('Satellite View'),
            onTap: () {
              setState(() {
                _showSatelliteView = !_showSatelliteView;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(_isMeasuringDistance ? Icons.close : Icons.straighten),
            title: Text('Measure Distance'),
            onTap: () {
              setState(() {
                _isMeasuringDistance = !_isMeasuringDistance;
                if (!_isMeasuringDistance) {
                  _distanceStart = null;
                  _distanceEnd = null;
                  _polylines.clear();
                }
              });
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Ship Types'),
            onTap: () {
              Navigator.pop(context);
              _showShipTypesLegend();
            },
          ),
        ],
      ),
    );
  }

  void _showShipTypesLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ship Types'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.directions_boat, color: Colors.blue),
              title: Text('Cargo Ships'),
            ),
            ListTile(
              leading: Icon(Icons.directions_boat, color: Colors.green),
              title: Text('Passenger Ships'),
            ),
            ListTile(
              leading: Icon(Icons.directions_boat, color: Colors.orange),
              title: Text('Tankers'),
            ),
            ListTile(
              leading: Icon(Icons.directions_boat, color: Colors.brown),
              title: Text('Fishing Vessels'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _focusOnBoat(Boat boat) {
    if (_mapController != null) {
      // First, make sure we're on the map screen
      setState(() {
        _selectedIndex = 0;
      });
      
      // Zoom to the boat with a higher zoom level for better visibility
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(boat.latitude, boat.longitude),
          14, // Higher zoom level for better visibility
        ),
      );
      
      // Highlight the selected boat
      setState(() {
        _selectedBoat = boat;
      });
      
      // Show a brief info popup
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Showing ${boat.name} on map'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ShipDetailsCard(boat: boat),
              );
            },
          ),
        ),
      );
    } else {
      // If map controller isn't ready yet, wait and try again
      print("Map controller not ready, waiting...");
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) _focusOnBoat(boat);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Listen for navigation results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == 1) { // Ships screen
        final navigator = Navigator.of(context);
        navigator.popUntil((route) {
          if (route.settings.arguments is Map) {
            final args = route.settings.arguments as Map;
            if (args['action'] == 'showOnMap' && args['boat'] is Boat) {
              setState(() {
                _selectedIndex = 0; // Switch to map
              });
              _focusOnBoat(args['boat'] as Boat);
              return true;
            }
          }
          return route.isFirst;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ship Admin'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Map Screen
          Stack(
            children: [
              _buildMap(),
              if (_showWeatherOverlay) _buildWeatherOverlay(),
              _buildMapControls(),
              if (_showSearchPanel) _buildSearchPanel(),
              if (_isMeasuringDistance)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Card(
                    color: Colors.blue.shade900,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        _distanceStart == null
                            ? 'Click first point to measure distance'
                            : 'Now click second point to measure distance',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Ships Screen with callback
          ShipsScreen(
            boats: boats,
            onShowBoat: (boat) {
              showBoatOnMap(boat);
            },
          ),
          // Statistics Screen
          StatisticsScreen(boats: boats),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: Duration(milliseconds: 300),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_boat),
            label: 'Ships',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
