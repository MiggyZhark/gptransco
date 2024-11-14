import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../constants.dart';
import 'ticket_details.dart';

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
                  ticketData: ticketData,
                  ticketID: tickets[index].id,
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
  final Map<String, dynamic> ticketData;
  final String ticketID;

  const TicketCard({
    super.key,
    required this.ticketData,
    required this.ticketID,
  });

  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.blue[50],
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
              'Ticket ID: ${ticketData['ticketID'] ?? 'N/A'}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info,color: Colors.blue,),
                const SizedBox(width: 5,),
                Text('Status: ${ticketData['status'] ?? 'N/A'}',style: const TextStyle(fontSize: 14,color: Colors.blue),),
              ],
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetails(ticketData: ticketData),
                    ),
                  );
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
