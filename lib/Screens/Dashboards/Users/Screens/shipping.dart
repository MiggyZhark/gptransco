import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../components/shipping_image.dart';

class ShippingScreen extends StatefulWidget {
  const ShippingScreen({super.key});

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _isSensitive = 'False';
  String _selectedLocation = 'Palimbang';

  final List<String> sensitivityOptions = ['True', 'False'];
  final List<String> locationOptions = ['Palimbang', 'Maitum', 'Kiamba', 'Maasim'];

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gpBottomNavigationColorDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'My Package',
          style: headerTitle,
        ),
      ),
      body: Column(
        children: [
          const ShippingImage(),
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
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Package Information',
                    style: TextStyle(fontSize: 14),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(key: _formKey,
                      child: Column(
                        children: [
                          // First row: Product name and sensitivity
                          Row(
                            children: [
                              // Product Name TextField
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _productNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Product Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Product Name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Sensitive Dropdown
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  dropdownColor: gpPrimaryColor,
                                  decoration: InputDecoration(
                                    labelText: 'Fragile',
                                    border: OutlineInputBorder(),
                                  ),
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
                                  decoration: InputDecoration(
                                    labelText: 'Location',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedLocation,
                                  items: locationOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedLocation = newValue!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Price TextField
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.money),
                                    labelText: 'Price',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your Price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40,),
                          Row(mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.blueGrey),
                                          borderRadius: BorderRadius.circular(10))),
                                  onPressed: () {},
                                  child: Text('History',style: TextStyle(color: Colors.blue),)),
                              SizedBox(width: 15,),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: gpBottomNavigationColorDark),
                                          borderRadius: BorderRadius.circular(10))),
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {

                                    } else {
                                      // Optionally, you can show an error message or handle invalid input
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Please fill in the required fields')),
                                      );
                                    }
                                  },
                                  child: Text('Post',style: TextStyle(color: Colors.teal),)),
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
