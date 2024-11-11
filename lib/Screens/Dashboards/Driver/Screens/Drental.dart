import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import '../../../../constants.dart';

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
  bool? availability;
  bool _isLoading = true;

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
        availability = data['Availability'] ?? true;
      });

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
      _isLoading = false;
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.length >= 3) {
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

      await FirebaseFirestore.instance.collection('Driver').doc(user.uid).set({
        'plateNumber': plateNumber,
        'fuelType': fuelType,
        'totalSeats': totalSeats,
        'vehicleColor': vehicleColor,
        'Stricted': strictedRules,
        'Price': price,
        'Availability': availability,
      }, SetOptions(merge: true));

      final vehicleCollection = FirebaseFirestore.instance
          .collection('Driver')
          .doc(user.uid)
          .collection('Vehicle');

      await vehicleCollection.doc('Images').set({'imageUrls': imageUrls});

      setState(() {
        _storedImageUrls = imageUrls;
        _selectedImages = [];
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
          title: const Text('GPVan', style: headerTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              tooltip: 'Help',
              onPressed: () {
                // Implement help functionality here
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.24,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (_selectedImages?.isNotEmpty ?? false)
                      ? ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    children: _selectedImages!.map((image) {
                      return Image.file(File(image.path), fit: BoxFit.cover);
                    }).toList(),
                  )
                      : (_storedImageUrls?.isNotEmpty ?? false)
                      ? ImageSlideshow(
                    width: double.infinity,
                    height: 200,
                    children: _storedImageUrls!.map((url) {
                      return Image.network(url, fit: BoxFit.cover);
                    }).toList(),
                  )
                      : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        Text('Upload 3 Images'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(thickness: 1, color: Colors.grey),
                      _buildTextField(label: 'Plate Number', value: plateNumber, onChanged: (val) => plateNumber = val),
                      _buildTextField(label: 'Fuel Type', value: fuelType, onChanged: (val) => fuelType = val),
                      _buildTextField(
                        label: 'Total Seats',
                        value: totalSeats?.toString(),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => totalSeats = int.tryParse(val),
                      ),
                      _buildTextField(label: 'Vehicle Color', value: vehicleColor, onChanged: (val) => vehicleColor = val),
                      _buildTextField(label: 'Stricted Rules', value: strictedRules, onChanged: (val) => strictedRules = val),
                      _buildTextField(label: 'Price', value: price, onChanged: (val) => price = val),
                      const Text('Availability', style: TextStyle(fontSize: 12)),
                      DropdownButton<bool>(
                        dropdownColor: Colors.white,
                        value: availability,
                        items: const [
                          DropdownMenuItem(value: true, child: Text('Available', style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(value: false, child: Text('Not Available', style: TextStyle(fontSize: 12))),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: const Color(0xFF07917C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saveVehicleDetails,
                  child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 25,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String? value,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: value ?? '',
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }
}
