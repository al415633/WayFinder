import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/view/map_screen.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteMapScreen extends StatefulWidget {
  final Routes route;

  const RouteMapScreen({super.key, required this.route});

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late Routes route;
  late LatLng initialPoint;
  late LatLng destination;
  late List<LatLng> points;
  late TransportMode transportMode;
  bool showInterestPlaces = false;
  bool showRoutes = true;
  bool showVehicles = false;
  double distance = 0.0;
  double estimatedTime = 0.0;
  double cost = 0.0;
  FirestoreAdapterRoute routeAdapter = FirestoreAdapterRoute();
  FirestoreAdapterVehiculo vehicleAdapter = FirestoreAdapterVehiculo();


  @override
  void initState() {
    super.initState();
    route = widget.route;
    transportMode = route.getTransportMode;
    initialPoint = LatLng(route.getStart.getCoordinate().getLat,
        route.getStart.getCoordinate().getLong);
    destination = LatLng(route.getEnd.getCoordinate().getLat,
        route.getEnd.getCoordinate().getLong);
    points = [];
    fetchCoordinates();
  }

    void fetchCoordinates() async {
    var result = await RouteController.getInstance(routeAdapter).getPoints(initialPoint, destination, transportMode);
    setState(() {
      points = result['points'];
      distance = result['distance'];
      estimatedTime = result['duration'];
      print('Distance: $distance, Estimated Time: $estimatedTime'); // Debugging statement
      
      });

      if (transportMode == TransportMode.aPie || transportMode == TransportMode.bicicleta){
        try{
          route.setCalories = RouteController.getInstance(routeAdapter).calculateCostKCal(route);
        }catch (e){
          route.setCalories = 0.0;
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al calcular calorías: $e')),
          );
        }
      } else if (transportMode == TransportMode.coche){
          cost = await VehicleController.getInstance(vehicleAdapter).calculatePrice(route, route.getVehicle!);      }
  }

  void calculateDistanceAndTime() {
    distance = RouteController.getInstance(routeAdapter).calculateDistance(points);
    widget.route.setDistance = distance;
    estimatedTime = RouteController.getInstance(routeAdapter).calculateTime(transportMode, distance);
    widget.route.setTime = estimatedTime;
  }


  void _onTransportChanged(TransportMode newTransportMode) {
    setState(() {
      transportMode = newTransportMode;
      widget.route.setTransportMode = transportMode;
      fetchCoordinates();
    });
  }

  void _onModeChanged(String mode) {
    setState(() {
      showInterestPlaces = false;
      showRoutes = false;
      showVehicles = false;
      if (mode == 'routes') {
        showRoutes = true;
      } else if (mode == 'locations') {
        showInterestPlaces = true;
      } else if (mode == 'vehicles') {
        showVehicles = true;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(),
        ),
      );
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
                  _buildTopButton('Lugares de interés', () {
                    _onModeChanged('locations');
                  }),
                  _buildTopButton('Rutas', () {
                    _onModeChanged('routes');
                  }),
                  _buildTopButton('Vehículos', () {
                    _onModeChanged('vehicles');
                  }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ToggleButtons(
                  isSelected: [
                    transportMode == TransportMode.coche,
                    transportMode == TransportMode.aPie,
                    transportMode == TransportMode.bicicleta,
                  ],
                  onPressed: (int index) {
                    if (index == 0) {
                      _onTransportChanged(TransportMode.coche);
                    } else if (index == 1) {
                      _onTransportChanged(TransportMode.aPie);
                    } else if (index == 2) {
                      _onTransportChanged(TransportMode.bicicleta);
                    }
                  },
                  children: const <Widget>[
                    Icon(Icons.directions_car),
                    Icon(Icons.directions_walk),
                    Icon(Icons.directions_bike),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Distancia: ${distance < 1 ? '${(distance * 1000).toStringAsFixed(0)} m' : '${distance.toStringAsFixed(2)} km'}'),
                    Text(
                      'Tiempo estimado: ${estimatedTime < 1 ? '${(estimatedTime * 60).toStringAsFixed(0)} minutos' : '${estimatedTime.toStringAsFixed(2)} horas'}'),
                      if (transportMode == TransportMode.aPie || transportMode == TransportMode.bicicleta)
                        Text('Calorías: ${route.getCalories.toStringAsFixed(0)} kcal'),
                      if (transportMode == TransportMode.coche)
                        Text('Coste: ${cost.toStringAsFixed(2)} €'), // Mostrar el coste
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
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
                      points: points
                          .map((point) =>
                              LatLng(point.latitude, point.longitude))
                          .toList(),
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
  Widget _buildTopButton(
      String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }
}
