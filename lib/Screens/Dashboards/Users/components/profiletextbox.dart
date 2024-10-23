import 'package:flutter/material.dart';
import '../../../../constants.dart';

class ProfileTextBox extends StatelessWidget {
  final String? contentText;

  const ProfileTextBox({
    super.key,
    required this.contentText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text(
            contentText!,
            style: const TextStyle(fontSize: 12, color: Color.fromARGB(160, 0, 0, 0)),
          ),
        ],
      ),
    );
  }
}

class ProfileTextLabel extends StatelessWidget {
  final String? labelText;

  const ProfileTextLabel({super.key, required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, bottom: 8, top: 20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          labelText!,
          style: contentTextProfile,
        ),
      ),
    );
  }
}

