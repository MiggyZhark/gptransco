import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    // Always hide the loading dialog before showing the error
    if (mounted) {
      hideLoadingDialog(context);

      String errorMessage = 'An error occurred. Please try again.';

      // Handle specific FirebaseAuthException error codes
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
        case 'channel-error':
          errorMessage = 'Missing Password';
          break;
        default:
          // For any other errors, keep the default error message
          errorMessage = 'Error: Please Try Again';
          break;
      }
      // Log the error (optional)
      print('Error signing in: ${e.code} - ${e.message}');

      // Show error banner with the custom error message
      _errorHandler.showErrorBanner(context, 'Oh Snap, Error Occurred!',
          errorMessage, ContentType.failure);
    }
  }

  void handleLoginResult(User? result) {
    hideLoadingDialog(context);

    if (result != null) {
      // Check if the user is email verified
      bool isEmailVerified = AuthService().isEmailVerified();
      if (!isEmailVerified) {
        hideLoadingDialog(context);
        // Navigate to email verification page
        Navigator.pushNamed(context, '/auth',
            arguments: _email.text);
      } else {
        hideLoadingDialog(context);
        // Navigate to user dashboard
        Navigator.pushReplacementNamed(context, '/userdashboard');
      }
    } else {
      hideLoadingDialog(context);
    }
  }

  Future<void> handleUserLogin() async {
    // Show loading indicator
    showLoadingDialog(context);
    try {
      // Attempt to sign in the user
      User? result = await _auth.signInWithEmailAndPassword(
        _email.text,
        _password.text,
      );
      handleLoginResult(result);
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
        const SizedBox(
          height: 40,
        ),
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
                    suffixIcon: const Icon(
                      Icons.email_outlined,
                      color: gpSecondaryColor,
                    ),
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
                  const SizedBox(
                    height: 32,
                  ),
                  CustomTextField(
                    controller: _password,
                    keyboardType: TextInputType.visiblePassword,
                    hintText: 'Password',
                    obscureText: true,
                    suffixIcon: const Icon(
                      Icons.lock_outline,
                      color: gpSecondaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length <= 5) {
                        return 'password must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            )),
        const SizedBox(
          height: 30,
        ),
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
                child: const Text(
                  'Forgot Password?',
                  style: textStyleLS,
                ),
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        FadeInUp(
            duration: const Duration(milliseconds: 1600),
            child: MaterialButton(
              onPressed: () {
                // Check if the form is valid before proceeding
                if (_formKey.currentState?.validate() ?? false) {
                  handleUserLogin(); // Proceed with login if validation is successful
                } else {
                  // Optionally, you can show an error message or handle invalid input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill in the required fields')),
                  );
                }
              },
              height: 50,
              // margin: EdgeInsets.symmetric(horizontal: 50),
              color: gpSecondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
              // decoration: BoxDecoration(
              // ),
              child: const Center(
                child: Text(
                  "Login",
                  style: textButtonStyle,
                ),
              ),
            )),
        const SizedBox(
          height: 20,
        ),
        FadeInUp(
            duration: const Duration(milliseconds: 1700),
            child: const Text(
              "Or",
              style: TextStyle(
                  color: gpSecondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            )),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInUp(
                duration: const Duration(milliseconds: 1700),
                child: const Text(
                  'don\'t have account?',
                  style: textStyleLS,
                )),
            FadeInUp(
                duration: const Duration(milliseconds: 1700),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()));
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: gpSecondaryColor,
                        decoration: TextDecoration.underline),
                  ),
                ))
          ],
        )
      ],
    );
  }
}
