import 'package:flutter/material.dart';
import 'package:gptransco/Services/auth_service.dart';
import '../../../../Services/Authentication.dart';
import '../../../../constants.dart';
import '../components/profiletextbox.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfileData;
  const ProfileScreen({super.key, required this.userProfileData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();

  void logoutNavigate(){
    hideLoadingDialog(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Authentication()),
          (Route<dynamic> route) => false,  // This removes all previous routes.
    );
  }

  Future<void> logoutHandler() async{
    showLoadingDialog(context);
    await _auth.signOut();
    logoutNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: gpBottomNavigationColor,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                  size: 20,
                  color: gpIconColor,
                ))
          ],
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: true,
          title: const Text(
            'Profile',
            style: headerTitle,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/profile-user.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Change Profile',
                style: TextStyle(
                    color: gpPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(
                  color: gpPrimaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(45),
                      topRight: Radius.circular(45))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const ProfileTextLabel(
                        labelText: 'Full Name',
                      ),
                      ProfileTextBox(
                        contentText: widget.userProfileData['name'] ?? 'N/A',
                      ),
                      const ProfileTextLabel(
                        labelText: 'Email',
                      ),
                      ProfileTextBox(
                        contentText: widget.userProfileData['email'] ?? 'N/A',
                      ),
                      const ProfileTextLabel(
                        labelText: 'Mobile Number',
                      ),
                      ProfileTextBox(
                        contentText: widget.userProfileData['mobileNumber'] ?? 'N/A',
                      ),
                      const ProfileTextLabel(
                        labelText: 'Address',
                      ),
                      ProfileTextBox(
                        contentText: widget.userProfileData['address'] ?? 'N/A',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: gpBottomNavigationColor),
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {},
                            child: const Text(
                              'Change Password',
                              style: TextStyle(
                                  color: gpBottomNavigationColor, fontSize: 14),
                            )),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    title: const Text(
                                      'Confirm Logout',
                                      style: TextStyle(
                                          color: gpBottomNavigationColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: const Text(
                                      'Are you sure you want to logout?',
                                      style: dialogTextColor,
                                    ),
                                    actions: [
                                      Row(mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(style: ElevatedButton.styleFrom(side: const BorderSide(color: gpBottomNavigationColor)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel',
                                                  style: dialogTextColor)),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      gpBottomNavigationColor),
                                              onPressed: () {
                                                logoutHandler();
                                              },
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ))
                                        ],
                                      )
                                    ],
                                  );
                                });
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          )),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
