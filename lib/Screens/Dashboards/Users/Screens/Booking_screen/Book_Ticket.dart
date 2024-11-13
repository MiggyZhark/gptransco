import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../constants.dart';

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
  String driverName = "";
  String driverPlateNo = "";
  String assignedDriverID = "";
  int remainingSeats = 18;
  bool isDriverLoaded = false;
  String? userUID; // Variable to store the user UID
  DateTime? scheduledDate;
  DateTime? expirationDate;
  File? _selectedImage;
  String? driverMobileNumber; // Store driver's mobile number
  final ImagePicker picker = ImagePicker();



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
    if (isDriverLoaded || userUID == null) return;

    final driverQuery = await FirebaseFirestore.instance
        .collection('Driver')
        .where('Availability', isEqualTo: true)
        .where('address', isEqualTo: widget.currentLocation)
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
          driverMobileNumber = driver['mobileNumber']; // Fetch mobile number
          isDriverLoaded = true;
          driverName = driver['driverName'];
        });
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No available drivers in this location. Please try again later.')),
    );
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Select Image Source',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Text('Please choose how you would like to select the image.'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt, color: Colors.green),
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            label: const Text('Take a Picture'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo, color: Colors.green),
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            label: const Text('Choose from Gallery'),
          ),
        ],
      ),
    );

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  // Generate a unique ticket ID
  String generateTicketID() {
    final random = Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return '$driverPlateNo-$randomNumber';
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = 'receipts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save the ticket in the Passenger subcollection with user UID as document ID
  Future<void> saveTicketToFirebase(String ticketID) async {
    showLoadingDialog(context);
    if (assignedDriverID.isNotEmpty && userUID != null) {
      String? imageUrl;

      // Upload the image to Firebase Storage if an image is selected
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }
      await FirebaseFirestore.instance
          .collection('Driver')
          .doc(assignedDriverID)
          .collection('Passenger')
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
        'userUID': userUID,
        'Receipt': imageUrl, // Save the download URL here
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

      // Save the ticket to the user's collection
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
        'Receipt': imageUrl, // Save the download URL here
        'driverUID':assignedDriverID,
        'driverName':driverName,
        'userUID':userUID,
        'userProfile':'assets/models/booking.png'
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
    if (_currentStep == 1 && scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a schedule date before proceeding.')),
      );
      return;
    }

    if (_currentStep == 3 && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a payment receipt image to continue.')),
      );
      return;
    }

    if (_currentStep == 4) {
      final ticketID = generateTicketID();
      saveTicketToFirebase(ticketID).then((_) {
        hideLoadingDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket Reserved with ID: $ticketID')),
        );
        Navigator.pop(context);
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
              title: const Text(
                'Schedule Date',
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickScheduleDate,
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    label: const Text('Pick Schedule Date',style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gpBottomNavigationColorDark,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (scheduledDate != null)
                    ListTile(
                      leading: const Icon(Icons.event, color: Colors.green),
                      title: const Text(
                        'Scheduled Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('MMMM dd, yyyy').format(scheduledDate!),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                ],
              ),
              isActive: _currentStep == 1,
            ),
            Step(
              title: const Text(
                'Seat Confirmation',
              ),
              content: Card(color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.blue),
                        title: const Text(
                          'Driver Plate No',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(driverPlateNo.isNotEmpty ? driverPlateNo : 'N/A'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.event_seat, color: Colors.green),
                        title: const Text(
                          'Remaining Seats',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          remainingSeats.toString(),
                          style: TextStyle(
                            color: remainingSeats > 0
                                ? Colors.black
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep == 2,
            ),
            Step(
              title: const Text('Payment Confirmation'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (driverMobileNumber != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please pay via GCash to the driver’s mobile number:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'GCash Number: $driverMobileNumber',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    onPressed: _pickImage,
                    label: const Text('Upload Payment Receipt'),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              isActive: _currentStep == 3,
            ),
            Step(
              title: const Text(
                'Ticket Confirmation',
              ),
              content: Card(color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.blue),
                        title: const Text(
                          'Driver Plate No',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(driverPlateNo.isNotEmpty ? driverPlateNo : 'N/A'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.location_pin, color: Colors.redAccent),
                        title: const Text(
                          'Current Location',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.currentLocation),
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag, color: Colors.green),
                        title: const Text(
                          'Destination',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.destination),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.orange),
                        title: const Text(
                          'Scheduled Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          scheduledDate != null
                              ? '${scheduledDate!.toLocal()}'.split(' ')[0]
                              : 'Not scheduled',
                          style: TextStyle(
                            color: scheduledDate != null ? Colors.black : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Click Continue to generate your ticket.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              isActive: _currentStep == 4,
            ),
          ],
        ),
      ),
    );
  }
}
