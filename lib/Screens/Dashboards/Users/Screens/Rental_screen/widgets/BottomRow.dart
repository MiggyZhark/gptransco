import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../components/message_screen.dart';

class BottomRow extends StatelessWidget {
  final String price;
  final String uid;

  const BottomRow({
    super.key,
    required this.price,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            if (currentUserUid != null) {
              // Navigate to MessageScreen with both current and receiver UIDs
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageScreen(
                    senderUid: currentUserUid,
                    receiverUid: uid, profileImage: '', name: '',
                  ),
                ),
              );
            } else {
              // Handle case where user is not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User not logged in')),
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const Text(
                'Message Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
