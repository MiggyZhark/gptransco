import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Services/firebase_database.dart';
import 'Screens/Driver_Home/Dhome.dart';
import 'Screens/Dpassengers.dart';
import 'Screens/Dprofile.dart';
import 'Screens/Drental.dart';
import 'driver_chathub.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final Database _database = Database();
  Map<String, dynamic>? driverProfileData;
  int totalReservations = 0;

  var iconList = [
    Icons.messenger,
    Icons.group,
    Icons.car_repair_sharp,
    Icons.person,
  ];

  int _currentIndex = -1;
  final List<Widget> _screens = [
    const DriverChatHub(),
    const Passengers(),
    const DRentalScreen(),
  ];

  @override
  void initState() {
    super.initState();
    getCurrentUserProfile(); // Fetch driver profile data
    fetchTotalReservations(); // Fetch total reservations
  }

  // Fetch the driver profile data
  Future<void> getCurrentUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? data = await _database.getDriverProfileData(user.uid);
      setState(() {
        driverProfileData = data;
      });
    }
  }

  // Fetch the total reservations count
  Future<void> fetchTotalReservations() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('Driver')
            .doc(user.uid)
            .collection('Passenger')
            .get();

        setState(() {
          totalReservations = querySnapshot.size;
        });
      }
    } catch (e) {
      print('Error fetching reservations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (driverProfileData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Widget homeScreen = DriverHomeScreen(
      userProfileData: driverProfileData!,
      totalReservations: totalReservations, // Pass total reservations
    );

    return SafeArea(
      child: Scaffold(
        body: _currentIndex == -1 ? homeScreen : _screens[_currentIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = -1;
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
          activeIndex: _currentIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() {
              if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverProfileScreen(
                        userProfileData: driverProfileData!),
                  ),
                );
              } else {
                _currentIndex = index;
              }
            });
          },
        ),
      ),
    );
  }
}
