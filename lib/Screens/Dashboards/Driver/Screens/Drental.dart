import 'package:flutter/material.dart';

import '../../../../constants.dart';

class DRentalScreen extends StatelessWidget {
  const DRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            title: Text(
              'GPVan',
              style: headerTitle,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * 0.25,
                  width: MediaQuery.sizeOf(context).width * 1,
                  decoration: BoxDecoration(color: Colors.white),
                ),
                //child of content should be 3 images that in a slider
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 1,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [Align(alignment: Alignment.topLeft,child: Text('Vehicle Information'))],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15,)
              ],
            ),
          )),
    );
  }
}
