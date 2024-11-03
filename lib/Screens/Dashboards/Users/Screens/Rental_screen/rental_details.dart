import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.teal),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(driverName, style: headerTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
              SizedBox(height: 20,),
              BottomRow(price: price, uid: uid,),
            ],
          ),
        ),
      ),
    );
  }
}
