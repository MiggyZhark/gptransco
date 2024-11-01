import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../Services/firebase_database.dart';
import '../components/chathub.dart';
import 'Screens/Dhome.dart';
import 'Screens/Dpassengers.dart';
import 'Screens/Dprofile.dart';
import 'Screens/Drental.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  var iconList = [
    Icons.group,
    Icons.messenger,
    Icons.car_rental,
    Icons.person,
  ];

  int _currentIndex = -1; // Initial index set to -1, representing HomeScreen
  final Database _database = Database(); // Instantiate the database service
  Map<String, dynamic>? driverProfileData;

  // List of screens for each tab
  final List<Widget> _screens = [
    const Passengers(),
    const ChatHub(),
    const DRentalScreen(),
    // ProfileScreen will be handled separately
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUserProfile(); // Pre-fetch user profile data on initialization
  }

  // Method to fetch user profile data
  Future<void> getCurrentUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? data = await _database.getDriverProfileData(user.uid);
      setState(() {
        driverProfileData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if userProfileData is not yet loaded
    if (driverProfileData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Home screen for the FAB with userProfileData
    final Widget homeScreen = DriverHomeScreen(userProfileData: driverProfileData!);

    return SafeArea(
      child: Scaffold(
        body: _currentIndex == -1 ? homeScreen : _screens[_currentIndex], // Show home screen or selected tab
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = -1; // Set to -1 to represent the Home screen
            });
          },
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Icon(
            Icons.home,
            size: 30,
            color: _currentIndex == -1 ? Colors.greenAccent : Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
          activeColor: Colors.greenAccent,
          inactiveColor: Colors.white,
          backgroundColor: Colors.black87,
          icons: iconList,
          activeIndex: _currentIndex == -1 ? -1 : _currentIndex, // Ensure FAB is treated separately
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() {
              if (index == 3) { // If the profile tab is tapped
                if (driverProfileData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverProfileScreen(userProfileData: driverProfileData!), // Pass user data to ProfileScreen
                    ),
                  );
                } else {
                  // Handle loading state or error if data is not available
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile data is still loading.')),
                  );
                }
              } else {
                _currentIndex = index; // Update the index based on tab selection, except for Profile
              }
            });
          },
        ),
      ),
    );
  }
}
