import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../constants.dart';
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
                  CircleAvatar(backgroundColor: Colors.white,
                    backgroundImage: userProfileData['profileImageUrl'].startsWith('http')
                        ? NetworkImage(userProfileData['profileImageUrl'])
                        : AssetImage(userProfileData['profileImageUrl']) as ImageProvider,
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
              IconButton(
                onPressed: () {
                  // Handle notification press
                },
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.black87,
                  size: 28,
                ),
              )
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
