import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // For real-time location tracking
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
  int currentStepIndex = 0;
  LatLng? driverLocation;
  StreamSubscription<Position>? positionStream;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    getCoordinates();
    startTrackingLocation();
  }

  // Fetch route data
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
        List listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((e) => LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble()))
            .toList();

        steps = (data['features'][0]['properties']['segments'][0]['steps'] as List)
            .map((step) => {
          'instruction': step['instruction'],
          'distance': (step['distance'] as num).toDouble(),
          'duration': (step['duration'] as num).toDouble(),
        })
            .toList();
      });
    } else {
      print('Error fetching route');
    }
  }

  // Start tracking the driver's real-time location
  void startTrackingLocation() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2, // Update location every 2 meters
      ),
    ).listen((Position position) {
      setState(() {
        driverLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController.move(driverLocation!, 16.0); // Move map with driver
    });
  }

  // Move to the next step in navigation
  void moveToNextStep() {
    if (currentStepIndex < steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });

      // Move to the next navigation step location
      _mapController.move(points[currentStepIndex], 16.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have reached the destination!')),
      );
    }
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialZoom: 15,
                initialCenter: LatLng(widget.sLat, widget.sLong),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=fe7095d5cf2a4a26a88875a4bd375258',
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
                    // Driver's real-time location marker
                    if (driverLocation != null)
                      Marker(
                        point: driverLocation!,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.directions_car, color: Colors.blue, size: 35),
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
          if (steps.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.directions, color: Colors.blue),
                    title: Text(steps[currentStepIndex]['instruction']),
                    subtitle: Text(
                        "Distance: ${steps[currentStepIndex]['distance']}m | Duration: ${steps[currentStepIndex]['duration']}s"),
                  ),
                  ElevatedButton(
                    onPressed: moveToNextStep,
                    child: const Text('Next Step'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
