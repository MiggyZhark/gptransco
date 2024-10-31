import 'package:flutter/material.dart';

import '../../../../../constants.dart';

class MyTicket extends StatelessWidget {
  const MyTicket({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Tickets',
            style: headerTitle,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
