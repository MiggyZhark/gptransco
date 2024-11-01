import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gptransco/Screens/Welcome/Onboarding_slider.dart';
import 'package:gptransco/Screens/Dashboards/Driver/Driver_Dashboard.dart';
import '../Screens/Dashboards/Users/User_Dashboard.dart';
import '../constants.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  Future<bool> isDriver(User user) async {
    final driverDoc = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(user.uid)
        .get();
    return driverDoc.exists && driverDoc['isDriver'] == true && driverDoc['role'] == 'Driver';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: gpSecondaryColor,
        statusBarIconBrightness: Brightness.light, // Adjust based on design
      ),
    );
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;

            return FutureBuilder<bool>(
              future: isDriver(user),
              builder: (context, isDriverSnapshot) {
                if (isDriverSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (isDriverSnapshot.hasData && isDriverSnapshot.data == true) {
                  // Automatically navigates driver to DriverDashboard
                  return const DriverDashboard();
                } else if (user.emailVerified) {
                  // Non-driver verified user goes to UserDashboard
                  return const UserDashboard();
                } else {
                  // User not verified goes to OnboardingSlider
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

