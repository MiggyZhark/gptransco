import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import 'Book_Ticket.dart';
import 'My_ticket.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Select Current Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Gensan'),
                onTap: () {
                  setState(() {
                    currentLocation = 'Gensan'; // Update selected location
                  });
                  Navigator.of(context).pop(); // Close dialog
                },
              ),
              ListTile(
                title: const Text('Palimbang'),
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
  // Function to show Select Destination dialog
  void showDestinationDialog(BuildContext context) {
    // List of all possible destinations
    List<String> destinations = [
      'Gensan',
      'Palimbang',
      'Maasim',
      'Maitum',
      'Kiamba'
    ];

    // Filter out the currentLocation from the list of destinations
    List<String> filteredDestinations = destinations
        .where((destination) => destination != currentLocation)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Destination'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: filteredDestinations.map((destination) {
              return ListTile(
                title: Text(destination),
                onTap: () {
                  setState(() {
                    this.destination = destination;
                  });
                  Navigator.of(context).pop(); // Close dialog
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                      height: MediaQuery.sizeOf(context).height * 0.25,
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
                      padding: const EdgeInsets.all(25),
                      child: Container(
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(90, 17, 117, 103),
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, top: 20, bottom: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () => showCurrentLocationDialog(context),
                                child: Row(
                                  children: [
                                    const ImageIcon(
                                        size: 30,
                                        color: gpIconColor,
                                        AssetImage(
                                            'assets/models/map-marker-home.png')),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      currentLocation,
                                      style: const TextStyle(shadows: [
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
                              const SizedBox(
                                height: 20,
                              ),
                              const Divider(
                                indent: 30,
                                height: 5,
                                color: Colors.black,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InkWell(
                                onTap: () => showDestinationDialog(context),
                                child: Row(
                                  children: [
                                    const ImageIcon(
                                        size: 30,
                                        color: gpIconColor,
                                        AssetImage('assets/models/marker.png')),
                                    const SizedBox(
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
                      padding: const EdgeInsets.only(top: 10.0),
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
                                    textStyle: const TextStyle(fontSize: 14),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 70),
                                  ),
                                  onPressed: () {
                                    if (currentLocation != 'Current Location' &&
                                        destination != 'Select Destination') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BookTicket(
                                              currentLocation: currentLocation,
                                              destination: destination,
                                            ),
                                          ),
                                        );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please select a Location & Destination')),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
                                        Color(0xFF7D878E),
                                        Color(0xFF85949A),
                                        Color(0xFF7696A6)
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
                                    textStyle: const TextStyle(fontSize: 14),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 70),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MyTicket()));
                                  },
                                  child: const Text(
                                    'My Tickets',
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
      ),
    );
  }
}
