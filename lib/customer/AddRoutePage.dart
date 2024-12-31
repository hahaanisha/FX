import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';



class AdminPortalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AddRoutePage(),
    );
  }
}

class AddRoutePage extends StatefulWidget {
  @override
  _AddRoutePageState createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _timeWindowController = TextEditingController();
  String _natureOfDestination = 'Drop';

  final List<Map<String, dynamic>> _nodes = [];
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('routes');

  void _addNode() {
    if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty) {
      setState(() {
        _nodes.add({
          "latitude": double.parse(_latController.text),
          "longitude": double.parse(_lngController.text),
          "timeWindow": _timeWindowController.text.isNotEmpty
              ? _timeWindowController.text
              : null,
          "nature": _natureOfDestination,
          "type": _nodes.isEmpty ? "start" : "stop",
        });

        // Clear fields after adding
        _latController.clear();
        _lngController.clear();
        _timeWindowController.clear();
        _natureOfDestination = 'Drop';
      });
    }
  }

  void _submitRoute() async {
    if (_routeNameController.text.isNotEmpty &&
        _vehicleIdController.text.isNotEmpty &&
        _orderIdController.text.isNotEmpty &&
        _nodes.isNotEmpty) {
      final String customKey =
      'ROU${_orderIdController.text}V${_vehicleIdController.text}'
          .replaceAll(' ', '_');

      await _dbRef.child(customKey).set({
        "routeName": _routeNameController.text,
        "vehicleId": _vehicleIdController.text,
        "orderId": _orderIdController.text,
        "nodes": _nodes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route added successfully!')),
      );

      // Clear all inputs and list
      setState(() {
        _routeNameController.clear();
        _vehicleIdController.clear();
        _orderIdController.clear();
        _nodes.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields and add stops.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal - Create Route'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(labelText: 'Route Name'),
            ),
            TextField(
              controller: _vehicleIdController,
              decoration: InputDecoration(labelText: 'Vehicle ID'),
            ),
            TextField(
              controller: _orderIdController,
              decoration: InputDecoration(labelText: 'Order ID'),
            ),
            SizedBox(height: 20),
            Text(
              'Add Start/Stops:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _latController,
              decoration: InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _lngController,
              decoration: InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _timeWindowController,
              decoration: InputDecoration(
                  labelText: 'Time Window (Optional, e.g., 10:00-12:00)'),
            ),
            DropdownButton<String>(
              value: _natureOfDestination,
              onChanged: (String? newValue) {
                setState(() {
                  _natureOfDestination = newValue!;
                });
              },
              items: <String>['Drop', 'Pickup', 'Break']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: _addNode,
              child: Text('Add Job'),
            ),
            SizedBox(height: 20),
            Text(
              'Added Stops:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _nodes.length,
              itemBuilder: (context, index) {
                final node = _nodes[index];
                return ListTile(
                  title: Text(
                      '(${node['latitude']}, ${node['longitude']}) - ${node['type']}'),
                  subtitle: Text(
                      'Time Window: ${node['timeWindow'] ?? "N/A"}, Nature: ${node['nature']}'),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRoute,
              child: Text('Submit Route'),
            ),
          ],
        ),
      ),
    );
  }
}
