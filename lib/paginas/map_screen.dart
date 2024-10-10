import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'api_ops.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List listOfPoints = [];
  List<LatLng> points = [];
  String selectedMode = 'car'; // default mode

  @override
  void initState() {
    super.initState();
    getCoordinates();
  }

  void _onModeChanged(String mode) {
    setState(() {
      selectedMode = mode;
      getCoordinates();
    });
  }

  getCoordinates() async {
    var ini = '-0.04935, 39.98567';
    var fin = '0.0200804, 39.9811';
    var response;
    if (selectedMode == 'car') {
      response = await http.get(getCarRouteUrl(ini, fin));
    } else if (selectedMode == 'walk') {
      response = await http.get(getWalkRouteUrl(ini, fin));
    } else if (selectedMode == 'bike') {
      response = await http.get(getBikeRouteUrl(ini, fin));
    }

    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints.map((p) => LatLng(p[1].toDouble(), p[0].toDouble())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
        actions: [
          ToggleButtons(
            children: const <Widget>[
              Icon(Icons.directions_car),
              Icon(Icons.directions_walk),
              Icon(Icons.directions_bike),
            ],
            isSelected: [
              selectedMode == 'car',
              selectedMode == 'walk',
              selectedMode == 'bike',
            ],
            onPressed: (int index) {
              if (index == 0) {
                _onModeChanged('car');
              } else if (index == 1) {
                _onModeChanged('walk');
              } else if (index == 2) {
                _onModeChanged('bike');
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(39.98567, -0.04935),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(39.98567, -0.04935),
                width: 80,
                height: 80,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  color: Colors.green,
                  iconSize: 45.0,
                ),
              ),
              Marker(
                point: LatLng(39.9811, 0.0200804),
                width: 80,
                height: 80,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on),
                  color: Colors.red,
                  iconSize: 45.0,
                ),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
