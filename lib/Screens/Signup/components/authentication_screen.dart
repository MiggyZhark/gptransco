import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../Services/auth_service.dart';
import '../../../constants.dart';

class AuthenticationScreen extends StatefulWidget {
  final String? email;
  final String? mobileNumber;
  final String? name;
  const AuthenticationScreen({super.key,this.email,this.mobileNumber,this.name});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  bool isSendingEmail = false;
  bool isDriver = false;

  @override
  void initState() {
    super.initState();

    // Immediately check if the email is already verified using AuthService
    isEmailVerified = AuthService().isEmailVerified();

    if (!isEmailVerified) {
      // Start periodic timer to check verification status every 3 seconds
      timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerifiedStatus());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerifiedStatus() async {
    // Reload the user to get updated email verification status
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = AuthService().isEmailVerified();  // Using AuthService to check if verified
    });

    // If the email is verified, update Firestore and navigate to the login page
    if (isEmailVerified) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Update the 'isEmailVerified' field in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'isEmailVerified': true,  // Update to true after verification
        });

        timer?.cancel();  // Stop the timer once the email is verified
        Navigator.pushReplacementNamed(context, '/login');  // Navigate to login page
      }
    }
  }

  Future<void> checkIfDriver() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      setState(() {
        isDriver = adminSnapshot.exists && adminSnapshot['isDriver'] == true;
      });

      if (isDriver) {
        // Skip email verification if the user is an admin
        setState(() {
          isEmailVerified = true;
        });
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      setState(() {
        isSendingEmail = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        canResendEmail = true;
        isSendingEmail = false;
      });
    } catch (e) {
      setState(() {
        isSendingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? email = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: gpSecondaryColor,
      appBar: AppBar(
        title: const Text(
          'Authentication',
          style: headerTitle,
        ),
        centerTitle: true,
        backgroundColor: gpSecondaryColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: gpBottomSheetColor),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                width: 380, height: 300, 'assets/images/Authentication.png'),
            Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.89,
                  decoration: BoxDecoration(
                      color: gpPrimaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 15,),
                      const Text(
                        'Confirm your email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: gpSecondaryColor),
                      ),
                      const Divider(height: 15,),
                      const Text(
                        'We sent a confirmation email to:',
                        style: contentTextAuth,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        email ?? 'Unknown email', // Display the passed email here
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        textAlign: TextAlign.center,
                        'Check your email and click on the confirmation link to continue.',
                        style: contentTextAuth,
                      ),
                      const SizedBox(height: 10,)
                    ],
                  ),
                )),
            TextButton(
                onPressed: canResendEmail ? sendVerificationEmail : null,
                child: const Text(
                  'Resend Link',
                  style: TextStyle(decorationColor: Colors.white,color: gpPrimaryColor,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.17,)
          ],
        ),
      ),
    );
  }
}
