import 'package:animate_do/animate_do.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:gptransco/Services/auth_service.dart';
import '../../../Services/error_handling.dart';
import '../../../constants.dart';
import '../../Signup/components/customTextfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _auth = AuthService();
  final _email = TextEditingController();
  late AnimationController zoomController;
  final _errorHandler = ErrorHandling();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void handleForgotResult(String email) {
    hideLoadingDialog(context);
    showDialog(
        context: context,
        builder: (context) {
          return ZoomIn(
            animate: true,
            controller: (controller) => zoomController = controller,
            duration: const Duration(milliseconds: 1000),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          backgroundColor: Colors.greenAccent),
                      onPressed: () {
                        zoomController.reverse();
                        Future.delayed(const Duration(milliseconds: 800), () {
                          Navigator.pop(context); // Close the dialog
                        }); // Close the dialog
                      },
                      child: const FittedBox(
                        child: Text(
                          'Done',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )),
                )
              ],
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    style: const TextStyle(
                      color: gpSecondaryColor,
                      fontSize: 18,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Your reset has been successfully created. '
                            'A reset password link has been sent to your email ',style: TextStyle(fontSize: 14),
                      ),
                      TextSpan(text: email,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14))
                    ]),
              ),
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent,
                size: 100,
              ),
              title: const Text(
                'Success',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: gpSecondaryColor,
                    fontSize: 26),
              ),
            ),
          );
        });
  }

  Future<void> forgotHandler() async {
    String email = _email.text.trim(); // Trim to remove unnecessary whitespaces

    // Check if email is empty
    if (email.isEmpty) {
      _errorHandler.showErrorBanner(context, 'Oh Snap!',
          'Email field cannot be empty.', ContentType.failure);
      return; // Stop further execution
    }

    // Check if email is valid (basic email regex)
    bool emailValid =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email);
    if (!emailValid) {
      _errorHandler.showErrorBanner(context, 'Oh Snap!',
          'Please enter a valid email address.', ContentType.failure);
      return; // Stop further execution
    }

    // If everything is valid, proceed to send password reset email
    showLoadingDialog(context);
    await _auth.sendPasswordResetEmail(email);
    handleForgotResult(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gpPrimaryColor,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: headerTitle,
        ),
        centerTitle: true,
        backgroundColor: gpSecondaryColor,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: gpPrimaryColor),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
                width: 420, height: 280, 'assets/images/forgotpassword.png'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'FORGOT YOUR PASSWORD?',
                      style: TextStyle(
                          color: gpSecondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                      child: Text(
                        textAlign: TextAlign.center,
                        'No worries! Enter your email below, and we\'ll send you a link to reset your password.',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: gpSecondaryColor),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20),
                      child: CustomTextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        hintText: 'Type Your Email',
                        suffixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Align(
                        alignment:
                            Alignment.centerRight, // Aligns button to the right
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: gpSecondaryColor),
                          onPressed: forgotHandler,
                          child: const Row(
                            mainAxisSize: MainAxisSize
                                .min, // Makes sure the Row takes minimal space
                            children: [
                              Text(
                                'SEND',
                                style: TextStyle(
                                    color: gpPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.send,
                                color: gpPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
