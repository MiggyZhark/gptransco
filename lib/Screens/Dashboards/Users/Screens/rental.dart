import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../constants.dart';
import '../chats/users_chathub.dart';
import 'Rental_screen/car_info_card.dart';

class RentalScreen extends StatefulWidget {
  const RentalScreen({super.key});

  @override
  _RentalScreenState createState() => _RentalScreenState();
}

class _RentalScreenState extends State<RentalScreen> {
  String searchQuery = "";

  Future<List<String>> _getVehicleImages(String driverId) async {
    // Fetch images from the Vehicle subcollection of the specific Driver document
    DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(driverId)
        .collection('Vehicle')
        .doc('Images')
        .get();

    if (vehicleDoc.exists && vehicleDoc.data() != null) {
      Map<String, dynamic> vehicleData =
          vehicleDoc.data() as Map<String, dynamic>;
      return List<String>.from(vehicleData['imageUrls'] ?? []);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gpBottomNavigationColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Rentals',
          style: headerTitle,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                          hintText: 'Search by driver name, location, price',
                          hintStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.teal[500],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UsersChatHub()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.message, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: gpPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Available for Rentals',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Driver')
                          .where('role', isEqualTo: 'Driver')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('No available rentals'),
                          );
                        }

                        final drivers = snapshot.data!.docs.where((driver) {
                          final driverName =
                              driver['driverName']?.toString().toLowerCase() ??
                                  '';
                          final location =
                              driver['address']?.toString().toLowerCase() ?? '';
                          final price =
                              driver['Price']?.toString().toLowerCase() ?? '';
                          return driverName.contains(searchQuery) ||
                              location.contains(searchQuery) ||
                              price.contains(searchQuery);
                        }).toList();

                        if (drivers.isEmpty) {
                          return const Center(
                            child: Text('No matching rentals found'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: drivers.length,
                          itemBuilder: (context, index) {
                            final driverData = drivers[index];
                            return FutureBuilder<List<String>>(
                              future: _getVehicleImages(driverData.id),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                return CarInfoCard(
                                  driverName:
                                      driverData['driverName'] ?? 'No Upload',
                                  seats: driverData['totalSeats'] != null
                                      ? '${driverData['totalSeats']} seats'
                                      : 'No Upload',
                                  price: driverData['Price'] != null
                                      ? '₱${driverData['Price']}'
                                      : 'No Upload',
                                  isAvailable:
                                      driverData['Availability'] ?? false,
                                  driverImageUrl:
                                      driverData['driverImage'] ?? '',
                                  plateNumber:
                                      driverData['plateNumber'] ?? 'N/A',
                                  color:
                                      driverData['vehicleColor'] ?? 'No Upload',
                                  fuelType:
                                      driverData['fuelType'] ?? 'No Upload',
                                  stricted:
                                      driverData['Stricted'] ?? 'No Upload',
                                  location:
                                      driverData['address'] ?? 'No Upload',
                                  imageUrls:
                                      imageSnapshot.data?.isNotEmpty == true
                                          ? imageSnapshot.data!
                                          : ['https://via.placeholder.com/150'],
                                  uid: driverData['uid'],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
