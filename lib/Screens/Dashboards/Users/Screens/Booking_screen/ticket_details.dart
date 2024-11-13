import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import '../../../../../constants.dart';
import '../../../components/message_screen.dart';

class TicketDetails extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetails({
    Key? key,
    required this.ticketData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket ID: ${ticketData['ticketID']}',
          style: headerTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket Details Card
            Card(
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
                      value: formatDate(ticketData['scheduledDate']),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.event,
                      label: 'Expiration Date',
                      value: formatDate(ticketData['expirationDate']),
                    ),
                    const Divider(),
                    _buildDetailRow(
                      icon: Icons.info,
                      label: 'Status',
                      value: ticketData['status'] ?? 'N/A',
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Receipt Section
            const Text(
              'Receipt:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Center(
              child: ticketData['Receipt'] != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                                    ticketData['Receipt'],
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text('Failed to load image',
                                          style:
                                              TextStyle(color: Colors.white)),
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
                          child: const Text(
                            'Receipt Image',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MessageScreen(
                                          receiverUid: ticketData['driverUID'],
                                          senderUid: ticketData['userUID'],
                                          profileImage: ticketData['userProfile'],
                                          name: ticketData['driverName'],
                                        )));
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
                            'Contact Driver',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : const Text('No receipt available.',
                      style: TextStyle(color: Colors.grey)),
            )
          ],
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
