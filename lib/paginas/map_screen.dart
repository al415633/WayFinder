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

  //openrouteservice api key
  getCoordinates() async {
    var response =
        await http.get(getCarRouteUrl('-0.04935,39.98567', '0.0200804,39.9811'));

    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        //las coordenadas intermedias de un punto a otro
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        //las coordenadas en el formato longitud, latitud que necesita el openrouteservice
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              //primer marcador
              Marker(
                  point: LatLng(39.98567, -0.04935),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.location_on),
                    color: Colors.green,
                    iconSize: 45.0,
                  )),
              //segundo marcador
              Marker(
                  point: LatLng(39.9811, 0.0200804),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.location_on),
                    color: Colors.red,
                    iconSize: 45.0,
                  )),
            ],
          ),
          // polyline layer, muestra la ruta calculada por ops
          PolylineLayer(
            polylines: [
              Polyline(
                points: points, //los que hemos creado antes para el ops
                color: Colors.blue,
                strokeWidth: 4.0
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => getCoordinates(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
