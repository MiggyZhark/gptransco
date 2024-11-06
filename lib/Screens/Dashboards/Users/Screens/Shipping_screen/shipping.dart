import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gptransco/Screens/Dashboards/Users/Screens/Shipping_screen/packages_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../Services/error_handling.dart';
import '../../../../../constants.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final errorHandler = ErrorHandling();
  final TextEditingController _packageInfoController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String _isSensitive = 'False';
  String _selectedDestination = 'Palimbang';
  String _selectedTerminal = 'Gensan';
  bool _isImageSelected = false; // Track image selection status
  final ImagePicker _picker = ImagePicker();

  final List<String> sensitivityOptions = ['True', 'False'];
  final List<String> destinationOptions = [
    'Palimbang',
    'Maitum',
    'Kiamba',
    'Maasim',
    'Gensan'
  ];
  final List<String> terminalOptions = ['Palimbang', 'Gensan'];

  void _handleImageSelected(File? selectedImage) {
    setState(() {
      _selectedImage = selectedImage;
      _isImageSelected = selectedImage != null;
    });
  }

  Future<void> _pickImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _handleImageSelected(_selectedImage); // Call with image parameter
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _handleImageSelected(_selectedImage); // Call with image parameter
      });
    }
  }

  @override
  void dispose() {
    _packageInfoController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _uploadPackage() async {
    showLoadingDialog(context);
    if (!_isImageSelected || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      hideLoadingDialog(context);
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final packageId = '${user.uid}-${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    try {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('packages/$_selectedTerminal/${user.uid}/$packageId.jpg');
      await storageRef.putFile(_selectedImage!);

      // Get the image URL
      final imageUrl = await storageRef.getDownloadURL();

      // Get the selected terminal to save the package in the corresponding sub-collection
      String terminalCollection = _selectedTerminal;

      // Save package data to Firestore under the terminal sub-collection
      await FirebaseFirestore.instance
          .collection('shippings') // Main collection
          .doc(terminalCollection) // Terminal as a sub-document
          .collection(
          'packages') // Sub-collection for packages under each terminal
          .doc(packageId) // Unique package document
          .set({
        'packageInfo': _packageInfoController.text,
        'fragile': _isSensitive,
        'terminal': _selectedTerminal,
        'destination': _selectedDestination,
        'price': _priceController.text,
        'timestamp': timestamp,
        'imageUrl': imageUrl,
        'packageId': packageId,
        'status': 'Pending',
      });

      // Notify user of successful save
      uploadPackageHandler();

      // Reset form and image selection
      _formKey.currentState?.reset();
      setState(() {
        _isImageSelected = false;
        _selectedImage = null;
        _packageInfoController.clear();
        _priceController.clear();
      });
    } catch (e) {
      // Handle upload error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post package')),
      );
    }
  }

  void uploadPackageHandler() {
    hideLoadingDialog(context);
    errorHandler.showErrorBanner(
        context, 'Success', 'Package has been submitted', ContentType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Package Transpo',
          style: headerTitle,
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                  image: _selectedImage != null
                      ? DecorationImage(
                      image: FileImage(_selectedImage!), fit: BoxFit.cover)
                      : null,
                ),
                child: _selectedImage == null
                    ? const Icon(Icons.add_a_photo,
                    size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          Expanded(
              child: Container(
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(
                color: gpPrimaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    'Package Information',
                    style: TextStyle(fontSize: 14),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // First row: Product name and sensitivity
                          Row(
                            children: [
                              // Product Name TextField
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _packageInfoController,
                                  decoration: const InputDecoration(
                                      labelText: 'Package Info',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Package Info';
                                    }
                                    return null;
                                  },
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Sensitive Dropdown
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  dropdownColor: gpPrimaryColor,
                                  decoration: const InputDecoration(
                                      labelText: 'Fragile',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10)),
                                  value: _isSensitive,
                                  items: sensitivityOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _isSensitive = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Second row: Location and Price
                          Row(
                            children: [
                              // Location Dropdown
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  dropdownColor: gpPrimaryColor,
                                  decoration: const InputDecoration(
                                      labelText: 'Terminal',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10)),
                                  value: _selectedTerminal,
                                  items: terminalOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedTerminal = newValue!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  dropdownColor: gpPrimaryColor,
                                  decoration: const InputDecoration(
                                      labelText: 'Destination',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10)),
                                  value: _selectedDestination,
                                  items: destinationOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedDestination = newValue!;
                                    });
                                  },
                                ),
                              ),
                              // Price TextField
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.money),
                                      labelText: '₱rice',
                                      labelStyle: TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.blueGrey),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const PackagesScreen()));
                                    },
                                    child: const FittedBox(
                                      child: Text(
                                        'Packages',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color:
                                                    gpBottomNavigationColorDark),
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        if (_selectedTerminal ==
                                            _selectedDestination) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Terminal and Destination cannot be the same.')),
                                          );
                                        } else {
                                          _uploadPackage();
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Please fill in the required fields')),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Post',
                                      style: TextStyle(color: Colors.teal),
                                    )),
                              ),
                            ],
                          ),
                        ],
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
