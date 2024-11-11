import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../constants.dart';
import 'widgets/BottomRow.dart';
import 'widgets/ImageSlideshowContainer.dart';
import 'widgets/InformationSection.dart';
import 'widgets/RestrictionLocationSection.dart';

class RentalDetailsScreen extends StatelessWidget {
  final String driverName;
  final String price;
  final String location;
  final String stricted;
  final String plateNumber;
  final String color;
  final String totalSeats;
  final String fuelType;
  final List<String> imageUrls;
  final String uid;

  const RentalDetailsScreen({
    super.key,
    required this.driverName,
    required this.price,
    required this.location,
    required this.stricted,
    required this.plateNumber,
    required this.color,
    required this.totalSeats,
    required this.fuelType,
    required this.imageUrls,
    required this.uid,
  });

  // Function to get the current user's profile image URL
  Future<String?> getCurrentUserProfileImageUrl() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (userDoc.exists) {
      return userDoc.data()?['profileImageUrl'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(driverName, style: headerTitle),
          centerTitle: true,
          backgroundColor: gpSecondaryColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ImageSlideshowContainer(imageUrls: imageUrls),
                const SizedBox(height: 10),
                InformationSection(
                  driverName: driverName,
                  plateNumber: plateNumber,
                  color: color,
                  totalSeats: totalSeats,
                  fuelType: fuelType,
                ),
                const SizedBox(height: 10),
                RestrictionLocationSection(
                  stricted: stricted,
                  location: location,
                ),
                const SizedBox(height: 20),
                FutureBuilder<String?>(
                  future: getCurrentUserProfileImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final profileImage = snapshot.data ?? '';

                    return BottomRow(
                      price: price,
                      uid: uid,
                      driverName: driverName,
                      profileImage: profileImage,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
