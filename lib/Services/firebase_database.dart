// database.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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



}
