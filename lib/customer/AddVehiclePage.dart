import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddVehiclePage extends StatelessWidget {
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();

  void _addVehicle(BuildContext context) {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('vehicles');
    String key = dbRef.push().key!;
    dbRef.child(_vehicleNumberController.text).set({
      'name': _vehicleNameController.text,
      'number': _vehicleNumberController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vehicle Added Successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Title
            Text(
              'Add a New Vehicle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Styled Input Fields
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
            SizedBox(height: 30),

            // Large Blue Button
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
    );
  }
}
