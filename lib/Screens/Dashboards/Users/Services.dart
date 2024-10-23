import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to pick an image from the gallery
  Future<File?> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null; // Return null if no image is picked
  }

  // Function to upload the image to Firebase Storage and return the download URL
  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profileImages')
          .child('$uid.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Return the image URL after upload
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Function to save the image URL to Firestore
  Future<void> saveImageUrlToFirestore(String imageUrl) async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
      });
    } catch (e) {
      print('Error saving image URL: $e');
    }
  }

  // Function to load the user's profile image URL from Firestore
  Future<String?> loadProfileImageFromFirestore() async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists && userDoc['profileImageUrl'] != null) {
        return userDoc['profileImageUrl'];
      }
      return null;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }
}
