import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'Book_Ticket.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // State variables to hold selected values
  String currentLocation = 'Current Location';
  String destination = 'Select Destination';

  // Function to show Current Location dialog
  void showCurrentLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Current Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Gensan'),
                onTap: () {
                  setState(() {
                    currentLocation = 'Gensan'; // Update selected location
                  });
                  Navigator.of(context).pop(); // Close dialog
                },
              ),
              ListTile(
                title: Text('Palimbang'),
                onTap: () {
                  setState(() {
                    currentLocation = 'Palimbang';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show Select Destination dialog
  void showDestinationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Destination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Gensan'),
                onTap: () {
                  setState(() {
                    destination = 'Gensan';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Palimbang'),
                onTap: () {
                  setState(() {
                    destination = 'Palimbang';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Maasim'),
                onTap: () {
                  setState(() {
                    destination = 'Maasim';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Maitum'),
                onTap: () {
                  setState(() {
                    destination = 'Maitum';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Kiamba'),
                onTap: () {
                  setState(() {
                    destination = 'Kiamba';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gpBottomNavigationColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Booking',
          style: headerTitle,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  child: Image.asset(
                    'assets/images/Van-driver.png',
                    height: MediaQuery.sizeOf(context).height * 0.27,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(
                color: gpPrimaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: Container(
                      height: MediaQuery.sizeOf(context).height * 0.2,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(90, 17, 117, 103),
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: EdgeInsets.only(left: 30, top: 20, bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => showCurrentLocationDialog(context),
                              child: Row(
                                children: [
                                  ImageIcon(
                                      size: 30,
                                      color: gpIconColor,
                                      AssetImage(
                                          'assets/models/map-marker-home.png')),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    currentLocation,
                                    style: TextStyle(shadows: [
                                      BoxShadow(
                                        color: Colors.teal,
                                        blurRadius: 3.0,
                                        spreadRadius: 6.0,
                                      ),
                                    ]),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(
                              indent: 30,
                              height: 5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () => showDestinationDialog(context),
                              child: Row(
                                children: [
                                  ImageIcon(
                                      size: 30,
                                      color: gpIconColor,
                                      AssetImage('assets/models/marker.png')),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(destination)
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color(0xFF07917C),
                                      Color(0xFF0CB39B),
                                      Color(0xFF06BAA4)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 70),
                                ),
                                onPressed: () {
                                  if (currentLocation != 'Current Location' &&
                                      destination != 'Select Destination'){
                                    if(currentLocation != destination){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookTicket(
                                            currentLocation: currentLocation,
                                            destination: destination,
                                          ),
                                        ),
                                      );
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Location & Destination should not be match')),
                                      );
                                    }
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please select a Location & Destination')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Get Reservation',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
