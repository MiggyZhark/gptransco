import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get the current user ID
  Future<String?> getCurrentUserId() async {
    try {
      final user = _auth.currentUser;
      return user?.uid;
    } catch (e) {
      print("Error getting current user ID: $e");
      return null;
    }
  }

  // Method to get user profile data by userId
  Future<Map<String, dynamic>?> getUserProfileData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userProfileSnapshot =
      await _firestore.collection('users').doc(userId).get();
      return userProfileSnapshot.data();
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDriverProfileData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userProfileSnapshot =
      await _firestore.collection('Driver').doc(userId).get();
      return userProfileSnapshot.data();
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}
