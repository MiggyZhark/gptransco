import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'homecard_slider.dart';

class VanPage extends StatelessWidget {
  final CardItem item;

  const VanPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            item.title,
            style: headerTitle,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: AspectRatio(aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    item.urlImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
                child: Container(
              width: MediaQuery.of(context).size.width * 1,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
                  child: Column(children: [
                    SizedBox(height: 8,),
                    Text('Description',style: TextStyle(fontSize: 14),),

                  ],),
            ))
          ],
        ),
      );
}
