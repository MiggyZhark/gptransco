import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gptransco/Screens/Welcome/Onboarding_slider.dart';
import 'package:gptransco/Screens/Dashboards/Driver_Dashboard.dart';
import '../Screens/Dashboards/Users/User_Dashboard.dart';
import '../constants.dart';

class Authentication extends StatelessWidget {
  const Authentication({super.key});

  Future<bool> isDriver(User user) async {
    final adminDoc = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(user.uid)
        .get();
    return adminDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: gpSecondaryColor,
        statusBarIconBrightness: Brightness.light,  // Adjust based on design
      ),
    );
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;

            // Check if email is verified
            if (user.emailVerified) {
              return FutureBuilder<bool>(
                future: isDriver(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data == true) {
                    return const DriverDashboard(); // Driver account
                  } else {
                    return const UserDashboard(); // Non-driver verified user goes to UserDashboard
                  }
                },
              );
            } else {
              // If email is not verified, navigate to the AuthenticationScreen
              return const OnboardingSlider();
            }
          } else {
            // If no user is signed in, show onboarding
            return const OnboardingSlider();
          }
        },
      ),
    );
  }
}
