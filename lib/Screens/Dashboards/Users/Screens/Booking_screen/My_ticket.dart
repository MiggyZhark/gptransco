import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../constants.dart';

class MyTicket extends StatelessWidget {
  const MyTicket({super.key});

  // Function to get the current user's UID
  String? getCurrentUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final userUID = getCurrentUserUID();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Ticket',
            style: headerTitle,
          ),
        ),
        body: userUID != null
            ? StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userUID)
              .collection('my_ticket')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No tickets found.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final tickets = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticketData = tickets[index].data() as Map<String, dynamic>;
                return TicketCard(
                  currentLocation: ticketData['currentLocation'] ?? 'N/A',
                  destination: ticketData['destination'] ?? 'N/A',
                  ticketID: ticketData['ticketID'] ?? 'N/A',
                  plateNumber: ticketData['plateNumber'] ?? 'N/A',
                  createdAt: (ticketData['createdAt'] as Timestamp?)?.toDate(),
                );
              },
            );
          },
        )
            : const Center(
          child: Text('Please log in to view your tickets.'),
        ),
      ),
    );
  }
}

class TicketCard extends StatelessWidget {
  final String currentLocation;
  final String destination;
  final String ticketID;
  final String plateNumber;
  final DateTime? createdAt;

  const TicketCard({
    super.key,
    required this.currentLocation,
    required this.destination,
    required this.ticketID,
    required this.plateNumber,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket ID: $ticketID',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('From: $currentLocation'),
                    Text('To: $destination'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plate No: $plateNumber'),
                    Text(
                      'Date: ${createdAt != null ? "${createdAt!.day}/${createdAt!.month}/${createdAt!.year}" : 'N/A'}',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implement any action, e.g., showing more details or navigating to another page
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
