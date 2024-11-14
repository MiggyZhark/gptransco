import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import '../../../../constants.dart';
import 'Pticket.dart';

class Passengers extends StatelessWidget {
  const Passengers({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user's UID
    final String? currentUserUID = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUID == null) {
      // If no user is signed in, show an error message
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reservation',
            style: headerTitle,
          ),
        ),
        body: const Center(
          child: Text('No Driver signed in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation',
          style: headerTitle,
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Driver')
            .doc(currentUserUID)
            .collection('Passenger')
            .orderBy('createdAt', descending: true) // Sort by createdAt field
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching reservations'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reservations yet'));
          }

          // Extract 'ticketID' and 'createdAt' from each document
          List<Map<String, dynamic>> tickets = snapshot.data!.docs.map((doc) {
            return {
              'ticketID': doc['ticketID'] as String,
              'createdAt': doc['createdAt'] as Timestamp,
              'userUID': doc['userUID'] as String,
              'Receipt': doc['Receipt'] as String,
              'status': doc['status'] as String,
              'scheduledDate': doc['scheduledDate'] as Timestamp,
              'expirationDate': doc['expirationDate'] as Timestamp,
              'destination': doc['destination'] as String,
              'currentLocation': doc['currentLocation'] as String
            };
          }).toList();

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              // Format the 'createdAt' timestamp
              String formattedDate = DateFormat('MMMM dd, yyyy, hh:mm a')
                  .format(tickets[index]['createdAt'].toDate());

              return Card(
                color: Colors.grey[50],
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.teal,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    'Ticket ID: ${tickets[index]['ticketID']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Created At: $formattedDate'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info, color: Colors.blueGrey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PTicketsScreen(
                            userUID: tickets[index]['userUID'],
                            ticketID: tickets[index]['ticketID'],
                            receipt: tickets[index]['Receipt'],
                            scheduledDate: tickets[index]['scheduledDate'],
                            expirationDate: tickets[index]['expirationDate'],
                            destination: tickets[index]['destination'],
                            currentLocation: tickets[index]['currentLocation'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
