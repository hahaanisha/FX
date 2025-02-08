import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddDriverPage extends StatefulWidget {
  @override
  _AddDriverPageState createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  bool _isAvailable = true;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('drivers');

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitDriver() async {
    if (_driverNameController.text.isNotEmpty &&
        _licenseNumberController.text.isNotEmpty &&
        _contactNumberController.text.isNotEmpty &&
        _image != null) {
      final String customKey = _licenseNumberController.text.replaceAll(' ', '_');

      await _dbRef.child(customKey).set({
        "name": _driverNameController.text,
        "licenseNumber": _licenseNumberController.text,

        "contactNumber": _contactNumberController.text,
        "isAvailable": _isAvailable,
        "imagePath": _image!.path, // Store local path (consider a different approach if needed)
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver added successfully!')),
      );

      setState(() {
        _driverNameController.clear();
        _licenseNumberController.clear();

        _contactNumberController.clear();
        _isAvailable = true;
        _image = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and add an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Driver',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _driverNameController,
              decoration: InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _licenseNumberController,
              decoration: InputDecoration(
                labelText: 'License Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            SizedBox(height: 10),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text("Available for Duty"),
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDriver,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Add Driver',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
