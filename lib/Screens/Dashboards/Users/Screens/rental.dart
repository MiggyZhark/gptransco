import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../components/chathub.dart';
import 'Rental_screen/car_info_card.dart';

class RentalScreen extends StatelessWidget {
  const RentalScreen({super.key});

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
                // First row: Search bar and Chat button
                Row(
                  children: [
                    // Search bar
                    Expanded(
                      flex: 3,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 15),
                          hintText: 'Search',
                          filled: true,
                          fillColor: Colors.teal[500],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style:
                        const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Chat Icon button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const ChatHub()));
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

                // Second row: Sort button and Pending button
                Row(
                  children: [
                    // Sort button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Sort action here
                      },
                      icon: const Icon(Icons.sort, color: Colors.white),
                      label: const Text('Sort',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pending button
                    ElevatedButton(
                      onPressed: () {
                        // Pending action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text('Pendings',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Rental Contents
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

                  // Scrollable container for car info
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: 10, // Change this to the number of available rentals
                      itemBuilder: (context, index) {
                        return CarInfoCard(
                          driverName: 'Driver ${index + 1}',
                          seats: '${4 + index} seats',
                          price: '₱${1000 + index * 5}', // Sample price
                          isAvailable: index % 2 == 0, // Example: alternating availability
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
