import 'package:flutter/material.dart';

import 'rental_details.dart';

class CarInfoCard extends StatelessWidget {
  final String driverName;
  final String seats;
  final String price;
  final bool isAvailable; // New parameter to indicate availability

  const CarInfoCard({
    required this.driverName,
    required this.seats,
    required this.price,
    required this.isAvailable, // Add this parameter to constructor
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            color: Colors.teal, // Placeholder for car image or icon
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Driver Name: $driverName',
                        style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 5),
                    // Status Dot
                    Icon(
                      Icons.circle,
                      color: isAvailable ? Colors.green : Colors.grey,
                      size: 9,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        fontSize: 10,
                        color: isAvailable ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text('Seats: $seats', style: const TextStyle(fontSize: 9)),
                Text('Price: $price', style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalDetailsScreen(
                    driverName: driverName,
                    price: price,
                    location: 'Sample Location', // Replace with actual location
                    stricted:
                        'Sample Stricted', // Replace with actual stricted information
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_circle_right, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}