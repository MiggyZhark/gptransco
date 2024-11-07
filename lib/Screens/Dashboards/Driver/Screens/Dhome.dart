import 'package:flutter/material.dart';
import '../../../../constants.dart';

class DriverHomeScreen extends StatelessWidget {
  final Map<String, dynamic> userProfileData;

  const DriverHomeScreen({super.key, required this.userProfileData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'GPTransco',
            style: headerTitle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white),
              onPressed: () {
                // Handle notification button press here
              },
            ),
          ],
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
                          userProfileData['driverImage'].startsWith('http')
                              ? NetworkImage(userProfileData['driverImage'])
                              : AssetImage(userProfileData['driverImage'])
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
                              text: userProfileData['driverName'] ?? 'N/A',
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
                          Text(
                            'Total Reservations',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '15',
                            // Replace with dynamic count of `Passenger` subcollection
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900]),
                          ),
                        ],
                      ),
                      Icon(Icons.people, size: 30, color: Colors.blueGrey[400]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Notification List Section
                Text(
                  'Notifications',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                NotificationList(),

                const SizedBox(height: 20),

                // Reports Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.report, color: Colors.white),
                    label: Text('Lost & Found Report'),
                    onPressed: () {
                      // Handle report button press here
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
class NotificationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: List.generate(3, (index) {
          return ListTile(
            leading:
                Icon(Icons.notification_important, color: Colors.blueGrey[600]),
            title: Text('Notification Title $index'),
            subtitle: Text('This is a sample notification message.'),
            trailing: Text('2h ago',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          );
        }),
      ),
    );
  }
}
