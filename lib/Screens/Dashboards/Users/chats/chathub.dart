import 'package:flutter/material.dart';
import '../../../../constants.dart';

class ChatHub extends StatelessWidget {
  const ChatHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true,
        title: const Text('Chats',style: headerTitle,),
        backgroundColor: gpBottomNavigationColorDark,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(prefixIcon: Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 15),
                hintText: 'Search',
                filled: true,
                fillColor: Colors.grey[400],
                // Adjust color as per your UI
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style:
              const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        Divider(height: 5,indent: 40,endIndent: 40,),
        //Temporary
        SizedBox(height: 50,),
        Center(child: Text('No Message Yet'),)
      ],),
    );
  }
}
