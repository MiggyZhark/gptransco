import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Dashboards/Users/Screens/Home_screen/vanpage.dart';

class CardItem {
  final String urlImage;
  final String title;
  final String subtitle;
  final String plateNumber;
  final String fuelType;
  final String address;
  final String mobileNumber;
  final String uid;
  final String senderUid;
  final String senderProfile;

  const CardItem(
      {required this.urlImage,
      required this.title,
      required this.subtitle,
      required this.plateNumber,
      required this.fuelType,
      required this.address,
      required this.mobileNumber,
      required this.uid,
      required this.senderUid,
      required this.senderProfile});
}

class HomeCardSlider extends StatefulWidget {
  final Map<String, dynamic> userProfileData;

  const HomeCardSlider({super.key, required this.userProfileData});

  @override
  State<HomeCardSlider> createState() => _HomeCardSliderState();
}

class _HomeCardSliderState extends State<HomeCardSlider> {
  List<CardItem> items = [];
  final CollectionReference driversCollection =
      FirebaseFirestore.instance.collection('Driver');

  @override
  void initState() {
    super.initState();
    fetchDriverData();
  }

  Future<void> fetchDriverData() async {
    try {
      // Fetch only documents with role 'Driver' and Availability set to true
      QuerySnapshot driverSnapshot = await driversCollection
          .where('role', isEqualTo: 'Driver')
          .where('Availability', isEqualTo: true)
          .get();

      for (var driverDoc in driverSnapshot.docs) {
        final driverData = driverDoc.data() as Map<String, dynamic>;
        final driverName = driverData['driverName'] ?? 'Unknown Driver';
        final price = driverData['Price'] ?? 'N/A';
        final plateNumber = driverData['plateNumber'] ?? 'N/A';
        final fuelType = driverData['fuelType'] ?? 'N/A';
        final address = driverData['address'] ?? 'N/A';
        final mobileNumber = driverData['mobileNumber'] ?? 'N/A';
        final uid = driverData['uid'] ?? '';

        // Access the 'Vehicle' subcollection to get the first image
        final vehicleCollection =
            driversCollection.doc(driverDoc.id).collection('Vehicle');

        QuerySnapshot vehicleSnapshot = await vehicleCollection.limit(1).get();
        String firstImageUrl =
            'assets/images/van_example.png'; // Default asset image

        if (vehicleSnapshot.docs.isNotEmpty) {
          final vehicleData =
              vehicleSnapshot.docs.first.data() as Map<String, dynamic>;

          var imageUrlData = vehicleData['imageUrls'];
          if (imageUrlData is List && imageUrlData.isNotEmpty) {
            firstImageUrl = imageUrlData[0]; // Use the first URL from the list
          } else if (imageUrlData is String) {
            firstImageUrl =
                imageUrlData; // Use the single string URL if present
          }
        }

        // Create a CardItem using the fetched data
        setState(() {
          items.add(CardItem(
            urlImage: firstImageUrl,
            title: driverName,
            subtitle: '₱$price',
            plateNumber: plateNumber,
            fuelType: fuelType,
            address: address,
            mobileNumber: '+63-$mobileNumber',
            uid: uid,
            senderUid: widget.userProfileData['uid'],
            senderProfile: widget.userProfileData['profileImageUrl'],
          ));
        });
      }
    } catch (e) {
      print('Error fetching driver data: $e');
    }
  }

  void _openBottomSheet(CardItem item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => VanPage(item: item)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => buildCard(item: items[index]),
      ),
    );
  }

  Widget buildCard({required CardItem item}) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Material(
                  child: Ink.image(
                    image: item.urlImage.startsWith('http')
                        ? NetworkImage(
                            item.urlImage) // Use network image if valid URL
                        : AssetImage(item.urlImage) as ImageProvider,
                    // Fallback to asset image
                    fit: BoxFit.cover,
                    child: InkWell(onTap: () {
                      _openBottomSheet(item);
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            item.subtitle,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
