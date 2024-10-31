import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
import '../../../../../constants.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<Map<String, dynamic>> _userPackages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserPackages();
  }

  void _fetchUserPackages() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final terminalCollections = ['Palimbang', 'Gensan'];

    for (String terminal in terminalCollections) {
      FirebaseFirestore.instance
          .collection('shippings')
          .doc(terminal)
          .collection('packages')
          .snapshots()
          .listen((snapshot) {
        List<Map<String, dynamic>> packages = [];

        for (var doc in snapshot.docs) {
          final packageData = doc.data();
          final packageId = packageData['packageId'];

          // Check if the packageId starts with the current user's ID
          if (packageId != null && packageId.startsWith(userId)) {
            final userPackageId = packageId.split('-').last;
            packageData['displayPackageId'] = userPackageId;
            packages.add(packageData);
          }
        }

        // Sort the packages by timestamp in descending order (latest first)
        packages.sort((a, b) {
          final aTimestamp = a['timestamp'] as Timestamp?;
          final bTimestamp = b['timestamp'] as Timestamp?;
          return bTimestamp!.compareTo(aTimestamp!);
        });

        // Update the state to reflect new packages
        setState(() {
          _userPackages = packages;
        });
      });
    }
  }

  void _showPackageDialog(BuildContext context, Map<String, dynamic> package) {
    final imageUrl = package['imageUrl'] ?? '';
    final productName = package['packageInfo'] ?? '';
    final packageId = package['displayPackageId'] ?? '';
    final destination = package['destination'] ?? '';
    final fragile = package['fragile'] ?? 'No';
    final terminal = package['terminal'] ?? '';
    final fullPackageId = package['packageId'] ?? '';
    final status = package['status'] ?? '';
    final timestamp = package['timestamp'] as Timestamp?;
    final formattedTimestamp = timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
        : 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.all(15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    width: MediaQuery.sizeOf(context).width * 1,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 8),
              Divider(height: 8),
              Text(productName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('Package ID: $packageId'),
              Text('Fragile: $fragile'),
              Text('Terminal: $terminal'),
              Text('Destination: $destination'),
              Text('Date: $formattedTimestamp'),
            ],
          ),
          actions: [
            if (status == 'Pending')
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore.instance
                        .collection('shippings')
                        .doc(terminal)
                        .collection('packages')
                        .doc(fullPackageId)
                        .delete();
                    Navigator.of(context).pop(); // Close dialog after deletion
                  } catch (e) {
                    print('Error deleting package: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to cancel package.')),
                    );
                  }
                },
                child: const Text(
                  'Cancel Package',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text('Packages', style: headerTitle),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: _userPackages.isEmpty
              ? const Center(child: Text('No packages found',style: TextStyle(fontSize: 14),))
              : ListView.builder(
            itemCount: _userPackages.length,
            itemBuilder: (context, index) {
              final package = _userPackages[index];
              final packagePrice = package['price'] ?? '';
              final productName = package['packageInfo'] ?? '';
              final status = package['status'] ?? '';

              IconData leadingIcon;
              Color iconColor;
              if (status == "Completed") {
                leadingIcon = Icons.check;
                iconColor = Colors.green;
              } else if (status == "Pending") {
                leadingIcon = Icons.pending;
                iconColor = Colors.blueGrey;
              } else {
                leadingIcon = Icons.help_outline;
                iconColor = Colors.grey;
              }

              return Card(
                color: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    leadingIcon,
                    color: iconColor,
                    size: 45,
                  ),
                  title: Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('Price: ₱$packagePrice'),
                      const SizedBox(height: 5),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _showPackageDialog(context, package),
                    icon: Icon(Icons.arrow_forward),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
