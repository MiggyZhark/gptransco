import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // Firestore instance

  // Create user with email, password, and save additional info like mobile number
  Future<User?> createUserWithEmailAndPassword(
      String email, String password, String mobileNumber, String name) async {
    try {
      // Create user in Firebase Auth
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user information to Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'mobileNumber': mobileNumber,
        'name': name,
        'uid': cred.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'profileImageUrl': '',
      });

      // Send email verification
      await cred.user?.sendEmailVerification();

      return cred.user;
    } catch (e) {
      log('Error creating user: $e');
      rethrow;
    }
  }


  // Sign in with email and password (only if email is verified)
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (cred.user != null && cred.user!.emailVerified) {
        return cred.user;
      } else if (!cred.user!.emailVerified) {
        await cred.user!.sendEmailVerification();
        return cred.user;
      }
      return null;
    } catch (e) {
      log('Error creating user: $e');
      rethrow;
    }
  }

  // Send email verification manually
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Email verification sent.');
      }
    } catch (e) {
      print('Error sending email verification: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }


  // Reset password
  Future<User?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
    }
    return null;
  }

  // Check if the user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Check if the email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Reload the user to get updated verification status
  Future<void> reloadUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      user = _auth.currentUser;  // refresh user instance
    }
  }

  // Change password by re-authenticating the user first
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user using their current password
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Once re-authenticated, update the password
        await user.updatePassword(newPassword);
        print('Password changed successfully');
      }
    } catch (e) {
      log('Error changing password: $e');
      rethrow;
    }
  }
}

