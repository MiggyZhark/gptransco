import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../constants.dart';
import 'components/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                        "Welcome Back,",
                        style:
                            TextStyle(color: gpBottomSheetColor, fontSize: 24),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: const Text(
                        "Log In!",
                        style:
                            TextStyle(color: gpBottomSheetColor, fontSize: 19),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1300),
                child: Container(
                  decoration: const BoxDecoration(
                      color: gpPrimaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: const Padding(
                    padding: EdgeInsets.all(25),
                    child: SingleChildScrollView(
                      child: LoginForm(),
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
