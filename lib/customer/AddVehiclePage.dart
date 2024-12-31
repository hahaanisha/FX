import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddVehiclePage extends StatelessWidget {
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();

  void _addVehicle() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('vehicles');
    String key = dbRef.push().key!;
    dbRef.child(_vehicleNumberController.text).set({
      'name': _vehicleNameController.text,
      'number': _vehicleNumberController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _vehicleNameController,
              decoration: InputDecoration(labelText: 'Vehicle Name'),
            ),
            TextField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(labelText: 'Vehicle Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addVehicle();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vehicle Added Successfully')),
                );
                Navigator.pop(context);
              },
              child: Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
