import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LNFScreen extends StatefulWidget {
  const LNFScreen({super.key});

  @override
  _LNFScreenState createState() => _LNFScreenState();
}

class _LNFScreenState extends State<LNFScreen> {
  File? _selectedImage;
  final TextEditingController _itemInfoController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  String? _driverName;
  String? _plateNumber;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();

    // Add listener to update the button state when fields change
    _itemInfoController.addListener(_validateForm);
    _itemNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _itemInfoController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _itemInfoController.text.isNotEmpty &&
          _itemNameController.text.isNotEmpty &&
          _selectedImage != null;
    });
  }

  Future<void> _fetchDriverDetails() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot driverDoc = await FirebaseFirestore.instance
            .collection('Driver')
            .doc(user.uid)
            .get();
        if (driverDoc.exists) {
          setState(() {
            _driverName = driverDoc['driverName'] ?? 'Unknown Driver';
            _plateNumber = driverDoc['plateNumber'] ?? 'Unknown Plate';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch driver details: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            label: const Text('Take a Picture'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo, color: Colors.green),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
        _validateForm();
      }
    }
  }

  Future<void> _confirmSubmission() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Submission',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to submit this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _submitReport();
      _clearFields();
    }
  }

  Future<void> _submitReport() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final String fileName =
            'lost_found_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('LNF').add({
        'dateTime': DateTime.now(),
        'itemName': _itemNameController.text,
        'itemPicture': imageUrl ?? '',
        'itemInformation': _itemInfoController.text,
        'driverName': _driverName ?? 'Unknown Driver',
        'plateNumber': _plateNumber ?? 'Unknown Plate',
        'isReturned': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report submitted successfully.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 700),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e',
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  void _clearFields() {
    setState(() {
      _selectedImage = null;
      _itemInfoController.clear();
      _itemNameController.clear();
      _isFormValid = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Lost & Found Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: _selectedImage == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 180,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item Name',
                    hintText: 'Enter the name of the lost item',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _itemInfoController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item Information',
                    hintText: 'Enter details about the lost item',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid ? _confirmSubmission : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
