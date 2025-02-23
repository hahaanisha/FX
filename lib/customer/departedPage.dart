import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gehraneela/customer/trackingPage.dart';

class DepartedPage extends StatefulWidget {
  final String UID;

  DepartedPage({super.key, required this.UID});

  @override
  _DepartedPageState createState() => _DepartedPageState();
}

class _DepartedPageState extends State<DepartedPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> departedRoutes = [];

  @override
  void initState() {
    super.initState();
    fetchDepartedRoutes();
  }

  Future<void> fetchDepartedRoutes() async {
    try {
      DataSnapshot departedSnapshot =
      await _dbRef.child('departed/${widget.UID}').get();
      if (!departedSnapshot.exists) {
        return;
      }

      Map<String, dynamic> departedData =
      Map<String, dynamic>.from(departedSnapshot.value as Map);

      List<Map<String, dynamic>> routesList = [];
      departedData.forEach((routeId, routeDetails) {
        routesList.add({
          'routeId': routeId,
          'vehicleId': routeDetails['vehicleId'] ?? 'N/A',
          'orderId': routeDetails['orderId'] ?? 'N/A',
          'details': routeDetails,
        });
      });

      setState(() {
        departedRoutes = routesList;
      });
    } catch (error) {
      print('Error fetching departed routes: $error');
    }
  }

  void showRouteDetails(Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Route Details"),
        content: SingleChildScrollView(
          child: Text(details.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Departed Routes'),
      ),
      body: departedRoutes.isEmpty
          ? Center(child: Text("No Departed Routes"))
          : ListView.builder(
        itemCount: departedRoutes.length,
        itemBuilder: (context, index) {
          final route = departedRoutes[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Route ID: ${route['routeId']}'),
              subtitle: Text(
                  'Vehicle ID: ${route['vehicleId']}\nOrder ID: ${route['orderId']}'),
              onTap: () => showRouteDetails(route['details']),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TrackVehiclePage(routeId: route['routeId']),
                    ),
                  );
                },
                child: Text('Track Vehicle'),
              ),
            ),
          );
        },
      ),
    );
  }
}
