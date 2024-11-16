import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gptransco/Screens/Dashboards/Dispatcher/Screens/Dispatcher_Home_Screen.dart';
import 'package:gptransco/Screens/Dashboards/Dispatcher/Screens/Dispatcher_Profile.dart';
import '../../../../Services/firebase_database.dart';
import 'Screens/Dispatcher_Booking_Screen.dart';
import 'Screens/Shipping_Screen.dart';
import 'dispatcher_chathub.dart';


class DispatcherDashboard extends StatefulWidget {
  const DispatcherDashboard({super.key});

  @override
  State<DispatcherDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DispatcherDashboard> {
  final Database _database = Database();
  Map<String, dynamic>? driverProfileData;
  int totalReservations = 0;

  var iconList = [
    Icons.messenger,
    Icons.local_shipping,
    Icons.list_alt,
    Icons.person,
  ];

  int _currentIndex = -1;
  final List<Widget> _screens = [
    const DispatcherChatHub(),
    const DispatcherBookingScreen(),
    const DispatcherShipping(),
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

    final Widget homeScreen = DispatcherHomeScreen(
      userProfileData: driverProfileData!,
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
                    builder: (context) => DispatcherProfileScreen(
                        dispatcherProfileData: driverProfileData!),
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
