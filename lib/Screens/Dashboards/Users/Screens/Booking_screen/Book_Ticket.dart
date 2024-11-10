import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import '../../../../../constants.dart';
import 'My_ticket.dart';

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
  int remainingSeats = 18;
  bool isDriverLoaded = false;
  String? userUID; // Variable to store the user UID
  DateTime? scheduledDate;
  DateTime? expirationDate;


  // Fetch current user's UID
  void getCurrentUserUID() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userUID = user.uid;
      });
    }
  }

  // Fetch an available driver with Availability = true, Seats > 0, and address matching current location
  Future<void> getAvailableDriver() async {
    if (isDriverLoaded || userUID == null) return; // Ensure userUID is loaded before proceeding

    final driverQuery = await FirebaseFirestore.instance
        .collection('Driver')
        .where('Availability', isEqualTo: true)         // Only get available drivers
        .where('address', isEqualTo: widget.currentLocation) // Filter by current location
        .get();

    for (var driver in driverQuery.docs) {
      final passengerCount = await FirebaseFirestore.instance
          .collection('Driver')
          .doc(driver.id)
          .collection('Passenger')
          .get()
          .then((snapshot) => snapshot.docs.length);

      if (passengerCount < 18) {
        setState(() {
          driverPlateNo = driver['plateNumber'];
          assignedDriverID = driver.id;
          remainingSeats = 18 - passengerCount;
          isDriverLoaded = true;
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No available drivers in this location. Please try again later.')),
    );
  }


  // Generate a unique ticket ID
  String generateTicketID() {
    final random = Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return '$driverPlateNo-$randomNumber';
  }

  // Save the ticket in the Passenger subcollection with user UID as document ID
  Future<void> saveTicketToFirebase(String ticketID) async {
    if (assignedDriverID.isNotEmpty && userUID != null) {
      await FirebaseFirestore.instance
          .collection('Driver')
          .doc(assignedDriverID)
          .collection('Passenger')
          .doc(userUID) // Save document with current user's UID as ID
          .set({
        'currentLocation': widget.currentLocation,
        'destination': widget.destination,
        'ticketID': ticketID,
        'plateNumber': driverPlateNo,
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledDate': scheduledDate,
        'expirationDate': expirationDate,
        'status': 'Waiting',
      });

      // Notification entry for the driver
      await FirebaseFirestore.instance
          .collection('Driver')
          .doc(assignedDriverID)
          .collection('Notification')
          .doc(userUID)
          .set({
        'Title': 'Reservation',
        'message': 'A customer has reserved a trip to ${widget.destination}.',
        'ticketID': ticketID,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('my_ticket')
          .doc(userUID)
          .set({
        'currentLocation': widget.currentLocation,
        'destination': widget.destination,
        'ticketID': ticketID,
        'plateNumber': driverPlateNo,
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledDate': scheduledDate,
        'expirationDate': expirationDate,
        'status': 'Waiting',
      });
    }
  }


  Future<void> pickScheduleDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          scheduledDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          expirationDate = scheduledDate!.add(const Duration(days: 1));
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    getCurrentUserUID(); // Fetch user UID
    getAvailableDriver();
  }

  void continueStepper() {
    if (_currentStep == 1) {
      // Ensure that a scheduled date is selected before continuing
      if (scheduledDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please pick a schedule date before proceeding.')),
        );
        return; // Prevent advancing to the next step
      }
    }

    if (_currentStep == 3) {
      final ticketID = generateTicketID();
      saveTicketToFirebase(ticketID).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket Reserved with ID: $ticketID')),
        );
        Navigator.pop(context);

        // Reload the available driver if needed
        setState(() {
          isDriverLoaded = false;
        });
        getAvailableDriver();
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ticket Booking Process', style: headerTitle),
        ),
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
              title: const Text('Schedule Date'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: pickScheduleDate,
                    child: const Text('Pick Schedule Date'),
                  ),
                  if (scheduledDate != null)
                    Text('Scheduled Date: ${scheduledDate.toString()}'),
                ],
              ),
              isActive: _currentStep == 1,
            ),
            Step(
              title: const Text('Seat Confirmation'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver Plate No: $driverPlateNo'),
                  Text('Remaining Seats: $remainingSeats'),
                ],
              ),
              isActive: _currentStep == 2,
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
              isActive: _currentStep == 3,
            ),
          ],
        ),
      ),
    );
  }
}
