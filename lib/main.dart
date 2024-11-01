import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Dashboards/Driver/Driver_Dashboard.dart';
import 'package:gptransco/Screens/Dashboards/Users/User_Dashboard.dart';
import 'package:gptransco/Screens/Login/login_screen.dart';
import 'package:gptransco/Screens/Signup/components/authentication_screen.dart';
import 'package:gptransco/Services/Authentication.dart';
import 'Screens/Dashboards/components/Services.dart';
import 'constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPTransco',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: gpBottomNavigationColorDark),
          dividerTheme: const DividerThemeData(color: gpSecondaryColor),
          iconTheme: const IconThemeData(size: 23, color: Colors.white),
          primaryColor: gpSecondaryColor,
          scaffoldBackgroundColor: gpPrimaryColor,
          dialogBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))))),
      initialRoute: "/",
      routes: {
        "/": (context) => const Authentication(),
        "/auth": (context) => const AuthenticationScreen(),
        "/login": (context) => const LoginScreen(),
        "/userDashboard": (context) => const UserDashboard(),
        "/driverDashboard": (context) => const DriverDashboard(),
        "/UpdatePassword": (context) => const UpdatePassword(),
      },
    );
  }
}
