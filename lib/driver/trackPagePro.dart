import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

class TrackingPagePro extends StatefulWidget {
  var slat;
  var slong;
  var elat;
  var elong;

  TrackingPagePro({super.key, required this.slat, required this.slong, required this.elat, required this.elong});

  @override
  _TrackingPageProState createState() => _TrackingPageProState();
}

class _TrackingPageProState extends State<TrackingPagePro> {
  final FlutterTts _flutterTts = FlutterTts();
  List<LatLng> _routePoints = [];
  List<Map<String, dynamic>> _steps = [];
  late LatLng _userMarkerPosition;
  LatLng? _previousPosition;
  double _markerRotation = 0.0;
  String _currentInstruction = "Start your journey!";
  double _remainingDistance = 0.0;
  String _eta = "--"; // Default ETA when speed is unknown

  @override
  void initState() {
    super.initState();
    _userMarkerPosition = LatLng(widget.slat, widget.slong);
    _requestLocationPermission();
    _fetchRoute();
    _trackUserLocation();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      print("Location permission denied");
    }
  }

  Future<void> _fetchRoute() async {
    String apiUrl =
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62487f8c922db5d2436299573b80d1d942c9&start=${widget.slong},${widget.slat}&end=${widget.elong},${widget.elat}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  void _trackUserLocation() {
    Geolocator.getPositionStream(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5))
        .listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      // Calculate bearing if a previous position exists
      if (_previousPosition != null) {
        double bearing = Geolocator.bearingBetween(
          _previousPosition!.latitude,
          _previousPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );

        setState(() {
          _markerRotation = (bearing * pi / 180); // Convert to radians for rotation
        });
      }

      // Update position and compute remaining distance & ETA
      setState(() {
        _userMarkerPosition = newPosition;
        _previousPosition = newPosition; // Update previous position
        _updateRemainingDistance();
        _updateETA(position.speed);
      });

      _updateStepInstruction();
    });
  }

  void _updateRemainingDistance() {
    _remainingDistance = Geolocator.distanceBetween(
      _userMarkerPosition.latitude,
      _userMarkerPosition.longitude,
      widget.elat,
      widget.elong,
    ) /
        1000; // Convert to kilometers
  }

  void _updateETA(double speed) {
    if (speed > 0) {
      double timeInMinutes = (_remainingDistance / (speed * 3.6)); // Speed in km/h
      setState(() {
        _eta = timeInMinutes.toStringAsFixed(1) + " min";
      });
    } else {
      setState(() {
        _eta = _remainingDistance > 0 ? "Calculating..." : "Arrived";
      });
    }
  }

  void _updateStepInstruction() {
    if (_steps.isEmpty) return;
    double minDistance = double.infinity;
    Map<String, dynamic>? closestStep;

    for (var step in _steps) {
      LatLng stepLocation = _getLatLngFromStep(step);
      double distance = Geolocator.distanceBetween(
          _userMarkerPosition.latitude, _userMarkerPosition.longitude, stepLocation.latitude, stepLocation.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        closestStep = step;
      }
    }

    if (closestStep != null) {
      _showInstruction(closestStep['instruction']);
      _flutterTts.speak(closestStep['instruction']);
    }
  }

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

  void _showInstruction(String instruction) {
    setState(() {
      _currentInstruction = instruction;
      _flutterTts.speak(instruction);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Live GPS Navigation")),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _currentInstruction,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "ETA: $_eta",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _routePoints.isNotEmpty ? _routePoints[0] : LatLng(widget.slat, widget.slong),
                maxZoom: 18.0,
                initialZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _routePoints, color: Colors.blue, strokeWidth: 5.0),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _userMarkerPosition,
                      child: Transform.rotate(
                        angle: _markerRotation, // Rotate marker based on user heading
                        child: Icon(Icons.navigation, color: Colors.purple, size: 40),
                      ),
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
