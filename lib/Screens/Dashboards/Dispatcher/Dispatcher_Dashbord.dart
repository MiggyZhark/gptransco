import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Services/firebase_database.dart';
import 'Screens/Dispatcher_Home_Scree.dart';

class DispatcherDashboard extends StatefulWidget {
  const DispatcherDashboard({super.key});

  @override
  State<DispatcherDashboard> createState() => _DispatcherDashboardState();
}

class _DispatcherDashboardState extends State<DispatcherDashboard> {
  var iconList = [
    Icons.message,
    Icons.person,
  ];

  int _currentIndex = -1;
  final Database _database = Database();
  Map<String, dynamic>? userProfileData;

  @override
  void initState() {
    super.initState();
    getCurrentUserProfile();
  }

  Future<void> getCurrentUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? data = await _database.getDriverProfileData(user.uid);
      if (mounted) {
        setState(() {
          userProfileData = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfileData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Widget homeScreen =
        DispatcherHomeScreen(userProfileData: userProfileData!);

    return SafeArea(
      child: Scaffold(
        body: _currentIndex == -1 ? homeScreen : Container(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = -1;
            });
          },
          backgroundColor: Colors.black87,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Icon(
            Icons.home,
            size: 30,
            color: _currentIndex == -1 ? Colors.greenAccent : Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          items: iconList
              .map((icon) =>
                  BottomNavigationBarItem(icon: Icon(icon), label: ''))
              .toList(),
          currentIndex: _currentIndex == -1 ? 0 : _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.black87,
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white,
        ),
      ),
    );
  }
}
