import 'package:flutter/material.dart';
import '../../../../../constants.dart';
import '../../../components/message_screen.dart';
import 'homecard_slider.dart';

class VanPage extends StatelessWidget {
  final CardItem item;

  const VanPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Van Details',
            style: headerTitle,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 5 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image(
                      image: item.urlImage.startsWith('http')
                          ? NetworkImage(item.urlImage)
                          : AssetImage(item.urlImage) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      'Vehicle Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    VehicleInfoRow(
                      icon: Icons.directions_car,
                      label: 'Plate Number',
                      value: item.plateNumber, // replace with your data
                    ),
                    VehicleInfoRow(
                      icon: Icons.local_gas_station,
                      label: 'Fuel Type',
                      value: item.fuelType, // replace with your data
                    ),
                    VehicleInfoRow(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: item.address, // replace with your data
                    ),
                    VehicleInfoRow(
                      icon: Icons.phone,
                      label: 'Mobile Number',
                      value: item.mobileNumber, // replace with your data
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Color(0xFF07917C),
                                        Color(0xFF0CB39B),
                                        Color(0xFF06BAA4)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 14),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 70),
                                  ),
                                  onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MessageScreen(
                                                receiverUid: item.uid,
                                                senderUid: item.senderUid,
                                                profileImage:
                                                    item.senderProfile,
                                                name: item.title,
                                              ))),
                                  child: const Text(
                                    'Send a Message',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VehicleInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 28),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
