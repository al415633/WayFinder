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
  String selectedMode = 'car'; // por defecto
  LatLng initialPoint = LatLng(39.98567, -0.04935); // por defecto
  LatLng destination = LatLng(39.9811, 0.0200804); // por defecto
  bool selectInitialPoint = false;
  bool selectDestination = false;

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
    var ini = '${initialPoint.longitude}, ${initialPoint.latitude}';
    var fin = '${destination.longitude}, ${destination.latitude}';
    http.Response? response;
    if (selectedMode == 'car') {
      response = await http.get(getCarRouteUrl(ini, fin));
    } else if (selectedMode == 'walk') {
      response = await http.get(getWalkRouteUrl(ini, fin));
    } else if (selectedMode == 'bike') {
      response = await http.get(getBikeRouteUrl(ini, fin));
    }

    setState(() {
      if (response?.statusCode == 200) {
        var data = jsonDecode(response!.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints.map((p) => LatLng(p[1].toDouble(), p[0].toDouble())).toList();
      }
    });
  }

  void _onMapTap(LatLng latlng) {
    setState(() {
      if (selectInitialPoint) {
        initialPoint = latlng;
        selectInitialPoint = false;
      } else if (selectDestination) {
        destination = latlng;
        selectDestination = false;
      }
      getCoordinates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ToggleButtons(
              isSelected: [
                selectInitialPoint,
                selectDestination,
              ],
              onPressed: (int index) {
                setState(() {
                  if (index == 0) {
                    selectInitialPoint = !selectInitialPoint;
                    if (selectInitialPoint) selectDestination = false;
                  } else if (index == 1) {
                    selectDestination = !selectDestination;
                    if (selectDestination) selectInitialPoint = false;
                  }
                });
              },
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Selecciona Origen'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Selecciona Destino'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ToggleButtons(
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
            children: const <Widget>[
              Icon(Icons.directions_car),
              Icon(Icons.directions_walk),
              Icon(Icons.directions_bike),
            ],
          ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: initialPoint,
                initialZoom: 13.0,
                onTap: (tapPosition, point) => _onMapTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: initialPoint,
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
                      point: destination,
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
          ),
        ],
      ),
    );
  }
}
