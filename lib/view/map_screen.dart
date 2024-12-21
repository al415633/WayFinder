import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/topMenuSelection.dart';
import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/view/addRouteDialog.dart';
import 'package:WayFinder/view/addVehicleDialog.dart';
import 'package:WayFinder/view/addLocationDialog.dart';
import 'package:WayFinder/view/defaultRouteDialog.dart';
import 'package:WayFinder/view/login.dart';
import 'package:WayFinder/view/defaultTransportDialog.dart';
import 'package:WayFinder/view/routeMapScreen.dart';
import 'package:WayFinder/view/showConfirmationDialog.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterRoute.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterVehiculo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final UserApp? userApp;
  const MapScreen({super.key, this.userApp});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TopMenuSelection _topMenuSelection = TopMenuSelection.noSeleccionado;

  List listOfPoints = [];
  List<LatLng> points = [];
  TransportMode transportMode = TransportMode.coche; // por defecto
  RouteMode routeMode = RouteMode.corta; // por defecto
  LatLng initialPoint = LatLng(39.98567, -0.04935); // por defecto
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
      VehicleController.getInstance(FirestoreAdapterVehiculo());
  List<Vehicle> vehicles = [];
  UserAppController? userAppController = UserAppController.getInstance();
  late double cost;
  UserApp? userApp;

  @override
  void initState() {
    super.initState();
    /*
    locationController.clearList();
    routeController.clearList();
    vehicleController.clearList();
    */
    userApp = widget.userApp;
    userAppController?.getDefaults(userApp);
    routeMode = userApp!.getDefaultRouteMode; 
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
              // Contenedor con scroll para los botones de la barra superior
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTopButton(TopMenuSelection.locations.name,
                          _topMenuSelection == TopMenuSelection.locations, () {
                        _onTopMenuSelectionChanged(TopMenuSelection.locations);
                      }),
                      _buildTopButton(TopMenuSelection.routes.name,
                          _topMenuSelection == TopMenuSelection.routes, () {
                        _onTopMenuSelectionChanged(TopMenuSelection.routes);
                      }),
                      _buildTopButton(TopMenuSelection.vehicles.name,
                          _topMenuSelection == TopMenuSelection.vehicles, () {
                        _onTopMenuSelectionChanged(TopMenuSelection.vehicles);
                      }),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      _onTopMenuSelectionChanged(TopMenuSelection.settings);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      _logOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MiApp()),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double panelWidth =
              constraints.maxWidth * 0.3; // 30% del ancho de la pantalla
          return Stack(
            children: [
              _buildFlutterMap(),
              if (_topMenuSelection == TopMenuSelection.locations)
                _buildSidePanel(
                    TopMenuSelection.locations.name,
                    locations,
                    (item) => _buildLocationItem(item as Location),
                    () => showAddLocationDialog(context, _onLocationSelected),
                    panelWidth),
              if (_topMenuSelection == TopMenuSelection.routes)
                _buildSidePanel(
                    TopMenuSelection.routes.name,
                    routes,
                    (item) => _buildRouteItem(item as Routes),
                    () => showAddRouteDialog(context, locations, vehicles,
                        userApp, _onRouteSelected),
                    panelWidth),
              if (_topMenuSelection == TopMenuSelection.vehicles)
                _buildSidePanel(
                    TopMenuSelection.vehicles.name,
                    vehicles,
                    (item) => _buildVehicleItem(item as Vehicle),
                    () => showAddVehicleDialog(context, _onVehicleSelected),
                    panelWidth),
              if (_topMenuSelection == TopMenuSelection.settings)
                _buildSettingsSidePanel(
                    TopMenuSelection.settings.name, panelWidth),
            ],
          );
        },
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

  Future<bool> _onVehicleSelected(String name, FuelType fuelType,
      double consumption, String numberPlate) async {
    try {
      await vehicleController.createVehicle(
          numberPlate, consumption, fuelType, name);
      _fetchVehicles(); // Actualizar la lista de vehículos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo guardado exitosamente.')),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onRouteSelected(
      String name,
      Location start,
      Location end,
      TransportMode transportMode,
      RouteMode routeMode,
      Vehicle? vehicle,
      bool save) async {
    late Routes route;
    try {
      route = await routeController.createRoute(
          name, start, end, transportMode, routeMode, vehicle);
      print(vehicle);
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
        SnackBar(content: Text('Error al guardar la ruta: $e')),
      );
    }
    _showRoutes(route);
  }

  Future<void> onDefaultTransportSelected(
      TransportMode transportMode, Vehicle? vehicle) async {
    try {
      userAppController?.setTransportModeDefault(
          userApp, transportMode, vehicle);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al seleccionar transporte por defecto: $e')),
      );
    }
  }

  Future<void> onDefaultRouteSelected(RouteMode routeMode) async {
    try {
      userAppController?.setRouteModeDefault(userApp, routeMode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar ruta por defecto: $e')),
      );
    }
  }

  Widget _buildSidePanel(
      String title,
      List items,
      Widget Function(dynamic) buildItem,
      VoidCallback onAddPressed,
      double panelWidth) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: panelWidth,
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

  Widget _buildSettingsSidePanel(String title, double panelWidth) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: panelWidth,
        color: Colors.white,
        child: SingleChildScrollView(
          // Permite desplazamiento vertical
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ElevatedButton(
                child: const Text('Seleccionar transporte por defecto'),
                onPressed: () {
                  showDefalutTransportDialog(
                      context, vehicles, userApp, onDefaultTransportSelected);
                },
              ),
              const SizedBox(height: 12), // Espacio adicional entre botones
              ElevatedButton(
                child: const Text('Seleccionar tipo de ruta por defecto'),
                onPressed: () {
                  showDefaultRouteDialog(
                      context, userApp, onDefaultRouteSelected);
                },
              ),
              const SizedBox(height: 20), // Espacio adicional
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Fondo rojo
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16), // Ajusta el padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                  minimumSize: const Size(150, 40), // Ajusta el tamaño mínimo
                ),
                onPressed: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'Confirmación',
                    question:
                        '¿Estás seguro de que deseas eliminar tu cuenta y todos los datos relacionados?',
                    onConfirm: (bool confirmed) {
                      if (confirmed) {
                        // Llama al controlador para eliminar la cuenta
                        UserAppController userAppController =
                            UserAppController.getInstance();
                        userAppController.deleteAccount();

                        // Muestra un mensaje de éxito o redirige
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cuenta eliminada con éxito.'),
                          ),
                        );

                        // Opcionalmente, navega a otra pantalla o cierra sesión
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => MiApp(), // Página inicial
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        // Acción cancelada
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Acción cancelada.'),
                          ),
                        );
                      }
                    },
                  );
                },
                child: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16), // Texto blanco y tamaño de fuente
                ),
              ),
              const SizedBox(height: 16), // Espacio final
            ],
          ),
        ),
      ),
    );
  }

  void _onTopMenuSelectionChanged(TopMenuSelection menuSelection) {
    setState(() {
      _topMenuSelection = menuSelection;
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
              locationController.removeFav(location);
            } else {
              locationController.addFav(location);
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
            onPressed: () async {
              await locationController.deleteLocation(location);
              _fetchLocations();
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
              routeController.removeFav(route);
            } else {
              routeController.addFav(route);
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
            onPressed: () async {
              await routeController.deleteRoute(route);
              _fetchRoutes();
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
        onPressed: () {
          try {
            if (vehicle.getFav()) {
              vehicleController.removeFav(vehicle);
            } else {
              vehicleController.addFav(vehicle);
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
            onPressed: () async {
              await vehicleController.deleteVehicle(vehicle);
              _fetchVehicles();
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

  void _logOut() async {
    UserAppController userAppController = UserAppController.getInstance();
    RouteController routeController =
        RouteController.getInstance(FirestoreAdapterRoute());
    VehicleController vehicleController =
        VehicleController.getInstance(FirestoreAdapterVehiculo());
    LocationController locationController =
        LocationController.getInstance(FirestoreAdapterLocation());

    // Limpia los estados y destruye las instancias
    userAppController.logOut();
    //UserAppController.destroyInstance();
    RouteController.destroyInstance();
    VehicleController.destroyInstance();
    LocationController.destroyInstance();
  }
}
