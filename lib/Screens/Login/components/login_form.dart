import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gptransco/Screens/Dashboards/Dispatcher/Dispatcher_Dashbord.dart';
import 'package:gptransco/Screens/Dashboards/Driver/Driver_Dashboard.dart';
import 'package:gptransco/Screens/Dashboards/Users/User_Dashboard.dart';
import '../../../Services/auth_service.dart';
import '../../../Services/error_handling.dart';
import '../../../constants.dart';
import '../../Signup/components/customTextfield.dart';
import '../../Signup/signup_screen.dart';
import 'forgot_password.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _errorHandler = ErrorHandling();
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void handleLoginError(FirebaseAuthException e) {
    // Hide the loading dialog before showing the error
    if (mounted) {
      hideLoadingDialog(context);

      String errorMessage = 'An error occurred. Please try again.';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'missing-password':
          errorMessage = 'Please enter your password.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid Credential';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Try again later.';
          break;
        default:
          errorMessage = 'Error: Please Try Again';
          break;
      }

      print('Error signing in: ${e.code} - ${e.message}');
      _errorHandler.showErrorBanner(context, 'Oh Snap, Error Occurred!',
          errorMessage, ContentType.failure);
    }
  }

  void handleNavigationAfterLogin(User? user, String role) {
    hideLoadingDialog(context);

    if (role == 'Driver') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DriverDashboard()),
            (route) => false,
      );
    } else if (role == 'Dispatcher') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DispatcherDashboard()),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserDashboard()),
            (route) => false,
      );
    }
  }

  Future<void> handleUserLogin() async {
    showLoadingDialog(context); // Show loading indicator
    try {
      // Attempt to sign in the user
      User? result = await _auth.signInWithEmailAndPassword(
        _email.text,
        _password.text,
      );

      if (result != null) {
        // Check the Driver collection for role
        final driverDoc = await FirebaseFirestore.instance
            .collection('Driver')
            .doc(result.uid)
            .get();

        if (driverDoc.exists) {
          // If user is found in Driver collection, use the role from there
          String role = driverDoc.data()?['role'] ?? 'User';
          handleNavigationAfterLogin(result, role);
        } else {
          // If not found in Driver collection, check the users collection
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(result.uid)
              .get();

          if (userDoc.exists) {
            // If found in users collection, use the role from there
            String role = userDoc.data()?['role'] ?? 'User';
            handleNavigationAfterLogin(result, role);
          } else {
            handleLoginError(FirebaseAuthException(
                code: 'user-not-found', message: 'User document does not exist.'));
          }
        }
      } else {
        handleLoginError(FirebaseAuthException(
            code: 'login-failed', message: 'Login failed, please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      handleLoginError(e);
    }
  }



  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 40),
        FadeInUp(
          duration: const Duration(milliseconds: 1400),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                CustomTextField(
                  controller: _email,
                  keyboardType: TextInputType.name,
                  hintText: 'Enter your email',
                  obscureText: false,
                  suffixIcon: const Icon(Icons.email_outlined, color: gpSecondaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _password,
                  keyboardType: TextInputType.visiblePassword,
                  hintText: 'Password',
                  obscureText: true,
                  suffixIcon: const Icon(Icons.lock_outline, color: gpSecondaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length <= 5) {
                      return 'Password must be 6 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Align(
          alignment: Alignment.centerRight,
          child: FadeInUp(
            duration: const Duration(milliseconds: 1500),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPassword()));
              },
              child: const Text('Forgot Password?', style: textStyleLS),
            ),
          ),
        ),
        const SizedBox(height: 30),
        FadeInUp(
          duration: const Duration(milliseconds: 1600),
          child: MaterialButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                handleUserLogin(); // Proceed with login if validation is successful
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in the required fields')),
                );
              }
            },
            height: 50,
            color: gpSecondaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            child: const Center(
              child: Text("Login", style: textButtonStyle),
            ),
          ),
        ),
        const SizedBox(height: 20),
        FadeInUp(
          duration: const Duration(milliseconds: 1700),
          child: const Text("Or", style: TextStyle(
              color: gpSecondaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 1700),
              child: const Text("Don't have an account?", style: textStyleLS),
            ),
            FadeInUp(
              duration: const Duration(milliseconds: 1700),
              child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()));
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: gpSecondaryColor,
                      decoration: TextDecoration.underline),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

