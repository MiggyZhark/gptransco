import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../chats/chathub.dart';

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
                          // Adjust color as per your UI
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
                        backgroundColor: Colors.teal[600], // Adjust color
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
                        backgroundColor: Colors.teal[600], // Adjust color
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
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(
                color: gpPrimaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45))),
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Text('Available for Rentals',style: TextStyle(fontSize: 14),)
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
