import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

class MapsPage extends StatefulWidget {
  final double sLat;
  final double sLong;
  final double eLat;
  final double eLong;
  final String vtype;

  MapsPage({
    super.key,
    required this.sLat,
    required this.sLong,
    required this.eLat,
    required this.eLong,
    required this.vtype,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<LatLng> points = [];
  List<Map<String, dynamic>> steps = [];
  LatLng? vehicleLocation; // Vehicle's real-time location
  String currentNavigation = "Fetching route...";
  Timer? locationUpdateTimer;

  Future<void> getCoordinates() async {
    var response = await http.get(
      getRouteUrl(
        "${widget.sLong},${widget.sLat}",
        "${widget.eLong},${widget.eLat}",
        widget.vtype,
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      setState(() {
        // Extract coordinates for route
        List listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((e) => LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble()))
            .toList();

        // Extract navigation steps safely
        steps = (data['features'][0]['properties']['segments'][0]['steps'] as List)
            .map((step) {
          var wayPoints = step['way_points'] ?? []; // Ensure it’s a list
          LatLng? stepLocation;

          if (wayPoints.isNotEmpty && wayPoints[0] is List && wayPoints[0].length >= 2) {
            stepLocation = LatLng(
              (wayPoints[0][1] as num).toDouble(),
              (wayPoints[0][0] as num).toDouble(),
            );
          } else {
            stepLocation = LatLng(widget.sLat, widget.sLong); // Default fallback
          }

          return {
            'instruction': step['instruction'],
            'distance': (step['distance'] as num).toDouble(),
            'duration': (step['duration'] as num).toDouble(),
            'location': stepLocation,
          };
        }).toList();

        // Initialize vehicle location at start point
        vehicleLocation = LatLng(widget.sLat, widget.sLong);
        currentNavigation = "Starting navigation...";

        // Start real-time location updates
        startTrackingVehicle();
      });

      print("Route Points: $points");
      print("Navigation Steps: $steps");
    } else {
      print('Error fetching route: ${response.body}');
    }
  }


  void startTrackingVehicle() {
    locationUpdateTimer?.cancel();
    locationUpdateTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      updateVehicleLocation();
    });
  }

  void updateVehicleLocation() {
    // Simulating real-time movement (Replace with real GPS data)
    if (points.isNotEmpty) {
      setState(() {
        int nextIndex = points.indexWhere((point) =>
        vehicleLocation == null ||
            (point.latitude > vehicleLocation!.latitude));

        if (nextIndex != -1 && nextIndex < points.length - 1) {
          vehicleLocation = points[nextIndex];
          updateNavigationInstructions();
        }
      });
    }
  }

  void updateNavigationInstructions() {
    for (var step in steps) {
      double distanceToStep = Distance().as(
          LengthUnit.Meter, vehicleLocation!, step['location'] as LatLng);

      if (distanceToStep < 50) { // If vehicle is near a step (50m)
        setState(() {
          currentNavigation = step['instruction'];
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Navigation')),
      body: Column(
        children: [
          // Navigation Instruction Display
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: Colors.black,
            child: Text(
              currentNavigation,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          // Map Display
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialZoom: 12,
                maxZoom: 30,
                initialCenter: LatLng(widget.sLat, widget.sLong),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=fe7095d5cf2a4a26a88875a4bd375258',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(
                  markers: [
                    // Source Marker
                    Marker(
                      point: LatLng(widget.sLat, widget.sLong),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                    // Destination Marker
                    Marker(
                      point: LatLng(widget.eLat, widget.eLong),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.green, size: 45),
                    ),
                    // Vehicle Real-Time Location Marker
                    if (vehicleLocation != null)
                      Marker(
                        point: vehicleLocation!,
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.directions_car,
                            color: Colors.blue, size: 40),
                      ),
                  ],
                ),
                // Polyline Route
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      color: Colors.purple,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation Steps Display
          if (steps.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  var step = steps[index];
                  return ListTile(
                    leading: const Icon(Icons.directions, color: Colors.blue),
                    title: Text(step['instruction']),
                    subtitle: Text(
                        "Distance: ${step['distance']}m | Duration: ${step['duration']}s"),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getCoordinates,
        child: const Icon(Icons.navigation_outlined),
      ),
    );
  }
}
