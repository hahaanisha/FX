import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../screens/mapScreen.dart';

class DriverPortal extends StatefulWidget {
  final dynamic UID;

  DriverPortal({super.key, required this.UID});

  @override
  _DriverPortalState createState() => _DriverPortalState();
}

class _DriverPortalState extends State<DriverPortal> {
  final _routeIdController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? responseRoute;
  List<dynamic> steps = [];
  int currentStepIndex = 0;

  Future<void> fetchAndSendRouteData(String routeId) async {
    try {
      // Fetch route data from Firebase using UID
      DataSnapshot routeSnapshot =
      await _dbRef.child('routes/${widget.UID}/$routeId').get();
      if (!routeSnapshot.exists) {
        throw Exception('Route ID not found');
      }

      Map<String, dynamic> routeData =
      Map<String, dynamic>.from(routeSnapshot.value as Map);
      String vehicleId = routeData['vehicleId'];

      // Prepare jobs and vehicles data
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
        "end": [routeData['nodes'][0]['longitude'], routeData['nodes'][0]['latitude']],
        "capacity": [100],
        "skills": [1]
      };

      Map<String, dynamic> optimizationData = {
        "jobs": jobs,
        "vehicles": [vehicles],
      };

      // Send data to ORS Optimization API
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
        print("API Response: ${json.encode(decodedResponse)}");

        // Check for expected structure
        if (decodedResponse.containsKey('routes') &&
            decodedResponse['routes'] is List &&
            decodedResponse['routes'].isNotEmpty &&
            decodedResponse['routes'][0] is Map &&
            decodedResponse['routes'][0].containsKey('steps') &&
            decodedResponse['routes'][0]['steps'] is List) {

          setState(() {
            responseRoute = decodedResponse;
            steps = decodedResponse['routes'][0]['steps'];
          });
        } else {
          throw Exception("Unexpected response structure from ORS API.");
        }
      } else {
        throw Exception('Failed to optimize route: ${response.body}');
      }
    } catch (error) {
      print("Error: $error");

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void navigateToNextStop() {
    if (currentStepIndex < steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });

      try {
        final start = steps[currentStepIndex - 1]['location'];
        final end = steps[currentStepIndex]['location'];

        if (start is List && end is List && start.length == 2 && end.length == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapsPage(
                sLat: start[1],
                sLong: start[0],
                eLat: end[1],
                eLong: end[0],
                vtype: 'driving-hgv',
              ),
            ),
          );
        } else {
          throw Exception("Invalid coordinates format.");
        }
      } catch (e) {
        print("Navigation Error: $e");
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Navigation Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Route Completed'),
          content: Text('You have completed all stops!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
              onPressed: () => fetchAndSendRouteData(_routeIdController.text.trim()),
              child: Text('Submit'),
            ),
            if (responseRoute != null) ...[
              SizedBox(height: 16),
              Text('Route Optimized Successfully!', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: navigateToNextStop,
                child: Text('Navigate'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    json.encode(responseRoute, toEncodable: (dynamic e) => e.toString()),
                    style: TextStyle(fontFamily: 'Courier', fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
