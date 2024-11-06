import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import '../../../components/profiletextbox.dart';
import 'homecard_slider.dart';

class VanPage extends StatelessWidget {
  final CardItem item;

  const VanPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.teal,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Text(
              item.title,
              style: headerTitle,
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: AspectRatio(
                  aspectRatio: 5 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                      image: item.urlImage.startsWith('http')
                          ? NetworkImage(item
                              .urlImage) // Load network image if URL is valid
                          : AssetImage(item.urlImage),
                      // Load asset image if URL is local path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Information',
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ProfileTextLabel(labelText: 'Plate No.',),
                            ProfileTextLabel(labelText: 'FuelType',),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
