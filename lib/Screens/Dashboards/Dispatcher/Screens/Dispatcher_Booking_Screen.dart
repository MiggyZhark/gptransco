import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../constants.dart';


class DispatcherBookingScreen extends StatefulWidget {
  const DispatcherBookingScreen({super.key});

  @override
  State<DispatcherBookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<DispatcherBookingScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VehicleHub', style: headerTitle),
          backgroundColor: gpBottomNavigationColorDark,
          actions: [
            DropdownButton<String>(dropdownColor: gpBottomNavigationColorDark,
              value: selectedFilter,
              icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
              underline: Container(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFilter = newValue!;
                });
              },
              items: <String>['All', 'Available', 'Not Available']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14,color: Colors.white)),
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Driver')
              .where('role', isEqualTo: 'Driver')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No drivers found.', style: TextStyle(fontSize: 14)));
            }
      
            final drivers = snapshot.data!.docs;
      
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
      
                // Apply filter based on availability
                if (selectedFilter == 'Available' && driver['Availability'] != true) {
                  return const SizedBox.shrink(); // Hide drivers that are not available
                } else if (selectedFilter == 'Not Available' && driver['Availability'] != false) {
                  return const SizedBox.shrink(); // Hide drivers that are available
                }
      
                return Card(color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(driver['driverImage']),
                    ),
                    title: Text('Plate Number: ${driver['plateNumber']}', style: const TextStyle(fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver Name: ${driver['driverName']}', style: const TextStyle(fontSize: 12)),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: driver['Availability'] ? Colors.green : Colors.red,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Availability: ${driver['Availability'] ? 'Available' : 'Not Available'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () async {
                        bool currentAvailability = driver['Availability'];
                        bool? confirmChange = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Availability Change', style: TextStyle(fontSize: 16)),
                              content: Text(
                                currentAvailability
                                    ? 'Is the van leaving?'
                                    : 'Is the van returning?',
                                style: const TextStyle(fontSize: 14),
                              ),
                              actionsAlignment: MainAxisAlignment.end,
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('No', style: TextStyle(fontSize: 14, color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: const Text('Yes', style: TextStyle(fontSize: 14, color: Colors.black)),
                                ),
                              ],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            );
                          },
                        );
      
                        if (confirmChange == true) {
                          await FirebaseFirestore.instance
                              .collection('Driver')
                              .doc(driver.id)
                              .update({'Availability': !currentAvailability});
                        }
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
