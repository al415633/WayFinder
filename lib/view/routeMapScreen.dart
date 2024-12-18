import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/view/map_screen.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterRoute.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterVehiculo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/view/carSelectionDialog.dart';

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
  late RouteMode routeMode;
  bool showInterestPlaces = false;
  bool showRoutes = true;
  bool showVehicles = false;
  double distance = 0.0;
  double estimatedTime = 0.0;
  FirestoreAdapterRoute routeAdapter = FirestoreAdapterRoute();
  VehicleController vehicleController =
      VehicleController.getInstance(FirestoreAdapterVehiculo());


  @override
  void initState() {
    super.initState();
    route = widget.route;
    transportMode = route.getTransportMode;
    routeMode = route.getRouteMode!;
    initialPoint = LatLng(route.getStart.getCoordinate().getLat,
        route.getStart.getCoordinate().getLong);
    destination = LatLng(route.getEnd.getCoordinate().getLat,
        route.getEnd.getCoordinate().getLong);
    points = [];
    fetchCoordinates();
  }

    void fetchCoordinates() async {
    setState(() {
      points = route.getPoints;
      distance = route.getDistance;
      estimatedTime = route.getTime;
      
      });

    
  }

  void _onTransportChanged(TransportMode newTransportMode) async {
    if ((transportMode == TransportMode.aPie ||
            transportMode == TransportMode.bicicleta) &&
        newTransportMode == TransportMode.coche) {
      // Esperar a que se complete la lista de vehículos
      Set<Vehicle> vehicleSet = await vehicleController.getVehicleList();
      List<Vehicle> vehicleList = vehicleSet.toList();

      showCarSelectionDialog(
        context,
        vehicleList, // Ahora pasas una lista válida
        (RouteMode selectedRouteMode, Vehicle selectedCar) {
          setState(() {
            routeMode = selectedRouteMode;
            transportMode = newTransportMode;

            // Actualizar el vehículo en la ruta
            route.setVehicle = selectedCar;

            // Actualizar la ruta
            RouteController routeController =
                RouteController.getInstance(routeAdapter);
            routeController.onTransportChanged(newTransportMode, route);

            transportMode = newTransportMode;
            fetchCoordinates();
          });
        },
      );
    } else {
      setState(() {
        RouteController routeController =
            RouteController.getInstance(routeAdapter);
        routeController.onTransportChanged(newTransportMode, route);
        transportMode = newTransportMode;
        fetchCoordinates();
      });
    }
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
                        Text('Coste: ${route.getCost.toStringAsFixed(2)} €'), // Mostrar el coste
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
                        UserAppController userAppController=UserAppController.getInstance();
                        userAppController.logOut();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                MiApp()), // Navega a la pantalla de inicio
                        (Route<dynamic> route) =>
                            false, // Elimina todas las rutas anteriores
                      );
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
