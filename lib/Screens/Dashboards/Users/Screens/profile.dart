import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gptransco/Services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Services/Authentication.dart';
import '../../../../constants.dart';
import '../../components/Services.dart';
import '../../components/profiletextbox.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfileData;
  const ProfileScreen({super.key, required this.userProfileData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.userProfileData['name'] ?? 'N/A';
    mobileController.text = widget.userProfileData['mobileNumber'] ?? 'N/A';
    addressController.text = widget.userProfileData['address'] ?? 'N/A';
  }

  Future<void> _changeProfileImage() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Ask the user if they want to take a picture or choose from the gallery
    final XFile? image = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () async {
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context,
                      await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );

    if (image == null) {
      setState(() {
        isLoading = false; // Hide loading indicator if no image is picked
      });
      return; // Exit the function if no image was picked
    }

    // Step 2: Upload the image to Firebase Storage and get the download URL
    String? downloadUrl =
    await ImageService().userUploadImageToStorage(File(image.path));
    if (downloadUrl != null) {
      // Step 3: Save the new image URL to Firestore
      User? currentUser = _auth.getCurrentUser();
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'profileImageUrl': downloadUrl,
        });

        setState(() {
          widget.userProfileData['profileImageUrl'] =
              downloadUrl; // Update local state
        });
      }
    }

    setState(() {
      isLoading = false; // Hide loading indicator after upload
    });
  }

  void logoutNavigate() {
    hideLoadingDialog(context);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: gpSecondaryColor,
        statusBarIconBrightness: Brightness.light, // Adjust based on design
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Authentication()),
          (Route<dynamic> route) => false, // This removes all previous routes.
    );
  }

  Future<void> logoutHandler() async {
    showLoadingDialog(context);
    await _auth.signOut();
    logoutNavigate();
  }

  Future<void> _saveProfileChanges() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      User? currentUser = _auth.getCurrentUser();
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': nameController.text,
          'mobileNumber': mobileController.text,
          'address': addressController.text,
        });

        setState(() {
          widget.userProfileData['name'] = nameController.text;
          widget.userProfileData['mobileNumber'] = mobileController.text;
          widget.userProfileData['address'] = addressController.text;
        });
      }
    } catch (e) {
      log('Error saving profile changes: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: gpBottomNavigationColor,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: gpPrimaryColor),
          actions: [
            // Edit Icon Button
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: MediaQuery.of(context).viewInsets,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  labelStyle: TextStyle(
                                      color: Colors.grey[700], fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: mobileController,
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  labelStyle: TextStyle(
                                      color: Colors.grey[700], fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  labelText: 'Address',
                                  labelStyle: TextStyle(
                                      color: Colors.grey[700], fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: gpBottomNavigationColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // Show confirmation dialog before saving changes
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                      // Centering the dialog to make it smaller
                                      child: Container(
                                        constraints: const BoxConstraints(
                                            maxWidth: 400), // Limit the width
                                        child: AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          title: const Text(
                                            'Confirm Save',
                                            style: TextStyle(
                                              color: gpBottomNavigationColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                              12, // Set header font size to 12
                                            ),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to save the changes?',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize:
                                              12, // Set content font size to 10
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                    minimumSize: Size
                                                        .zero, // Remove default minimum size
                                                    side: const BorderSide(
                                                        color:
                                                        gpBottomNavigationColor),
                                                    textStyle: const TextStyle(
                                                        fontSize:
                                                        12), // Set button text size to 10
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel',
                                                      style: TextStyle(
                                                          color: Colors.black)),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                    minimumSize: Size
                                                        .zero, // Remove default minimum size
                                                    backgroundColor:
                                                    gpBottomNavigationColor,
                                                    textStyle: const TextStyle(
                                                        fontSize:
                                                        12), // Set button text size to 10
                                                  ),
                                                  onPressed: () async {
                                                    await _saveProfileChanges();
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                    Navigator.pop(
                                                        context); // Close the modal bottom sheet
                                                  },
                                                  child: const Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: gpBottomNavigationColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.edit,
                size: 20,
                color: gpIconColor,
              ),
            )
          ],
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: true,
          title: const Text(
            'Profile',
            style: headerTitle,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 55,
                  backgroundImage: (widget.userProfileData['profileImageUrl'] != null &&
                      widget.userProfileData['profileImageUrl'].startsWith('http'))
                      ? NetworkImage(widget.userProfileData['profileImageUrl'])
                      : null,
                  child: (widget.userProfileData['profileImageUrl'] == null ||
                      !widget.userProfileData['profileImageUrl'].startsWith('http'))
                      ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: gpPrimaryColor,
                      child: Icon(
                        Icons.camera_alt,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Change Profile',
              style: TextStyle(
                  color: gpPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: const BoxDecoration(
                    color: gpPrimaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45))),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        const ProfileTextLabel(
                          labelText: 'Full Name',
                        ),
                        ProfileTextBox(
                          contentText: widget.userProfileData['name'] ?? 'N/A',
                        ),
                        const ProfileTextLabel(
                          labelText: 'Email',
                        ),
                        ProfileTextBox(
                          contentText: widget.userProfileData['email'] ?? 'N/A',
                        ),
                        const ProfileTextLabel(
                          labelText: 'Mobile Number',
                        ),
                        ProfileTextBox(
                          contentText:
                          widget.userProfileData['mobileNumber'] ?? 'N/A',
                        ),
                        const ProfileTextLabel(
                          labelText: 'Address',
                        ),
                        ProfileTextBox(
                          contentText:
                          widget.userProfileData['address'] ?? 'N/A',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: gpBottomNavigationColor),
                                      borderRadius: BorderRadius.circular(10))),
                              onPressed: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return const UpdatePassword(); // Show the UpdatePassword widget
                                  },
                                );
                              },
                              child: const Text(
                                'Change Password',
                                style: TextStyle(
                                    color: gpBottomNavigationColor,
                                    fontSize: 14),
                              )),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                      title: const Text(
                                        'Confirm Logout',
                                        style: TextStyle(
                                            color: gpBottomNavigationColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to logout?',
                                        style: dialogTextColor,
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    side: const BorderSide(
                                                        color:
                                                        gpBottomNavigationColor)),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel',
                                                    style: dialogTextColor)),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                    gpBottomNavigationColor),
                                                onPressed: () {
                                                  logoutHandler();
                                                },
                                                child: const Text(
                                                  'OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ))
                                          ],
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: const Text(
                              'Logout',
                              style:
                              TextStyle(color: Colors.black, fontSize: 14),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
