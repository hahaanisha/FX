import 'package:flutter/material.dart';

import 'AddRoutePage.dart';
import 'AddVehiclePage.dart';


class AdminPortal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddVehiclePage()),
                );
              },
              child: Text('Add New Vehicle'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRoutePage()),
                );
              },
              child: Text('Add New Route'),
            ),
          ],
        ),
      ),
    );
  }
}
