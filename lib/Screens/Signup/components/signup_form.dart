import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gptransco/Services/error_handling.dart';
import '../../../Services/auth_service.dart';
import '../../../constants.dart';
import '../../Login/login_screen.dart';
import 'customTextfield.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _errorHandler = ErrorHandling();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobileNumber = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobileNumber.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void handleRegisterError(FirebaseAuthException e) {
// Always hide the loading dialog before showing the error
    if (mounted) {
      hideLoadingDialog(context);

      String errorMessage = 'An error occurred. Please try again.';

      // Handle specific FirebaseAuthException error codes
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'email addres is already exist';
          break;
        case 'invalid-email':
          errorMessage = 'email address entered is not valid.';
          break;
        case 'weak-password':
          errorMessage = 'password provided is too weak.';
          break;
        default:
          // For any other errors, keep the default error message
          errorMessage = 'Error: A network error has occurred';
          break;
      }
      // Log the error (optional)
      print('Error signing in: ${e.code} - ${e.message}');

      // Show error banner with the custom error message
      _errorHandler.showErrorBanner(context, 'Oh Snap, Error Occurred!',
          errorMessage, ContentType.failure);
    }
  }

  void handleRegisterResult(User? result) {
    if (_formKey.currentState!.validate()) {
      if (result != null && context.mounted) {
        hideLoadingDialog(context);
        Navigator.pushReplacementNamed(
          context,
          '/auth',
          arguments: _email.text,
        );
      } else {
        hideLoadingDialog(context);
        print(result);
      }
    } else {
      hideLoadingDialog(context);
      _errorHandler.showErrorBanner(context, 'Oh Snap, Error Occurred!',
          'Please fill up the form', ContentType.failure);
    }
  }

  Future<void> handleUserCreation() async {
    showLoadingDialog(context);

    if (_password.text != _confirmPassword.text) {
      hideLoadingDialog(context);
      _errorHandler.showErrorBanner(context, 'Oh Snap, Error Occurred!',
          'Password not matched', ContentType.failure);
    } else {
      try {
        User? result = await AuthService().createUserWithEmailAndPassword(
          _email.text,
          _password.text,
          _mobileNumber.text,
          _name.text,
        );
        handleRegisterResult(result);
      } on FirebaseAuthException catch (e) {
        handleRegisterError(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 15,
        ),
        FadeInUp(
            duration: const Duration(milliseconds: 1400),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    controller: _name,
                    keyboardType: TextInputType.name,
                    hintText: 'Name',
                    obscureText: false,
                    suffixIcon: const Icon(
                      Icons.person_2_outlined,
                      color: gpSecondaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Name';
                      }
                      if (value.length <= 6) {
                        return 'Mobile number must be 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    obscureText: false,
                    suffixIcon: const Icon(
                      Icons.email_outlined,
                      color: gpSecondaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                      controller: _mobileNumber,
                      keyboardType: TextInputType.number,
                      hintText: 'Mobile Number',
                      obscureText: false,
                      suffixIcon: const Icon(
                        Icons.phone_android,
                        color: gpSecondaryColor,
                      ),
                      maxChar: 11,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 11) {
                        return 'Mobile number must be 11 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    controller: _password,
                    keyboardType: TextInputType.text,
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
                      if (value.length <= 6) {
                        return 'password must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextField(
                    controller: _confirmPassword,
                    keyboardType: TextInputType.text,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    suffixIcon: const Icon(
                      Icons.key_outlined,
                      color: gpSecondaryColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your confirm password';
                      }
                      if (value.length <= 6) {
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FadeInUp(
            duration: const Duration(milliseconds: 1500),
            child: Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _termsAccepted,
                onChanged: (bool? newValue) {
                  setState(() {
                    _termsAccepted = newValue ?? false;
                  });
                },
              ),
            ),
          ),
          FadeInUp(
              duration: const Duration(milliseconds: 1500),
              child: Row(
                children: [
                  const Text(
                    'I agree to the',
                    style: textStyleLS,
                  ),
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Terms & Conditions',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: gpSecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ))
                ],
              )),
        ]),
        const SizedBox(
          height: 30,
        ),
        FadeInUp(
            duration: const Duration(milliseconds: 1600),
            child: MaterialButton(
              disabledColor: const Color.fromARGB(120, 28, 63, 57),
              onPressed: _termsAccepted
                  ? () {
                      if (_formKey.currentState?.validate() ?? false) {
                        handleUserCreation(); // Proceed if validation passes
                      }
                    }
                  : null,
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
                  "Sign Up",
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
                  'Have account?',
                  style: textStyleLS,
                )),
            FadeInUp(
                duration: const Duration(milliseconds: 1700),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Log In',
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
