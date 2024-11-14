import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import '../../../../constants.dart';

class PTicketsScreen extends StatefulWidget {
  final String userUID;
  final String ticketID;
  final String receipt;
  final Timestamp scheduledDate;
  final Timestamp expirationDate;
  final String destination;
  final String currentLocation;

  const PTicketsScreen(
      {super.key,
      required this.userUID,
      required this.ticketID,
      required this.receipt,
      required this.scheduledDate,
      required this.expirationDate,
      required this.destination,
      required this.currentLocation});

  @override
  State<PTicketsScreen> createState() => _PTicketsScreenState();
}

class _PTicketsScreenState extends State<PTicketsScreen> {
  String? currentUserUID;
  String? receipt;

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
  }

  /// Function to fetch the current user's UID from Firebase Authentication
  Future<void> getCurrentUserUID() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUID = user.uid;
      });
    }
  }

  void snackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Function to approve the ticket
  Future<void> approveTicket(BuildContext context) async {
    if (currentUserUID == null) {
      snackBar('User not logged in');
      return;
    }

    try {
      // Define Firestore document references
      final driverDocRef = FirebaseFirestore.instance
          .collection('Driver')
          .doc(currentUserUID)
          .collection('Passenger')
          .doc(widget.userUID);

      final userTicketDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUID)
          .collection('my_ticket')
          .doc(widget.userUID);

      // Get current ticket data from the 'Passenger' collection
      final passengerDocSnapshot = await driverDocRef.get();
      final passengerData = passengerDocSnapshot.data();

      if (passengerData != null) {
        // Step 1: Update 'Passenger' collection with new status
        await driverDocRef.delete();
        await FirebaseFirestore.instance
            .collection('Driver')
            .doc(currentUserUID)
            .collection('Passenger')
            .doc(widget.userUID) // New document ID
            .set({
          ...passengerData,
          'status': 'approved',
        });

        // Step 2: Update 'my_ticket' collection with new status
        final myTicketDocSnapshot = await userTicketDocRef.get();
        final myTicketData = myTicketDocSnapshot.data();

        if (myTicketData != null) {
          await userTicketDocRef.delete();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userUID)
              .collection('my_ticket')
              .doc(widget.ticketID) // New document ID
              .set({
            ...myTicketData,
            'status': 'approved',
          });

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userUID)
              .collection('Notification')
              .doc(widget.ticketID)
              .set({
            'Title': 'Booking Approval',
            'message':
                'The driver has approve your booking reservation on TicketID: ${widget.ticketID}.',
            'ticketID': widget.ticketID,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        // Show a success message
        snackBar('Ticket approved successfully!');
      }
    } catch (error) {
      // Handle any errors
      snackBar('Failed to approve ticket: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Ticket ID: ${widget.ticketID}',
            style: headerTitle,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // From Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 5),
                              Text(
                                "From",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.currentLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Dotted Line Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            8,
                            (index) => Container(
                              height: 3,
                              width: 2,
                              color: Colors.grey[300],
                              margin: const EdgeInsets.symmetric(vertical: 1),
                            ),
                          ),
                        ),
                      ),
                      // To Location
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.teal[700]),
                              const SizedBox(width: 5),
                              const Text(
                                "To",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.destination,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Card(
                color: Colors.blue[50],
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: 'Scheduled Date',
                        value: formatDate(widget.scheduledDate),
                      ),
                      const Divider(),
                      _buildDetailRow(
                        icon: Icons.event,
                        label: 'Expiration Date',
                        value: formatDate(widget.expirationDate),
                      ),
                      const Divider(),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Driver')
                            .doc(currentUserUID)
                            .collection('Passenger')
                            .doc(widget.userUID)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text('Ticket not found');
                          }
                          final status = snapshot.data!.get('status') as String;
                          return _buildDetailRow(
                            icon: Icons.info,
                            label: 'Status',
                            value: status,
                            valueStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Show a full-screen image preview in a dialog
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(10),
                          child: InstaImageViewer(
                            child: Image.network(
                              widget.receipt,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.receipt,color: Colors.white,)
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      approveTicket(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      subtitle: Text(value, style: valueStyle ?? const TextStyle(fontSize: 14)),
    );
  }

  String formatDate(dynamic date) {
    if (date != null) {
      final DateTime formattedDate = (date as Timestamp).toDate();
      return "${formattedDate.day}/${formattedDate.month}/${formattedDate.year}";
    }
    return 'N/A';
  }
}
