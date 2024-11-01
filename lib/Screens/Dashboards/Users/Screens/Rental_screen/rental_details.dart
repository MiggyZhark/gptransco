import 'package:flutter/material.dart';
import 'widgets/BottomRow.dart';
import 'widgets/ImageSlideshowContainer.dart';
import 'widgets/InformationSection.dart';
import 'widgets/RestrictionLocationSection.dart';

class RentalDetailsScreen extends StatelessWidget {
  final String driverName;
  final String price;
  final String location;
  final String stricted;

  const RentalDetailsScreen({
    super.key,
    required this.driverName,
    required this.price,
    required this.location,
    required this.stricted,
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
        title: Text(driverName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const ImageSlideshowContainer(),
            const SizedBox(height: 10),
            // Information section with sample data
            const InformationSection(
              driverName: 'John Doe',        // Sample data
              plateNumber: 'XYZ 1234',       // Sample data
              color: 'Red',                  // Sample data
              totalSeats: '4',               // Sample data
              fuelType: 'Diesel',            // Sample data
            ),
            const SizedBox(height: 10),
            RestrictionLocationSection(
              stricted: stricted,
              location: location,
            ),
            const Spacer(),
            BottomRow(price: price),
          ],
        ),
      ),
    );
  }
}