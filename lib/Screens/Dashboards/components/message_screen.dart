import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constants.dart';

class MessageScreen extends StatefulWidget {
  final String receiverUid;
  final String senderUid;
  final String profileImage;
  final String name;

  const MessageScreen(
      {super.key,
      required this.receiverUid,
      required this.senderUid,
      required this.profileImage,
      required this.name});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late ChatUser currentUser;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _fetchMessages();
  }

  void _initializeChat() {
    final user = FirebaseAuth.instance.currentUser!;
    currentUser = ChatUser(
      id: user.uid,
      firstName: user.displayName ?? "User",
      profileImage: widget.profileImage,
    );
  }

  Future<void> _fetchMessages() async {
    final chatId = _getChatId(widget.senderUid, widget.receiverUid);
    FirebaseFirestore.instance
        .collection('ChatHub')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return ChatMessage(
            text: data['text'] as String,
            user: ChatUser(
                profileImage: data['profileUrl'], id: data['userId'] as String),
            createdAt: (data['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
      });
    });
  }

  void _onSend(ChatMessage message) async {
    final chatId = _getChatId(widget.senderUid, widget.receiverUid);
    final messageData = {
      'text': message.text,
      'userId': currentUser.id,
      'createdAt': FieldValue.serverTimestamp(),
      'profileUrl': widget.profileImage,
    };

    // Add message to Firestore
    await FirebaseFirestore.instance
        .collection('ChatHub')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Add participants if this is the first message
    final chatDoc =
        FirebaseFirestore.instance.collection('ChatHub').doc(chatId);
    chatDoc.get().then((doc) {
      if (!doc.exists) {
        chatDoc.set({
          'Participants': [widget.senderUid, widget.receiverUid],
        });
      }
    });
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.name,
            style: headerTitle,
          ),
          backgroundColor: Colors.teal,
        ),
        body: DashChat(
          currentUser: currentUser,
          onSend: _onSend,
          messages: messages,
        ),
      ),
    );
  }
}
