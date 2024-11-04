import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../constants.dart';
import '../../components/message_screen.dart';

class UsersChatHub extends StatelessWidget {
  const UsersChatHub({super.key});

  // Function to get the current user's profile image URL
  Future<String?> getCurrentUserProfileImageUrl() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (userDoc.exists) {
      return userDoc.data()?['profileImageUrl'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats', style: headerTitle),
          backgroundColor: Colors.teal,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('ChatHub').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter chats to show only those where the current user is a participant
            final userChats = snapshot.data!.docs.where((doc) {
              final participants = List<String>.from(doc['Participants']);
              return participants.contains(currentUserUid);
            });

            // Display "No messages yet" if there are no chats
            if (userChats.isEmpty) {
              return const Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return FutureBuilder<String?>(
              future: getCurrentUserProfileImageUrl(),
              builder: (context, profileSnapshot) {
                final currentUserProfileImage = profileSnapshot.data ?? '';

                return ListView(
                  children: userChats.map((doc) {
                    final receiverUid = doc['Participants'].firstWhere((uid) => uid != currentUserUid);

                    // Use a StreamBuilder to listen to changes in the user's profile data
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('Driver').doc(receiverUid).snapshots(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return ListTile(
                            title: const Text('Loading...'),
                            leading: const CircleAvatar(
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                          );
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        final driverImage = userData['driverImage'] ?? '';
                        final driverName = userData['driverName'] ?? 'Chat';

                        return ListTile(
                          leading: driverImage.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(driverImage))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(driverName),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                  receiverUid: receiverUid,
                                  senderUid: currentUserUid,
                                  profileImage: currentUserProfileImage,
                                  name: driverName,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
