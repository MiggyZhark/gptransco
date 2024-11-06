import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gptransco/Screens/Dashboards/Dispatcher/Dispatcher_Dashbord.dart';
import 'package:gptransco/Screens/Welcome/Onboarding_slider.dart';
import 'package:gptransco/Screens/Dashboards/Driver/Driver_Dashboard.dart';
import '../Screens/Dashboards/Users/User_Dashboard.dart';
import '../constants.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  Future<String?> getUserRole(User user) async {
    // First check the Driver collection
    final driverDoc = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(user.uid)
        .get();

    if (driverDoc.exists) {
      return driverDoc.data()?['role'];
    }

    // If not found in Driver collection, check the users collection
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data()?['role'];
    }

    // Return null if no role found in either collection
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: gpSecondaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;

            return FutureBuilder<String?>(
              future: getUserRole(user),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasData) {
                  final role = roleSnapshot.data;

                  // Navigate based on role
                  if (role == 'Driver') {
                    return const DriverDashboard();
                  } else if (role == 'Dispatcher') {
                    return const DispatcherDashboard();
                  } else {
                    return const UserDashboard();
                  }
                } else if (user.emailVerified) {
                  // Default to UserDashboard if no specific role is found
                  return const UserDashboard();
                } else {
                  // If the user's email isn't verified, go to onboarding
                  return const OnboardingSlider();
                }
              },
            );
          } else {
            // No user is signed in, show onboarding
            return const OnboardingSlider();
          }
        },
      ),
    );
  }
}
