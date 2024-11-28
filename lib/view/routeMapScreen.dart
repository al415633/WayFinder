import 'dart:convert';
import 'package:WayFinder/APIs/apiConection.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/view/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RouteMapScreen extends StatefulWidget {
  final Routes route;

  const RouteMapScreen({super.key, required this.route});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late LatLng initialPoint;
  late LatLng destination;
  late List<LatLng> points;
  late bool selectInitialPoint;
  late bool selectDestination;
  late String transportMode;
  bool showInterestPlaces = false; 
  bool showRoutes = true; 

  @override
  void initState() {
    super.initState();
    transportMode = widget.route.getTransportMode();
    Coordinate start = widget.route.getStart().getCoordinate();
    Coordinate end = widget.route.getEnd().getCoordinate();
    initialPoint = LatLng(start.getLat(), start.getLong());
    destination = LatLng(end.getLat(), end.getLong());
    points = [];
    selectInitialPoint = false;
    selectDestination = false;
    getCoordinates();
  }

  void getCoordinates() async {
    var ini = '${initialPoint.longitude}, ${initialPoint.latitude}';
    var fin = '${destination.longitude}, ${destination.latitude}';
    http.Response? response;
    if (transportMode == 'Coche') {
      response = await http.get(getCarRouteUrl(ini, fin));
    } else if (transportMode == 'A pie') {
      response = await http.get(getWalkRouteUrl(ini, fin));
    } else if (transportMode == 'Bicicleta') {
      response = await http.get(getBikeRouteUrl(ini, fin));
    }
    setState(() {
      if (response?.statusCode == 200) {
        var data = jsonDecode(response!.body);
        var listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map<LatLng>((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
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

  void _onTransportChanged(String newTransportMode) {
    setState(() {
      transportMode = newTransportMode;
      widget.route.setTransportMode(newTransportMode);
      getCoordinates();
    });
  }

    void _onModeChanged(String mode) {
    setState(() {
      if (mode == 'locations') {
        showInterestPlaces = true; // Muestra el panel lateral
        showRoutes = false; // Muestra el panel lateral de rutas
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(),
          ),
        );
      } else if (mode == 'routes') {
      showRoutes = true; // Muestra el panel lateral de rutas
      showInterestPlaces = false; // Oculta el panel lateral de lugares
    } else {
      showInterestPlaces = false; // Oculta ambos paneles
      showRoutes = false;
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Color(0xFF99D2E5),
        elevation: 0,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botones de la barra superior
              Row(
                children: [
                  _buildTopButton('Lugares de interés', transportMode == 'locations', () {
                    _onModeChanged('locations');
                  }),
                  _buildTopButton('Rutas', transportMode == 'routes', () {
                    _onModeChanged('routes');
                  }),
                  _buildTopButton('Vehículos', transportMode == 'vehicles', () {
                    _onModeChanged('vehicles');
                  }),
                ],
              ),
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
                  child: Text('Cambia el origen'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Cambia el destino'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ToggleButtons(
              isSelected: [
                transportMode == 'Coche',
                transportMode == 'A pie',
                transportMode == 'Bicicleta',
              ],
              onPressed: (int index) {
                if (index == 0) {
                  _onTransportChanged('Coche');
                } else if (index == 1) {
                  _onTransportChanged('A pie');
                } else if (index == 2) {
                  _onTransportChanged('Bicicleta');
                }
              },
              children: const <Widget>[
                Icon(Icons.directions_car),
                Icon(Icons.directions_walk),
                Icon(Icons.directions_bike),
              ],
            ),
          ),
          Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white,),
                    onPressed: () {
                      _onModeChanged('settings');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      _onModeChanged('reload');
                    },
                  ),
                ],
              ),


            ],
          ),
        ),
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

    // Botón superior personalizado
  Widget _buildTopButton(String label, bool isSelected, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? const Color.fromARGB(71, 203, 220, 228) :  Color.fromARGB(0, 153, 210, 229),
          foregroundColor: Colors.white  ,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }


   // Widget para cada lugar de interés
  Widget _buildInterestPlaceItem(String placeName) {
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.yellow),
      title: Text(placeName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('Eliminar $placeName');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              print('Editar $placeName');
            },
          ),
        ],
      ),
    );
  }
}
