import 'package:flutter/material.dart';
import '../../../../constants.dart';

class Passengers extends StatelessWidget {
  const Passengers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Passengers',
          style: headerTitle,
        ),
      ),
      body: Center(
        child: Text('No Passenger Yet'),
      ),
    );
  }
}
