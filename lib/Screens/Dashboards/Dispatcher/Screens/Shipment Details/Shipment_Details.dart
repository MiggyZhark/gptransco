import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';

import '../../../../../constants.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shipmentDetails;

  const ShipmentDetailsScreen({super.key, required this.shipmentDetails});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  String? selectedPlateNumber;
  String? selectedDriverName;
  List<String> driverNames = [];
  Map<String, String> driverToPlateMap = {};
  Map<String, String> plateToDriverMap = {};

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final driverSnapshot = await FirebaseFirestore.instance
        .collection('Driver')
        .where('role', isEqualTo: 'Driver')
        .where('Availability', isEqualTo: true)
        .get();

    driverToPlateMap = {
      for (var doc in driverSnapshot.docs)
        (doc.data())['driverName'] as String:
        (doc.data())['plateNumber'] as String
    };

    plateToDriverMap = {
      for (var doc in driverSnapshot.docs)
        (doc.data())['plateNumber'] as String:
        (doc.data())['driverName'] as String
    };

    setState(() {
      driverNames = driverToPlateMap.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shipment Details',style: headerTitle,),
          backgroundColor: gpBottomNavigationColorDark,
          elevation: 1,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shippings')
              .doc(widget.shipmentDetails['terminal'])
              .collection('packages')
              .doc(widget.shipmentDetails['packageId'])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final shipmentData = snapshot.data!.data() as Map<String, dynamic>;
            String formattedDate = 'N/A';
            if (shipmentData['timestamp'] != null) {
              final timestamp = shipmentData['timestamp'] as Timestamp;
              formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(widget.shipmentDetails['packageId']),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Details for Shipment'),
                  _buildDetailCard('Status', shipmentData['status'] ?? 'N/A'),
                  _buildDetailCard('Terminal', shipmentData['terminal'] ?? 'N/A'),
                  _buildDetailCard('Destination', shipmentData['destination'] ?? 'N/A'),
                  _buildDetailCard('Fragile', shipmentData['fragile'] ?? 'N/A'),
                  _buildDetailCard('Date and Time', formattedDate),
                  _buildDetailCard('Package Info', shipmentData['packageInfo'] ?? 'N/A'),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Select Driver Details'),
                  _buildDriverDropdown(shipmentData),
                  _buildPlateDropdown(shipmentData),
                  const SizedBox(height: 10,),
                  _buildReceiptButton(shipmentData['imageUrl']),
                  const SizedBox(height: 15),
                  _buildAcceptButton(shipmentData),
                  const SizedBox(height: 10,)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String packageId) {
    // Extract the substring after the hyphen
    String trimmedId = packageId.contains('-') ? packageId.split('-').last : packageId;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.local_shipping, size: 25, color: Colors.blueGrey),
            const SizedBox(width: 5,),
            Text(
              'Shipment ID: $trimmedId',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.info, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Card(color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(top: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildDriverDropdown(Map<String, dynamic> shipmentData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(dropdownColor: Colors.white,
        decoration: _inputDecoration('Driver Name'),
        value: selectedDriverName,
        items: driverNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
        onChanged: shipmentData['status'] == 'accepted' ? null : (value) {
          setState(() {
            selectedDriverName = value;
            selectedPlateNumber = driverToPlateMap[value!];
          });
        },
      ),
    );
  }

  Widget _buildPlateDropdown(Map<String, dynamic> shipmentData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(dropdownColor: Colors.white,
        decoration: _inputDecoration('Plate Number'),
        value: selectedPlateNumber,
        items: driverToPlateMap.values
            .map((plate) => DropdownMenuItem(value: plate, child: Text(plate)))
            .toList(),
        onChanged: shipmentData['status'] == 'accepted'
            ? null
            : (value) {
          setState(() {
            selectedPlateNumber = value;
            selectedDriverName = plateToDriverMap[value!];
          });
        },
      ),
    );
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildAcceptButton(Map<String, dynamic> shipmentData) {
    String ticketID = widget.shipmentDetails['packageId'].substring(0, widget.shipmentDetails['packageId'].indexOf('-'));
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle,color: Colors.white,),
        label: const Text('Accept Shipment',style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          backgroundColor: gpBottomNavigationColorDark,
        ),
        onPressed: shipmentData['status'] == 'accepted'
            ? null
            : () async {
          if (selectedPlateNumber != null && selectedDriverName != null) {
            // Show confirmation dialog
            bool confirm = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Shipment Acceptance'),
                  content: const Text('Are you sure you want to accept this shipment?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                );
              },
            );

            // If confirmed, accept the shipment
            if (confirm) {
              await FirebaseFirestore.instance
                  .collection('shippings')
                  .doc(widget.shipmentDetails['terminal'])
                  .collection('packages')
                  .doc(widget.shipmentDetails['packageId'])
                  .update({
                'status': 'accepted',
                'acceptedDate': Timestamp.now(),
                'driverName': selectedDriverName,
                'plateNumber': selectedPlateNumber,
              });

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.shipmentDetails['userUID'])
                  .collection('Notification')
                  .doc(widget.shipmentDetails['packageId'])
                  .set({
                'Title': 'Package Approval',
                'message':
                'The dispatcher has accept your package deliver on PlateNo. $selectedPlateNumber.',
                'ticketID': ticketID,
                'createdAt': FieldValue.serverTimestamp(),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shipment accepted with Plate Number: $selectedPlateNumber and Driver: $selectedDriverName'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select both Plate Number and Driver Name'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildReceiptButton(String imageUrl) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.receipt,color: Colors.white,),
        label: const Text('Receipt',style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          backgroundColor: gpBottomNavigationColorDark,
        ),
        onPressed: (){
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: InstaImageViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Failed to load image',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
