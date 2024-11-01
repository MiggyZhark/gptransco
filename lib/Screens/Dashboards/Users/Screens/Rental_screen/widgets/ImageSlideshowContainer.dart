import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class ImageSlideshowContainer extends StatelessWidget {
  const ImageSlideshowContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImageSlideshow(
            width: double.infinity,
            height: 250,
            initialPage: 0,
            indicatorColor: Colors.teal,
            autoPlayInterval: 3000,
            isLoop: true,
            children: [
              Image.network('https://via.placeholder.com/150', fit: BoxFit.cover),
              Image.network('https://via.placeholder.com/150', fit: BoxFit.cover),
              Image.network('https://via.placeholder.com/150', fit: BoxFit.cover),
            ],
          ),
        ],
      ),
    );
  }
}
