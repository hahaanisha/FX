import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TrackingPagePro extends StatefulWidget {
  @override
  _TrackingPageProState createState() => _TrackingPageProState();
}

class _TrackingPageProState extends State<TrackingPagePro> {
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _steps = [];
  LatLng _userMarkerPosition = LatLng(19.22522171760112, 73.13721535914361);
  String _currentInstruction = "Start your journey!";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchRoute();
    _trackUserLocation(); // Start tracking GPS location
  }

  /// ✅ Request Location Permission
  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      print("Location permission denied");
    }
  }

  /// ✅ Fetch Route from API
  Future<void> _fetchRoute() async {
    String apiUrl =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62487f8c922db5d2436299573b80d1d942c9&start=73.13721535914361,19.22522171760112&end=73.12427761389138,19.229502308526033";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract route geometry (coordinates)
        List coordinates = data['features'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          _steps = List<Map<String, dynamic>>.from(data['features'][0]['properties']['segments'][0]['steps']);
        });
      } else {
        print("Failed to load route: ${response.body}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  /// ✅ Track Real-Time User Location
  void _trackUserLocation() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    ).listen((Position position) {
      setState(() {
        _userMarkerPosition = LatLng(position.latitude, position.longitude);
      });

      _updateStepInstruction(); // Update navigation instruction
    });
  }

  /// ✅ Find Closest Step & Update UI
  void _updateStepInstruction() {
    if (_steps.isEmpty) return;

    double minDistance = double.infinity;
    Map<String, dynamic>? closestStep;

    for (var step in _steps) {
      LatLng stepLocation = _getLatLngFromStep(step);
      double distance = Geolocator.distanceBetween(
        _userMarkerPosition.latitude,
        _userMarkerPosition.longitude,
        stepLocation.latitude,
        stepLocation.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestStep = step;
      }
    }

    if (closestStep != null) {
      _showInstruction(closestStep['instruction']);
    }
  }

  /// ✅ Convert Step to LatLng
  LatLng _getLatLngFromStep(Map<String, dynamic> step) {
    var waypoints = step['way_points'];
    if (waypoints.isNotEmpty) {
      int index = waypoints.first;
      if (index < _routePoints.length) {
        return _routePoints[index];
      }
    }
    return _userMarkerPosition;
  }

  /// ✅ Show Step Instruction in UI
  void _showInstruction(String instruction) {
    setState(() {
      _currentInstruction = instruction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live GPS Navigation")),
      body: Column(
        children: [
          /// 🚀 Instruction Display
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.blueAccent,
            child: Text(
              _currentInstruction,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          /// 🚀 Map with User Marker & Route
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _routePoints.isNotEmpty ? _routePoints[0] : LatLng(19.22522171760112, 73.13721535914361),
                maxZoom: 18.0,
              ),
              children: [
                // Map Tiles
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),

                // Route Polyline
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 5.0,
                      ),
                    ],
                  ),

                // User Location Marker
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _userMarkerPosition,
                      child: Icon(Icons.navigation, color: Colors.purple, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
