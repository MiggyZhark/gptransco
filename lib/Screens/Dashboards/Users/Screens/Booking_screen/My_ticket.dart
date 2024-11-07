import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Dashboards/Users/User_Dashboard.dart';

import '../../../../../constants.dart';

class MyTicket extends StatelessWidget {
  const MyTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Tickets',
            style: headerTitle,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF7D878E),
                                  Color(0xFF85949A),
                                  Color(0xFF7696A6)
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 14),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 70),
                            ),
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UserDashboard()),
                                      (route) => false);
                            },
                            child: const Text(
                              'Go To Home',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
