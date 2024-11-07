import 'package:flutter/material.dart';
import 'homecard_slider.dart';

class VanPage extends StatelessWidget {
  final CardItem item;

  const VanPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: AspectRatio(
              aspectRatio: 6 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image(
                  image: item.urlImage.startsWith('http')
                      ? NetworkImage(
                          item.urlImage) // Load network image if URL is valid
                      : AssetImage(item.urlImage),
                  // Load asset image if URL is local path
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

        ],
      ),
    );
  }
}
