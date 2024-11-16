import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../constants.dart';
import 'Shipment Details/Shipment_Details.dart';

class DispatcherShipping extends StatefulWidget {
  const DispatcherShipping({super.key});

  @override
  State<DispatcherShipping> createState() => _DispatcherShippingState();
}

class _DispatcherShippingState extends State<DispatcherShipping> {
  String? selectedTerminal;
  String? selectedDestination;
  List<String> destinations = [];

  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    final gensanSnapshot = await FirebaseFirestore.instance
        .collection('shippings')
        .doc('Gensan')
        .collection('packages')
        .get();

    final palimbangSnapshot = await FirebaseFirestore.instance
        .collection('shippings')
        .doc('Palimbang')
        .collection('packages')
        .get();

    final gensanDestinations = gensanSnapshot.docs
        .map((doc) => (doc.data())['destination'] as String?)
        .where((destination) => destination != null)
        .cast<String>()
        .toSet();

    final palimbangDestinations = palimbangSnapshot.docs
        .map((doc) => (doc.data())['destination'] as String?)
        .where((destination) => destination != null)
        .cast<String>()
        .toSet();

    final allDestinations = gensanDestinations.union(palimbangDestinations).toList();

    setState(() {
      destinations = allDestinations;
    });
  }

  Stream<List<QueryDocumentSnapshot>> _fetchPackages() {
    final gensanStream = FirebaseFirestore.instance
        .collection('shippings')
        .doc('Gensan')
        .collection('packages')
        .snapshots();

    final palimbangStream = FirebaseFirestore.instance
        .collection('shippings')
        .doc('Palimbang')
        .collection('packages')
        .snapshots();

    return gensanStream.asyncMap((gensanSnapshot) async {
      final palimbangSnapshot = await palimbangStream.first;
      return [...gensanSnapshot.docs, ...palimbangSnapshot.docs];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shipping Details',style: headerTitle,),
          backgroundColor: gpBottomNavigationColorDark,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(dropdownColor: Colors.white,
                    value: selectedTerminal,
                    hint: const Text('Select Terminal'),
                    items: <String>['Gensan', 'Palimbang']
                        .map((terminal) => DropdownMenuItem<String>(
                              value: terminal,
                              child: Text(terminal),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTerminal = value;
                      });
                    },
                  ),
                  DropdownButton<String>(dropdownColor: Colors.white,
                    value: selectedDestination,
                    hint: const Text('Select Destination'),
                    items: destinations
                        .map((destination) => DropdownMenuItem<String>(
                              value: destination,
                              child: Text(destination),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDestination = value;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: _fetchPackages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching packages'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No packages available'));
                    }
      
                    var packages = snapshot.data!;
      
                    packages = packages
                        .where((package) => (package.data() as Map<String, dynamic>)['status'] != 'accepted')
                        .toList();
      
                    if (selectedTerminal != null) {
                      packages = packages
                          .where((package) =>
                              (package.data() as Map<String, dynamic>)['terminal'] == selectedTerminal)
                          .toList();
                    }
      
                    if (selectedDestination != null) {
                      packages = packages
                          .where((package) =>
                              (package.data() as Map<String, dynamic>)['destination'] == selectedDestination)
                          .toList();
                    }
      
                    if (packages.isEmpty) {
                      return const Center(child: Text('No packages match the selected filters'));
                    }
      
                    packages.sort((a, b) {
                      final aStatus = (a.data() as Map<String, dynamic>)['status'] ?? '';
                      final bStatus = (b.data() as Map<String, dynamic>)['status'] ?? '';
                      if (aStatus == 'Pending' && bStatus != 'Pending') {
                        return -1;
                      } else if (aStatus != 'Pending' && bStatus == 'Pending') {
                        return 1;
                      } else {
                        return 0;
                      }
                    });
      
                    return ListView.builder(
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index].data() as Map<String, dynamic>;
      
                        String formattedDate = 'N/A';
                        if (package['timestamp'] != null) {
                          final timestamp = package['timestamp'] as Timestamp;
                          formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
                        }
      
                        return Card(color: Colors.white,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              package['imageUrl'] ?? 'https://via.placeholder.com/50',
                            ),
                            title: Text('Status: ${package['status'] ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Package Info: ${package['packageInfo'] ?? 'N/A'}'),
                                Text('Terminal: ${package['terminal'] ?? 'N/A'}'),
                                Text('Destination: ${package['destination'] ?? 'N/A'}'),
                                Text('Date and Time: $formattedDate'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShipmentDetailsScreen(
                                    shipmentDetails: package,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
