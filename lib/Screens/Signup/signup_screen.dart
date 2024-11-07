import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: gpSecondaryColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 80,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Welcome,",
                        style:
                            TextStyle(color: gpBottomSheetColor, fontSize: 24),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: const Text(
                        "Sign Up!",
                        style:
                            TextStyle(color: gpBottomSheetColor, fontSize: 19),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1300),
                child: Container(
                  child: const Padding(
                    padding: EdgeInsets.all(25),
                    child: SingleChildScrollView(
                      child: SignupForm(),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
