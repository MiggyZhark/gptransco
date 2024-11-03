import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class DRentalScreen extends StatefulWidget {
  const DRentalScreen({super.key});

  @override
  _DRentalScreenState createState() => _DRentalScreenState();
}

class _DRentalScreenState extends State<DRentalScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  List<String>? _storedImageUrls = [];
  String? plateNumber, fuelType, vehicleColor, gender, strictedRules, price;
  int? totalSeats;
  bool? availability; // New availability variable
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final driverDoc = await FirebaseFirestore.instance
        .collection('Driver')
        .doc(user.uid)
        .get();

    if (driverDoc.exists) {
      final data = driverDoc.data()!;
      setState(() {
        plateNumber = data['plateNumber'];
        fuelType = data['fuelType'];
        totalSeats = data['totalSeats'];
        vehicleColor = data['vehicleColor'];
        strictedRules = data['Stricted'];
        price = data['Price'];
        availability = data['Availability'] ?? true; // Set availability
      });

      // Fetch stored image URLs from 'Vehicle' subcollection
      final vehicleImagesDoc = await FirebaseFirestore.instance
          .collection('Driver')
          .doc(user.uid)
          .collection('Vehicle')
          .doc('Images')
          .get();

      if (vehicleImagesDoc.exists) {
        setState(() {
          _storedImageUrls = List<String>.from(vehicleImagesDoc['imageUrls']);
        });
      }
    }
    setState(() {
      _isLoading = false; // Stop loading indicator when data is fetched
    });
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.length >= 3) {
      setState(() {
        _selectedImages = images.take(3).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 3 images')),
      );
    }
  }

  Future<void> _saveVehicleDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedImages == null || _selectedImages!.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload 3 images before saving')),
      );
      return;
    }

    try {
      List<String> imageUrls = [];
      for (var i = 0; i < _selectedImages!.length; i++) {
        XFile image = _selectedImages![i];
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('vehicle_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await storageRef.putFile(File(image.path));
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // Save or update vehicle details in 'Driver' document
      await FirebaseFirestore.instance.collection('Driver').doc(user.uid).set({
        'plateNumber': plateNumber,
        'fuelType': fuelType,
        'totalSeats': totalSeats,
        'vehicleColor': vehicleColor,
        'Stricted': strictedRules,
        'Price': price,
        'Availability': availability, // Save availability to Firestore
      }, SetOptions(merge: true));

      // Save image URLs in 'Vehicle' subcollection under 'Driver'
      final vehicleCollection = FirebaseFirestore.instance
          .collection('Driver')
          .doc(user.uid)
          .collection('Vehicle');

      await vehicleCollection.doc('Images').set({'imageUrls': imageUrls});

      setState(() {
        _storedImageUrls = imageUrls;
        _selectedImages = []; // Clear the selected images after saving
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle details saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicle details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('GPVan'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.25,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(color: Colors.white),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator()) // Display loading indicator
                      : (_selectedImages?.isNotEmpty ?? false) // Check if new images are selected
                      ? ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    children: _selectedImages!.map((image) {
                      return Image.file(File(image.path), fit: BoxFit.cover);
                    }).toList(),
                  )
                      : (_storedImageUrls?.isNotEmpty ?? false) // Otherwise, show stored images
                      ? ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    children: _storedImageUrls!.map((url) {
                      return Image.network(url, fit: BoxFit.cover);
                    }).toList(),
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        Text('Upload 3 Images'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vehicle Information',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Plate Number', hintText: plateNumber ?? ''),
                            onChanged: (value) => plateNumber = value,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Fuel Type', hintText: fuelType ?? ''),
                            onChanged: (value) => fuelType = value,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Total Seats', hintText: totalSeats?.toString() ?? ''),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => totalSeats = int.tryParse(value),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Vehicle Color', hintText: vehicleColor ?? ''),
                            onChanged: (value) => vehicleColor = value,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Stricted Rules', hintText: strictedRules ?? ''),
                            onChanged: (value) => strictedRules = value,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelStyle: TextStyle(fontSize: 12),labelText: 'Price', hintText: price ?? ''),
                            onChanged: (value) => price = value,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Availability',
                            style: TextStyle(fontSize: 12),
                          ),
                          DropdownButton<bool>(dropdownColor: Colors.white,
                            value: availability,
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Available',style: TextStyle(fontSize: 12),)),
                              DropdownMenuItem(value: false, child: Text('Not Available',style: TextStyle(fontSize: 12),)),
                            ],
                            onChanged: (bool? value) {
                              setState(() {
                                availability = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[Color(0xFF0E6357), Color(0xFF009774), Color(0xFF07917C)],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextButton(
                            onPressed: _saveVehicleDetails,
                            child: const Text(
                              'Save',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,)
            ],
          ),
        ),
      ),
    );
  }
}
