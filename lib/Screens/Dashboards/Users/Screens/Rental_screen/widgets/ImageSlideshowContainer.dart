import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class ImageSlideshowContainer extends StatelessWidget {
  final List<String> imageUrls;

  const ImageSlideshowContainer({super.key, required this.imageUrls});

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
            children: imageUrls
                .map((url) => Image.network(url, fit: BoxFit.cover))
                .toList(),
          ),
        ],
      ),
    );
  }
}