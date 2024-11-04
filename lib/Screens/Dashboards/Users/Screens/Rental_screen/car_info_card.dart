import 'package:flutter/material.dart';
import 'rental_details.dart';

class CarInfoCard extends StatelessWidget {
  final String driverName;
  final String seats;
  final String price;
  final bool isAvailable;
  final String driverImageUrl;
  final String plateNumber;
  final String color;
  final String fuelType;
  final String stricted;
  final String location;
  final List<String> imageUrls;
  final String uid;

  const CarInfoCard({
    required this.driverName,
    required this.seats,
    required this.price,
    required this.isAvailable,
    required this.driverImageUrl,
    required this.plateNumber,
    required this.color,
    required this.fuelType,
    required this.stricted,
    required this.location,
    required this.imageUrls,
    required this.uid,
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
          ClipOval(
            child: Image.network(
              driverImageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Name: $driverName',
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
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
                  const SizedBox(height: 3),
                  Text('Seats: $seats', style: const TextStyle(fontSize: 9)),
                  Text('Price: $price', style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RentalDetailsScreen(
                    driverName: driverName,
                    plateNumber: plateNumber,
                    color: color,
                    fuelType: fuelType,
                    totalSeats: seats,
                    stricted: stricted,
                    location: location,
                    price: price,
                    imageUrls: imageUrls,
                    uid: uid,
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
