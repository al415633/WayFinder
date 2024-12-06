import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/view/addRouteDialog.dart';
import 'package:WayFinder/view/addVehicleDialog.dart';
import 'package:WayFinder/view/addLocationDialog.dart';
import 'package:WayFinder/view/routeMapScreen.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List listOfPoints = [];
  List<LatLng> points = [];
  TransportMode transportMode = TransportMode.coche; // por defecto
  LatLng initialPoint = LatLng(39.98567, -0.04935); // por defecto
  bool showInterestPlaces = false;
  bool showRoutes = false;
  bool showVehicles = false;
  bool isSelectingLocation =
      false; // Nuevo estado para habilitar la selección en el mapa
  String? locationName;
  final LocationController locationController =
      LocationController.getInstance(FirestoreAdapterLocation());
  List<Location> locations = [];
  List<Routes> routes = [];
  final RouteController routeController =
      RouteController.getInstance(FirestoreAdapterRoute());
  String? routeName;
  final VehicleController vehicleController =
      VehicleController(FirestoreAdapterVehiculo());
  List<Vehicle> vehicles = [];
  UserAppController? userAppController = UserAppController.getInstance();

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchRoutes();
    _fetchVehicles();
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
                  _buildTopButton(
                      'Lugares de interés', transportMode == 'locations', () {
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
                      userAppController?.logOut();

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Inicio()), // Navega a la pantalla de inicio
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
      body: Stack(
        children: [
          _buildFlutterMap(),
          if (showInterestPlaces)
            _buildSidePanel(
                'Lugares de interés',
                locations,
                (item) => _buildLocationItem(item as Location),
                () => showAddLocationDialog(context, _onLocationSelected)),
          if (showRoutes)
            _buildSidePanel(
                'Rutas',
                routes,
                (item) => _buildRouteItem(item as Routes),
                () => showAddRouteDialog(context, locations, _onRouteSelected)),
          if (showVehicles)
            _buildSidePanel(
                'Vehículos',
                vehicles,
                (item) => _buildVehicleItem(item as Vehicle),
                () => showAddVehicleDialog(context, _onVehicleSelected)),
        ],
      ),
    );
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
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
      ],
    );
  }

  Future<void> _onLocationSelected(String alias, String? toponym) async {
    if (toponym == null) {
      setState(() {
        locationName = alias; // Guardar el nombre del lugar
        isSelectingLocation = true; // Activar modo de selección
      });
      // Mostrar mensaje para guiar al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una ubicación en el mapa.')),
      );
    } else {
      try {
        await locationController.createLocationFromTopo(toponym, alias);
        _fetchLocations(); // Actualizar la lista de ubicaciones
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación guardada exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la ubicación: $e')),
        );
      }
    }
  }

  Future<void> _onVehicleSelected(String name, String fuelType,
      double consumption, String numberPlate) async {
    try {
      await vehicleController.createVehicle(
          numberPlate, consumption, fuelType, name);
      _fetchVehicles(); // Actualizar la lista de vehículos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo guardado exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el vehículo: $e')),
      );
    }
  }

  Future<void> _onRouteSelected(String name, Location start, Location end,
      TransportMode transportMode, RouteMode routeMode, bool save) async {
    late Routes route;
    try {
      route = await routeController.createRoute(
          name, start, end, transportMode, routeMode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear la ruta: $e')),
      );
    }
    try {
      if (save) {
        routeController.saveRoute(route);
        _fetchRoutes(); // Actualizar la lista de rutas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta guardada exitosamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la ubicación: $e')),
      );
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouteMapScreen(route: route),
      ),
    );
  }

  Widget _buildSidePanel(String title, List items,
      Widget Function(dynamic) buildItem, VoidCallback onAddPressed) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 250,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ...items.map((item) => buildItem(item)),
                  IconButton(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Botón superior personalizado
  Widget _buildTopButton(
      String label, bool isSelected, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? const Color.fromARGB(71, 203, 220, 228)
              : Color.fromARGB(0, 153, 210, 229),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }

  void _onModeChanged(String mode) {
    setState(() {
      //transportMode = mode;
      if (mode == 'locations') {
        showInterestPlaces = true; // Muestra el panel lateral
        showRoutes = false; // Muestra el panel lateral de rutas
        showVehicles = false;
      } else if (mode == 'routes') {
        showRoutes = true; // Muestra el panel lateral de rutas
        showInterestPlaces = false; // Oculta el panel lateral de lugares
        showVehicles = false;
      } else if (mode == 'vehicles') {
        showRoutes = false;
        showInterestPlaces = false;
        showVehicles = true;
      } else {
        showInterestPlaces = false; // Oculta ambos paneles
        showRoutes = false;
        showVehicles = false;
      }
    });
  }

  // Método para manejar el evento de clic en el mapa
  Future<void> _onMapTap(LatLng latlng) async {
    if (isSelectingLocation) {
      setState(() {
        initialPoint = latlng; // Guardar las coordenadas seleccionadas
        isSelectingLocation = false; // Salir del modo de selección
      });

      if (locationName == null || locationName!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('El nombre del lugar no puede estar vacío.')),
        );
        return;
      }

      // Llamar al LocationController para guardar la ubicación
      try {
        await locationController.createLocationFromCoord(
          initialPoint.latitude,
          initialPoint.longitude,
          locationName!,
        );
        _fetchLocations(); // Actualizar la lista de ubicaciones
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación guardada exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Widget para cada lugar de interés
  Widget _buildLocationItem(Location location) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          location.getFav() ? Icons.star : Icons.star_border,
          color: location.getFav() ? Colors.yellow : Colors.grey,
        ),
        onPressed: () {
          try {
            if (location.getFav()) {
              location.removeFav();
            } else {
              location.addFav();
            }
            _fetchLocations();
            print(location.toponym
                .toString()); // Actualizar la lista de ubicaciones
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al cambiar el estado de favorito: $e')),
            );
          }
        },
      ),
      title: Text(location.getAlias()),
      subtitle: Text(location.getToponym()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('Eliminar ${location.getAlias()}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              print('Editar ${location.getAlias()}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(Routes route) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          route.getFav() ? Icons.star : Icons.star_border,
          color: route.getFav() ? Colors.yellow : Colors.grey,
        ),
        onPressed: () async {
          try {
            if (route.getFav()) {
              route.removeFav();
            } else {
              route.addFav();
            }
            _fetchRoutes();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al cambiar el estado de favorito: $e')),
            );
          }
        },
      ),
      title: Text(route.name),
      subtitle:
          Text('${route.getStart.getAlias()} → ${route.getEnd.getAlias()}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('Eliminar ruta');
            },
          ),
          IconButton(
            icon: const Icon(Icons.route_outlined),
            onPressed: () {
              _showRoutes(
                  route); //Si se selecciona te lleva a la pantalla de la ruta
              print('Mostrar ruta $route.name');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(Vehicle vehicle) {
    return ListTile(
      leading: IconButton(
        icon: Icon(
          vehicle.getFav() ? Icons.star : Icons.star_border,
          color: vehicle.getFav() ? Colors.yellow : Colors.grey,
        ),
        onPressed: () async {
          try {
            if (vehicle.getFav()) {
              vehicle.removeFav();
            } else {
              vehicle.addFav();
            }
            _fetchVehicles(); // Actualizar la lista de coches
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error al cambiar el estado de favorito: $e')),
            );
          }
        },
      ),
      title: Text(vehicle.getName()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              print('Eliminar $vehicle');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              print('Editar $vehicle');
            },
          ),
        ],
      ),
    );
  }

  void _fetchLocations() async {
    try {
      // Llamada asíncrona al ViewModel para obtener las ubicaciones
      final fetchedLocations = await locationController
          .getLocationList(); // Esperar el resultado del Future
      setState(() {
        locations = fetchedLocations
            .toList(); // Convertir el Set a una lista y actualizar el estado
        locations = sortFavItems(locations);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ubicaciones: $e')),
      );
    }
  }

  void _fetchRoutes() async {
    try {
      final fetchedRoutes =
          await routeController.getRouteList(); // Obtener la lista de rutas
      setState(() {
        routes =
            fetchedRoutes.toList(); // Convertir a lista y actualizar el estado
        routes = sortFavItems(routes);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar rutas: $e')),
      );
    }
  }

  void _showRoutes(Routes route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteMapScreen(route: route),
      ),
    );
  }

  void _fetchVehicles() async {
    try {
      print("entra en fetchvehicles"); //sí que entra
      final fetchedVehicles =
          await vehicleController.getVehicleList(); // Obtener la lista de rutas
      setState(() {
        vehicles = fetchedVehicles
            .toList(); // Convertir a lista y actualizar el estado
        vehicles = sortFavItems(vehicles);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar vehículos: $e')),
      );
    }
  }
}
