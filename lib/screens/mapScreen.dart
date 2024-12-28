import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'api.dart';


class mapsPage extends StatefulWidget {
  var sLat;
  var sLong;
  var eLat;
  var eLong;

  //final dynamic SLat;

  mapsPage({super.key,required this.sLat,required this.sLong, required this.eLat, required this.eLong});



  @override
  State<mapsPage> createState() => _mapsPageState();
}

class _mapsPageState extends State<mapsPage> {

  List listofPoints = [];

  List<LatLng> points =[];


  // var StartLat = 19.225129246202325;
  // var StartLong = 73.13747988067364;
  // var EndLat = 19.177908382850912;
  // var EndLong = 72.94566251056348;


  getCoordinates() async{
    var response = await http.get(getRouteUrl(widget.sLong.toString()+','+widget.sLat.toString(),widget.eLong.toString()+','+widget.eLat.toString()));

    setState(() {
      if(response.statusCode == 200){
        var data = jsonDecode(response.body);
        print(data);
        listofPoints = data['features'][0]['geometry']['coordinates'];
        points = listofPoints.map((e) => LatLng(e[1].toDouble(), e[0].toDouble())).toList();
        print(points);
      }
      else{
        print('error');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Maps'),
      ),
      body: Container(
        child: FlutterMap(
          options: MapOptions(
            initialZoom: 10,
            maxZoom: 30,
            initialCenter: LatLng(widget.sLat,widget.sLong),
            // initialCameraFit: ,
          ),
          // mapController: MapController(),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=fe7095d5cf2a4a26a88875a4bd375258',
              additionalOptions: {
                'style': '<your-map-style>',
                'apiKey': 'fe7095d5cf2a4a26a88875a4bd375258',
              },
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              // Plenty of other options available!
            ),
            //1st marker
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.sLat,widget.sLong),
                  width: 80,
                  height: 80,
                  child: Icon(Icons.location_on_rounded,color: Colors.red,size: 45,),
                ),
              ],
            ),
            //2nd marker
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.eLat,widget.eLong),
                  width: 80,
                  height: 80,
                  child: Icon(Icons.location_on_rounded,color: Colors.green,size: 45,),
                ),
              ],
            ),

            //polyline Layer
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getCoordinates();
          print('pressed');
        },
        child: Icon(Icons.navigation_outlined),
      ),
    );
  }
}
