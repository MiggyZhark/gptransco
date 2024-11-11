import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants.dart';
import 'LNF_Screen.dart';



class DriverHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userProfileData;
  final int totalReservations;

  const DriverHomeScreen({super.key, required this.userProfileData,required this.totalReservations});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  // Method to delete all notifications
  Future<void> deleteAllNotifications() async {
    if (currentUser == null) return;

    final notificationRef = FirebaseFirestore.instance
        .collection('Driver')
        .doc(currentUser!.uid)
        .collection('Notification');

    // Get all notifications and delete them
    final snapshot = await notificationRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {}); // Refresh the UI after deletion
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'GPTransco',
            style: headerTitle,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header with Profile Picture
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          widget.userProfileData['driverImage'].startsWith('http')
                              ? NetworkImage(widget.userProfileData['driverImage'])
                              : AssetImage(widget.userProfileData['driverImage'])
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'Hi, ',
                              style: TextStyle(fontSize: 14),
                            ),
                            TextSpan(
                              text: widget.userProfileData['driverName'] ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(
                              text: '\nWelcome!',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Total Reservations Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Reservations'),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.totalReservations}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      Icon(Icons.people, size: 30, color: Colors.blueGrey[400]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Notification List Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    IconButton(
                        onPressed: () async{
                          await deleteAllNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All notifications cleared')),
                          );
                        },
                        icon: const Icon(
                          size: 25,
                          Icons.clear_all,
                          color: Colors.black,
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                const NotificationList(),

                const SizedBox(height: 20),

                // Reports Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.report, color: Colors.white),
                    label: const Text(
                      'Lost & Found Report',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LNFScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy notification list for demonstration purposes
class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    if (currentUser == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(currentUser!.uid)
        .collection('Notification')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id, // Include document ID for deletion if needed
    }).toList();
  }

  String getTimeDifference(Timestamp timestamp) {
    final createdAt = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MM/dd/yyyy').format(createdAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading notifications'));
        } else if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications available'));
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final title = notification['Title'] ?? 'No Title';
            final message = notification['message'] ?? 'No Message';
            final createdAt = notification['createdAt'] as Timestamp?;

            return ListTile(
              leading: Icon(Icons.notification_important, color: Colors.blueGrey[600]),
              title: Text(title),
              subtitle: Text(message),
              trailing: createdAt != null
                  ? Text(
                getTimeDifference(createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
                  : const SizedBox(),
            );
          },
        );
      },
    );
  }
}

