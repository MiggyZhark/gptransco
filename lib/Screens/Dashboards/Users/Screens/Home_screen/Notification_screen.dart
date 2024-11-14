import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../../../constants.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  const NotificationScreen({super.key, required this.userId});

  Future<void> clearAllNotifications() async {
    final notificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Notification');

    // Fetch all documents in the Notification subcollection
    final snapshot = await notificationsRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete(); // Delete each document
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications',style: headerTitle,),
          backgroundColor: gpSecondaryColor,
          actions: [
            IconButton(
              onPressed: () async {
                await clearAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications cleared')),
                );
              },
              icon: const Icon(Icons.clear_all, color: Colors.white),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('Notification')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching notifications'));
            }
      
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No notifications available'));
            }
      
            final notifications = snapshot.data!.docs;
      
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final title = notification['Title'] ?? 'No Title';
                final message = notification['message'] ?? 'No Message';
                final ticketID = notification['ticketID'] ?? 'No Ticket ID';
                final createdAt = (notification['createdAt'] as Timestamp?)?.toDate();
                final formattedDate = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                    : 'No Date';
      
                return Card(color: Colors.blue[50],
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ticket ID: $ticketID',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
