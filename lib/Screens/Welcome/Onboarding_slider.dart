import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import '../../constants.dart';
import '../Login/login_screen.dart';
import '../Signup/signup_screen.dart';

class OnboardingSlider extends StatelessWidget {
  const OnboardingSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingSlider(
        middle: const Text(
          'GPTransco',
          style: TextStyle(color: gpPrimaryColor, fontSize: 18),
        ),
        onFinish: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignupScreen(),
            ),
          );
        },
        centerBackground: true,
        controllerColor: gpSecondaryColor,
        headerBackgroundColor: gpSecondaryColor,
        finishButtonText: 'Register Now',
        finishButtonStyle: FinishButtonStyle(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: gpSecondaryColor,
        ),
        skipTextButton: const Text(
          'Skip',
          style: TextStyle(color: gpPrimaryColor),
        ),
        background: [
          SizedBox(
              height: 300,
              child: Image.asset(
                'assets/images/Mail.png',
                fit: BoxFit.fitHeight,
              )),
          SizedBox(
              height: 300, child: Image.asset('assets/images/Car_Rent.png')),
          SizedBox(
              height: 300, child: Image.asset('assets/images/Deliveryman.png')),
        ],
        totalPage: 3,
        speed: 1.6,
        pageBodies: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  const Text(
                    'Introduction',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: gpSecondaryColor),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: const TextSpan(
                        style: TextStyle(
                          color: gpSecondaryColor,
                          fontSize: 18,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'GPTransco',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ' is your go-to app in General Santos City for renting vans and delivering packages. It\'s easy, convenient, and connects you with trusted drivers.')
                        ]),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                const Text(
                  'Van Rental and Booking',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: gpSecondaryColor),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  textAlign: TextAlign.justify,
                  'Book a van and driver with GPTransco for your moves, deliveries, or trips. '
                  'Choose the right van and enjoy a hassle-free experience.',
                  style: TextStyle(color: gpSecondaryColor),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),
                const Text(
                  'Package Delivery',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: gpSecondaryColor),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  textAlign: TextAlign.justify,
                  'Send packages easily with GPTransco. Post your package details, and a driver will pick it up and deliver it safely to the destination of the chosen Terminal.',
                  style: TextStyle(color: gpSecondaryColor),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  'Get Started?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: gpSecondaryColor),
                ),
                const Divider(
                  thickness: 1,
                  color: gpSecondaryColor,
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  },
                  height: 50,
                  color: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
