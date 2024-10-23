import 'package:flutter/material.dart';

import '../../../../constants.dart';

class ShippingImage extends StatelessWidget {
  const ShippingImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding:EdgeInsets.only(bottom: 15,left: 15,right: 15),
      child: Container(
        height: MediaQuery.sizeOf(context).height / 3.7, // Adjust height and width to your needs
        width: double.infinity,
        decoration: BoxDecoration(
          color: gpPrimaryColor, // Placeholder color
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 40,
              color: Colors.grey[700], // Icon color
            ),
            const SizedBox(height: 10),
            Text(
              'Add Image',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
