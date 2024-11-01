import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../Services/auth_service.dart';
import '../../../Services/error_handling.dart';
import '../../../constants.dart';
import '../../Signup/components/customTextfield.dart';

class ImageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to pick an image from the gallery
  Future<File?> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null; // Return null if no image is picked
  }

  // Function to upload the image to Firebase Storage and return the download URL
  Future<String?> userUploadImageToStorage(File imageFile) async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      final storageRef =
          FirebaseStorage.instance.ref().child('UserImages').child('$uid.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Return the image URL after upload
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> driverUploadImageToStorage(File imageFile) async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      final storageRef =
      FirebaseStorage.instance.ref().child('DriverImages/$uid').child('$uid.jpg');

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

  Future<void> saveDriverImageUrlToFirestore(String imageUrl) async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      await FirebaseFirestore.instance.collection('Driver').doc(uid).update({
        'driverImage': imageUrl,
      });
    } catch (e) {
      print('Error saving image URL: $e');
    }
  }

  // Function to load the user's profile image URL from Firestore
  Future<String?> loadProfileImageFromFirestore() async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc['profileImageUrl'] != null) {
        return userDoc['profileImageUrl'];
      }
      return null;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

  Future<String?> loadDriverProfileImageFromFirestore() async {
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown';

      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('Driver').doc(uid).get();

      if (userDoc.exists && userDoc['driverImage'] != null) {
        return userDoc['driverImage'];
      }
      return null;
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

}

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _newConfirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _errorHandler = ErrorHandling();
  final _authService = AuthService(); // Instance of AuthService

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _newConfirmPassword.dispose();
    super.dispose();
  }

  void handleUpdateError(FirebaseAuthException e) {
    hideLoadingDialog(context);
    // Always hide the loading dialog before showing the error
    if (mounted) {
      String errorMessage = 'An error occurred. Please try again.';
      // Handle specific FirebaseAuthException error codes
      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'Old password provided is wrong.';
          break;
        default:
          // For any other errors, keep the default error message
          errorMessage = 'Error: A network error has occurred';
          break;
      }
      // Log the error (optional)
      print('Error signing in: ${e.code} - ${e.message}');

      // Show error banner with the custom error message
      _errorHandler.showErrorBanner(
          context, 'Password Change Failed', errorMessage, ContentType.failure);
    }
  }

  void handleUpdateSuccess() {
    hideLoadingDialog(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPassword.text != _newConfirmPassword.text) {
        hideLoadingDialog(context);
        _errorHandler.showErrorBanner(
          context,
          'Oh Snap, Error Occurred!',
          'Passwords do not match',
          ContentType.failure,
        );
      } else {
        try {
          await _authService.changePassword(
              _oldPassword.text, _newPassword.text);
          // If successful, show success message
          handleUpdateSuccess();
          // Optionally clear the fields
          _oldPassword.clear();
          _newPassword.clear();
          _newConfirmPassword.clear();
        } on FirebaseAuthException catch (e) {
          // Handle errors (e.g., incorrect old password)
          handleUpdateError(e);
        }
      }
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
            color: gpPrimaryColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45), topRight: Radius.circular(45))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _oldPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  hintText: 'Old Password',
                  suffixIcon: const Icon(Icons.history),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Old Password';
                    }
                    if (value.length <= 5) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                CustomTextField(
                  controller: _newPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  hintText: 'New Password',
                  suffixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your New Password';
                    }
                    if (value.length <= 5) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                CustomTextField(
                  controller: _newConfirmPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  hintText: 'Confirm New Password',
                  suffixIcon: const Icon(Icons.key),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Confirm New Password';
                    }
                    if (value.length <= 5) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF07917C),
                                    Color(0xFF0CB39B),
                                    Color(0xFF06BAA4)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 18),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 70),
                              ),
                              onPressed: _updatePassword,
                              // Update password on button press
                              child: const Text(
                                'Update Password',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
