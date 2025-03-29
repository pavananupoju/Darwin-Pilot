import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/boat.dart';

class BoatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all boats for a user
  Stream<List<Boat>> getBoats(String userId) {
    return _firestore
        .collection('boats')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Boat.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Add a new boat
  Future<void> addBoat(String userId, Map<String, dynamic> boatData) async {
    await _firestore.collection('boats').add({
      ...boatData,
      'userId': userId,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Update boat location
  Future<void> updateBoatLocation(
      String boatId, double latitude, double longitude) async {
    await _firestore.collection('boats').doc(boatId).update({
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Update boat status
  Future<void> updateBoatStatus(String boatId, String status) async {
    await _firestore.collection('boats').doc(boatId).update({
      'status': status,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Delete boat
  Future<void> deleteBoat(String boatId) async {
    await _firestore.collection('boats').doc(boatId).delete();
  }
}
