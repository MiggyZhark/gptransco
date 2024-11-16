import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../constants.dart';

class DispatcherHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userProfileData;

  const DispatcherHomeScreen({super.key, required this.userProfileData});

  @override
  State<DispatcherHomeScreen> createState() => _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends State<DispatcherHomeScreen> {
  int gensanPackages = 0;
  int palimbangPackages = 0;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchPackageCounts();
    fetchNotifications();
  }

  // Fetch total package counts for Gensan and Palimbang
  Future<void> fetchPackageCounts() async {
    try {
      // Fetch packages count for Gensan
      final gensanSnapshot = await FirebaseFirestore.instance
          .collection('shippings')
          .doc('Gensan')
          .collection('packages')
          .get();
      gensanPackages = gensanSnapshot.docs.length;

      // Fetch packages count for Palimbang
      final palimbangSnapshot = await FirebaseFirestore.instance
          .collection('shippings')
          .doc('Palimbang')
          .collection('packages')
          .get();
      palimbangPackages = palimbangSnapshot.docs.length;

      setState(() {});
    } catch (e) {
      print('Error fetching package counts: $e');
    }
  }

  // Fetch notifications from Firestore
  Future<void> fetchNotifications() async {
    final address = widget.userProfileData['address'] ?? '';
    try {
      final notificationSnapshot = await FirebaseFirestore.instance
          .collection('shippings')
          .doc(address)
          .collection('notification')
          .orderBy('createdAt', descending: true)
          .get();

      // Map the documents to the notifications list
      notifications = notificationSnapshot.docs.map((doc) {
        final data = doc.data();
        final Timestamp? createdAt = data['createdAt'];
        final DateTime createdAtDateTime =
        createdAt != null ? createdAt.toDate() : DateTime.now();

        // Calculate the time ago string
        final timeAgo = calculateTimeAgo(createdAtDateTime);

        return {
          'title': data['Title'] ?? 'No Title',
          'message': data['message'] ?? 'No Message',
          'timeAgo': timeAgo,
        };
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  String calculateTimeAgo(DateTime createdAt) {
    final Duration difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    }
  }




  @override
  Widget build(BuildContext context) {
    final userName = widget.userProfileData['driverName'] ?? 'Dispatcher';
    final profileImage = widget.userProfileData['profileImageUrl'] ?? '';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('GPTransco', style: headerTitle),
          backgroundColor: gpBottomNavigationColorDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(userName, profileImage),
              const SizedBox(height: 20),
              // Quick Actions Section
              const Text(
                'Total Packages',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              // Notifications Section
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNotificationList(),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(String userName, String profileImage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: profileImage.isNotEmpty
                ? NetworkImage(profileImage)
                : null,
            backgroundColor: Colors.blueGrey,
            child: profileImage.isEmpty
                ? const Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Dispatcher', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Widget
  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.terminal,
          label: 'Gensan\n($gensanPackages)',
          color: Colors.green,
          onTap: () {},
        ),
        _buildActionButton(
          context,
          icon: Icons.terminal,
          label: 'Palimbang\n($palimbangPackages)',
          color: Colors.blue,
          onTap: () {},
        ),
      ],
    );
  }

  // Action Button
  Widget _buildActionButton(BuildContext context,
      {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.35,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Notifications List
  Widget _buildNotificationList() {
    if (notifications.isEmpty) {
      return const Center(
        child: Text('No notifications available.'),
      );
    }

    return Column(
      children: notifications.map((notification) {
        return Card(color: Colors.grey[100],
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: Text(notification['title'] ?? 'No Title'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification['message'] ?? 'No Message'),
                const SizedBox(height: 4),
                Text(
                  notification['timeAgo'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


}
