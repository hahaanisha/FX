import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'navbarC.dart';

class AddVehiclePage extends StatefulWidget {
  final dynamic UID;

  const AddVehiclePage({super.key, required this.UID});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();

  String _selectedVehicleType = 'Driving-HGV'; // Default selection

  void _addVehicle(BuildContext context) {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('vehicles');
    String key = dbRef.push().key!;
    dbRef.child(widget.UID).child(_vehicleNumberController.text).set({
      'name': _vehicleNameController.text,
      'number': _vehicleNumberController.text,
      'type': _selectedVehicleType,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle Added Successfully')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Bottomnavbar(UID: widget.UID,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Add a New Vehicle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _vehicleNameController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _vehicleNumberController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Type:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text('Driving-HGV'),
                    leading: Radio<String>(
                      value: 'Driving-HGV',
                      groupValue: _selectedVehicleType,
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Tempo6'),
                    leading: Radio<String>(
                      value: 'Driving Car',
                      groupValue: _selectedVehicleType,
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addVehicle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Vehicle',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
