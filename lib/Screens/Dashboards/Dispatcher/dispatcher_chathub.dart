import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../constants.dart';
import '../components/message_screen.dart';

class DispatcherChatHub extends StatelessWidget {
  const DispatcherChatHub({super.key});

  // Function to get the current user's profile image URL
  Future<String?> getCurrentUserProfileImageUrl() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('Driver').doc(currentUserUid).get();

    if (userDoc.exists) {
      return userDoc.data()?['driverImage'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GPCrew', style: headerTitle),
          backgroundColor: gpBottomNavigationColorDark,
        ),
        body: FutureBuilder<String?>(
          future: getCurrentUserProfileImageUrl(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!profileSnapshot.hasData) {
              return const Center(
                child: Text('Failed to load profile image'),
              );
            }

            final currentUserProfileImage = profileSnapshot.data ?? '';

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Driver').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No drivers available',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                }

                final drivers = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driverDoc = drivers[index];
                    final driverData = driverDoc.data() as Map<String, dynamic>;
                    final driverUid = driverDoc.id;
                    final driverImage = driverData['driverImage'] ?? '';
                    final driverName = driverData['driverName'] ?? 'Driver';
                    final role = driverData['role'] ?? 'N/A';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: driverImage.isNotEmpty
                                ? Image.network(
                              driverImage,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
                                  child: Icon(Icons.person, color: Colors.white, size: 30),
                                );
                              },
                            )
                                : const CircleAvatar(
                              backgroundColor: Colors.blueGrey,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                          ),
                          title: Text(
                            driverName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'Tap to message $role',
                            style: const TextStyle(color: Colors.grey,fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                  receiverUid: driverUid,
                                  senderUid: currentUserUid,
                                  profileImage: currentUserProfileImage,
                                  name: driverName,
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
            );
          },
        ),
      ),
    );
  }
}
