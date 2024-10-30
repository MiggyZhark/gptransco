import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookTicket extends StatefulWidget {
  final String currentLocation;
  final String destination;

  const BookTicket({
    super.key,
    required this.currentLocation,
    required this.destination,
  });

  @override
  _BookTicketState createState() => _BookTicketState();
}

class _BookTicketState extends State<BookTicket> {
  int _currentStep = 0;
  String driverPlateNo = "";
  String assignedDriverID = "";
  int driverSeats = 0;
  bool isDriverLoaded = false;  // Flag to check if driver is already loaded

  // Fetch an available driver (Seats > 0) only if not already loaded
  Future<void> getAvailableDriver() async {
    if (isDriverLoaded) return;  // Skip if driver is already loaded

    final driverQuery = await FirebaseFirestore.instance
        .collection('Driver')
        .where('Seats', isGreaterThan: 0)
        .orderBy('Seats', descending: true)
        .limit(1)
        .get();

    if (driverQuery.docs.isNotEmpty) {
      final driver = driverQuery.docs.first;
      setState(() {
        driverPlateNo = driver['PlateNo'];
        assignedDriverID = driver.id;
        driverSeats = driver['Seats'];
        isDriverLoaded = true;  // Set to true after loading the driver
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available drivers. Please try again later.')),
      );
    }
  }

  // Decrement the seat count for the assigned driver in Firebase
  Future<void> decrementDriverSeatCount() async {
    if (assignedDriverID.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Driver').doc(assignedDriverID).update({
        'Seats': FieldValue.increment(-1),
      });

      // After decrementing, update the seat count locally
      setState(() {
        driverSeats -= 1;
      });

      // If seats reach zero, find a new driver for subsequent bookings
      if (driverSeats <= 0) {
        isDriverLoaded = false;  // Reset flag to fetch a new driver next time
        await getAvailableDriver();
      }
    }
  }

  // Generate a unique ticket ID
  String generateTicketID() {
    final random = Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return '$driverPlateNo-$randomNumber';
  }

  // Save the ticket to Firebase
  Future<void> saveTicketToFirebase(String ticketID) async {
    await FirebaseFirestore.instance.collection('tickets').add({
      'currentLocation': widget.currentLocation,
      'destination': widget.destination,
      'seats': 1,
      'ticketID': ticketID,
      'driverPlateNo': driverPlateNo,
    });
  }

  @override
  void initState() {
    super.initState();
    getAvailableDriver();  // Load available driver on initialization if not loaded
  }

  void continueStepper() {
    if (_currentStep == 2) {
      // Generate ticket ID and save the booking
      final ticketID = generateTicketID();
      decrementDriverSeatCount(); // Update the driver’s seat count
      saveTicketToFirebase(ticketID).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket Reserved with ID: $ticketID')),
        );

      });
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  void cancelStepper() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Booking Process')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: continueStepper,
        onStepCancel: cancelStepper,
        steps: [
          Step(
            title: const Text('Location Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Location: ${widget.currentLocation}'),
                Text('Destination: ${widget.destination}'),
              ],
            ),
            isActive: _currentStep == 0,
          ),
          Step(
            title: const Text('Seat Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Driver Plate No: $driverPlateNo'),
                Text('Available Seats: $driverSeats'),
              ],
            ),
            isActive: _currentStep == 1,
          ),
          Step(
            title: const Text('Ticket Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Driver Plate No: $driverPlateNo'),
                const Text('Click Continue to generate your ticket.'),
              ],
            ),
            isActive: _currentStep == 2,
          ),
        ],
      ),
    );
  }
}
