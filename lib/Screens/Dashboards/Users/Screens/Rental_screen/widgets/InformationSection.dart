import 'package:flutter/material.dart';

class InformationSection extends StatelessWidget {
  final String driverName;
  final String plateNumber;
  final String color;
  final String totalSeats;
  final String fuelType;

  const InformationSection({
    super.key,
    required this.driverName,
    required this.plateNumber,
    required this.color,
    required this.totalSeats,
    required this.fuelType,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = 420.0; // Define your fixed max width here

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minWidth: constraints.maxWidth < maxWidth ? constraints.maxWidth : maxWidth,
            ),
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Vehicle Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Driver Name: $driverName', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('Plate Number: $plateNumber', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('Color: $color', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('Total Seats: $totalSeats', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 5),
                  Text('Fuel Type: $fuelType', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}