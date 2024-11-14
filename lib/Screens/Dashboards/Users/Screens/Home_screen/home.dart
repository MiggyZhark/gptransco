import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'Notification_screen.dart';
import 'homecard_slider.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userProfileData;
  const HomeScreen({super.key,required this.userProfileData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: (userProfileData['profileImageUrl'] != null &&
                        userProfileData['profileImageUrl'].startsWith('http'))
                        ? NetworkImage(userProfileData['profileImageUrl'])
                        : null,
                    child: (userProfileData['profileImageUrl'] == null ||
                        !userProfileData['profileImageUrl'].startsWith('http'))
                        ? const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    )
                        : null,
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
                          text: userProfileData['name'] ?? 'N/A',
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
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userProfileData['uid'])
                    .collection('Notification')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Icon(Icons.notifications, color: Colors.black87, size: 28);
                  }

                  int notificationCount = 0;
                  if (snapshot.hasData) {
                    notificationCount = snapshot.data!.docs.length;
                  }

                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(
                                userId: userProfileData['uid'],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications, color: Colors.black87, size: 28),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
        body: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16,top: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 1,
                  height: MediaQuery.sizeOf(context).height * 0.22,
                  decoration: BoxDecoration(
                      color: gpBottomNavigationColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 20, left: 20, top: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Text(
                                'Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              children: [
                                Text(
                                  'Price: N/A',
                                  style: textBoxStyle,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Date: N/A',
                                  style: textBoxStyle,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Destination: N/A',
                                  style: textBoxStyle,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(12),
                                    height: MediaQuery.sizeOf(context).height *
                                        0.12,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.28,
                                    decoration: BoxDecoration(
                                        color: gpBottomNavigationColorDark,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Image.asset(
                                      'assets/models/package.png',
                                      width: 150,
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 30, top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'N/A',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Text(
                          'Available Rentals',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                        )),
                  ],
                ),
                HomeCardSlider(userProfileData: userProfileData,),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          TextButton(onPressed: () {
                          }, child: const Text('More Info')),
                    ),
                  ],
                ),
                ClipRRect(borderRadius:BorderRadius.circular(15),child: Image.asset('assets/images/Map.png'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
