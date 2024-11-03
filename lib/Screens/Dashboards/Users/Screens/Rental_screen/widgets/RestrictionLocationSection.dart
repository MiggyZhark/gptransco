import 'package:flutter/material.dart';

class RestrictionLocationSection extends StatelessWidget {
  final String stricted;
  final String location;

  const RestrictionLocationSection({
    super.key,
    required this.stricted,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                const Text('Stricted', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(stricted, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(location, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}