import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trackingPage.dart';  // Import the tracking page

class DriverPortal extends StatefulWidget {
  final dynamic UID;

  DriverPortal({super.key, required this.UID});

  @override
  _DriverPortalState createState() => _DriverPortalState();
}

class _DriverPortalState extends State<DriverPortal> {
  final _routeIdController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<dynamic> steps = [];
  int currentStepIndex = 0;

  Future<void> fetchAndSendRouteData(String routeId) async {
    try {
      DataSnapshot routeSnapshot =
      await _dbRef.child('routes/${widget.UID}/$routeId').get();
      if (!routeSnapshot.exists) {
        throw Exception('Route ID not found');
      }

      Map<String, dynamic> routeData =
      Map<String, dynamic>.from(routeSnapshot.value as Map);

      // Copy route data to 'departed' table
      await _dbRef.child('departed/${widget.UID}/$routeId').set(routeData);

      List<Map<String, dynamic>> jobs = [];
      for (var i = 0; i < routeData['nodes'].length; i++) {
        final node = routeData['nodes'][i];
        if (node['type'] == 'stop' || node['type'] == 'drop') {
          jobs.add({
            "id": i + 1,
            "service": 300,
            "delivery": [1],
            "location": [node['longitude'], node['latitude']],
            "skills": [1]
          });
        }
      }

      Map<String, dynamic> vehicles = {
        "id": 1,
        "profile": "driving-car",
        "start": [routeData['nodes'][0]['longitude'], routeData['nodes'][0]['latitude']],
        "end": [routeData['nodes'].last['longitude'], routeData['nodes'].last['latitude']],
        "capacity": [100],
        "skills": [1]
      };

      Map<String, dynamic> optimizationData = {
        "jobs": jobs,
        "vehicles": [vehicles],
      };

      final response = await http.post(
        Uri.parse('https://api.openrouteservice.org/optimization'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '5b3ce3597851110001cf62487f8c922db5d2436299573b80d1d942c9',
        },
        body: json.encode(optimizationData),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        setState(() {
          steps = decodedResponse['routes'][0]['steps'];
        });

        // Navigate to tracking page with steps
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackingPage(steps: steps),
          ),
        );
      } else {
        throw Exception('Failed to optimize route: ${response.body}');
      }
    } catch (error) {
      showErrorDialog("Error", error.toString());
    }
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Portal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _routeIdController,
              decoration: InputDecoration(
                labelText: 'Enter Route ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  fetchAndSendRouteData(_routeIdController.text.trim()),
              child: Text('Start Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}
