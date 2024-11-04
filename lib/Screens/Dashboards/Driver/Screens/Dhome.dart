import 'package:flutter/material.dart';
import '../../../../constants.dart';

class DriverHomeScreen extends StatelessWidget {
  final Map<String, dynamic> userProfileData;
  const DriverHomeScreen({super.key,required this.userProfileData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('GPTransco',style: headerTitle,),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white,
                    backgroundImage: userProfileData['driverImage'].startsWith('http')
                        ? NetworkImage(userProfileData['driverImage'])
                        : AssetImage(userProfileData['driverImage']) as ImageProvider,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black, // Use gpSecondaryColor if it's defined elsewhere
                        fontSize: 18,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Hi, ',
                          style: TextStyle(fontSize: 14), // Apply `textHeaderStyle` if defined
                        ),
                        TextSpan(
                          text: userProfileData['driverName'] ?? 'N/A',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const TextSpan(
                          text: '\nWelcome!',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  // Handle notification press
                },
                icon: const Icon(
                  Icons.clear_all,
                  color: Colors.black87,
                  size: 28,
                ),
              )
            ],
          ),
        ),
      ],)
    ));
  }
}
