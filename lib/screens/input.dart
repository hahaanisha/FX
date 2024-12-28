import 'package:flutter/material.dart';
import 'package:gehraneela/screens/mapScreen.dart';


class LogisticsPage extends StatefulWidget {
  @override
  _LogisticsPageState createState() => _LogisticsPageState();
}

class _LogisticsPageState extends State<LogisticsPage> {
  final TextEditingController startLatController = TextEditingController();
  final TextEditingController startLngController = TextEditingController();
  final TextEditingController endLatController = TextEditingController();
  final TextEditingController endLngController = TextEditingController();

  // Checkboxes state
  bool isSmallCar = false;
  bool isHgv = false;

  void _navigateToMapPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => mapsPage(sLat: startLatController, sLong:startLngController, eLat:endLatController, eLong:endLngController)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logistics Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Fields for Latitude and Longitude
            TextField(
              controller: startLatController,
              decoration: InputDecoration(
                labelText: 'Start Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: startLngController,
              decoration: InputDecoration(
                labelText: 'Start Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: endLatController,
              decoration: InputDecoration(
                labelText: 'End Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            TextField(
              controller: endLngController,
              decoration: InputDecoration(
                labelText: 'End Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Checkboxes for Vehicle Type
            Text(
              'Select Vehicle Type:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Checkbox(
                  value: isSmallCar,
                  onChanged: (value) {
                    setState(() {
                      isSmallCar = value!;
                    });
                  },
                ),
                Text('Small Car'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: isHgv,
                  onChanged: (value) {
                    setState(() {
                      isHgv = value!;
                    });
                  },
                ),
                Text('HGV'),
              ],
            ),

            Spacer(),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToMapPage,
                child: Text('Proceed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

