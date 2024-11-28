import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/favItemController.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/Vehicle.dart';
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
  String transportMode = 'car'; // por defecto
  LatLng initialPoint = LatLng(39.98567, -0.04935); // por defecto
  bool showInterestPlaces = false; 
  bool showRoutes = false; 
  bool showVehicles = false;
  bool isSelectingLocation = false; // Nuevo estado para habilitar la selección en el mapa
  String? locationName; 
  final LocationController locationController = LocationController(FirestoreAdapterLocation());
  List<Location> locations = []; 
  List<Routes> routes = [];
  final RouteController routeController = RouteController(FirestoreAdapterRoute());
  String? routeName; 
  final VehicleController vehicleController = VehicleController(FirestoreAdapterVehiculo());
  List<Vehicle> vehicles = [];
  UserAppController? userAppController = UserAppController.getInstance();



  @override
  void initState() {
    super.initState();
     _fetchLocations(); 
     _fetchRoutes();
     _fetchVehicles(); 
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
        const SnackBar(content: Text('El nombre del lugar no puede estar vacío.')),
      );
      return;
    }

    // Llamar al LocationController para guardar la ubicación
    try {
      bool success = await locationController.createLocationFromCoord(
        initialPoint.latitude,
        initialPoint.longitude,
        locationName!,
      );

      if (success) {
        _fetchLocations(); // Actualizar la lista de ubicaciones
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación guardada exitosamente.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la ubicación.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
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
                       userAppController?.logOut();

                Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Inicio()), // Navega a la pantalla de inicio
                      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
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
          FlutterMap(
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
            ),
    

          // Panel lateral (Lugares de interés)
          if (showInterestPlaces)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Lugares de interés',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          ...locations.map((placeName) => _buildLocationItem(placeName)),
                          IconButton(
                            onPressed: () {
                              _showAddPlaceDialog();
                              print(initialPoint);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),

                    ),
                  ]),
              ),),


          if (showRoutes)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Rutas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ...routes.map((route) => _buildRouteItem(route)),
                        IconButton(
                          onPressed: _showAddRouteDialog,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showVehicles)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 250,
              color: Colors.white,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Vehículos',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ...vehicles.map((vehicle) => _buildVehicleItem(vehicle)),
                        IconButton(
                          onPressed: _showAddVehicleDialog,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        





        ]  
      )
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
            // Si es favorito, lo desmarcamos
            location.removeFav();
          } else {
            // Si no es favorito, lo marcamos
            location.addFav();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cambiar el estado de favorito: $e')),
          );
        }
      },
    ),
    title: Text(location.getAlias()),
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
            // Si es favorito, lo desmarcamos
            route.removeFav();
          } else {
            // Si no es favorito, lo marcamos
            route.addFav();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cambiar el estado de favorito: $e')),
          );
        }
      },
    ),
    title: Text(route.name),
    subtitle: Text('${route.getStart().getAlias()} → ${route.getEnd().getAlias()}'),
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
          icon: const Icon(Icons.edit),
          onPressed: () {
            print('Editar ruta');
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
        vehicle.getFav()? Icons.star : Icons.star_border,
        color: vehicle.getFav() ? Colors.yellow : Colors.grey,
      ),
      onPressed: () async {
        try {
          if (vehicle.getFav()) {
            // Si es favorito, lo desmarcamos
            vehicle.removeFav();
          } else {
            // Si no es favorito, lo marcamos
            vehicle.addFav();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cambiar el estado de favorito: $e')),
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




  void _showAddPlaceDialog() {

     String locationNameInput = '';
    String errorMessage = ''; 
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Nuevo lugar de interés'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (value) {
                    setDialogState(() {
                      locationNameInput = value; // Actualizar el valor del nombre
                      errorMessage = ''; // Limpiar el mensaje de error
                    });
                  },
                ),
                if (errorMessage.isNotEmpty) // Mostrar error si existe
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (locationNameInput.isEmpty) {
                      setDialogState(() {
                        errorMessage = 'El nombre del lugar no puede estar vacío';
                      });
                    } else {
                      setState(() {
                        locationName = locationNameInput; // Guardar el nombre del lugar
                        isSelectingLocation = true; // Activar modo de selección
                      });

                       // Mostrar mensaje para guiar al usuario
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona una ubicación en el mapa.')),
                    );
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    }
                  },
                  child: const Text('Usar Mapa'),

                ),
            ],
          );
        },
      );
    },
  );
}



void _showAddRouteDialog() {
  String routeNameInput = '';
  Location? startLocation;
  Location? endLocation;
  String errorMessage = '';
  Routes? route;
  String transportMode = 'Coche';
  String routeMode = 'Rápida';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Crear ruta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nombre de la ruta'),
                  onChanged: (value) {
                    setDialogState(() {
                      routeNameInput = value;
                      errorMessage = '';
                    });
                  },
                ),
                DropdownButtonFormField<Location>(
                  decoration: const InputDecoration(labelText: 'Inicio'),
                  items: locations.map((location) {
                    return DropdownMenuItem<Location>(
                      value: location,
                      child: Text(location.getAlias()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      startLocation = value;
                    });
                  },
                ),
                DropdownButtonFormField<Location>(
                  decoration: const InputDecoration(labelText: 'Final'),
                  items: locations.map((location) {
                    return DropdownMenuItem<Location>(
                      value: location,
                      child: Text(location.getAlias()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      endLocation = value;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Vehículo'),
                  items: ['Coche', 'Bicicleta', 'A pie'].map((mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      transportMode = value!;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Modo de ruta'),
                  items: ['Rápida', 'Corta'].map((mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                    });
                  },
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (routeNameInput.isEmpty || startLocation == null || endLocation == null) {
                    setDialogState(() {
                      errorMessage = 'Completa todos los campos obligatorios';
                    });
                    return;
                  }

                  try {
                    route = routeController.createRoute(
                      routeNameInput,
                      startLocation!,
                      endLocation!,
                      transportMode,
                      routeMode,
                    );
                    
                    _showRoutes(route!);

                  } catch (e) {
                    setDialogState(() {
                      errorMessage = 'Error: $e';
                    });
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showAddVehicleDialog() {
  // Variables para los datos del vehículo
  String vehicleNameInput = '';
  String fuelTypeInput = ''; // Esto se actualizará con la opción seleccionada
  double consumptionInput = 0.0;
  String numberPlateInput = '';
  
  // Mensajes de error
  String errorMessage = ''; 
  String consumptionError = '';
  String fuelTypeError = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Nuevo vehículo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Nombre del vehículo'),
                  onChanged: (value) {
                    setDialogState(() {
                      vehicleNameInput = value;
                      errorMessage = ''; // Limpiar error de nombre
                    });
                  },
                ),
                // Dropdown para seleccionar el tipo de combustible
                DropdownButton<String>(
                  value: fuelTypeInput.isEmpty ? null : fuelTypeInput,
                  hint: const Text('Tipo de combustible'),
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      fuelTypeInput = newValue ?? '';
                      fuelTypeError = ''; // Limpiar error de tipo de combustible
                    });
                  },
                  items: <String>['Gasolina', 'Diésel', 'Eléctrico']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (fuelTypeError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      fuelTypeError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Consumo (L/100km)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setDialogState(() {
                      consumptionInput = value.isEmpty ? 0.0 : double.tryParse(value) ?? 0.0;
                      consumptionError = ''; // Limpiar error de consumo
                    });
                  },
                ),
                if (consumptionError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      consumptionError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Matrícula'),
                  onChanged: (value) {
                    setDialogState(() {
                      numberPlateInput = value;
                    });
                  },
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validaciones
                  if (vehicleNameInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'El nombre del vehículo no puede estar vacío';
                    });
                  } else if (fuelTypeInput.isEmpty) {
                    setDialogState(() {
                      fuelTypeError = 'El tipo de combustible no puede estar vacío';
                    });
                  } else if (consumptionInput <= 0) {
                    setDialogState(() {
                      consumptionError = 'El consumo debe ser mayor que 0';
                    });
                  } else if (numberPlateInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'La matrícula no puede estar vacía';
                    });
                  } else {
                    try {
                      bool success = await vehicleController.createVehicle(
                        numberPlateInput,
                        consumptionInput,
                        fuelTypeInput,
                        vehicleNameInput,
                      );

                      if (success) {
                        _fetchVehicles();  // Actualizar la lista de vehículos
                        // Mostrar mensaje para indicar que el vehículo se añadió
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vehículo añadido correctamente.')),
                        );
                        Navigator.of(context).pop(); // Cerrar el diálogo solo si la operación es exitosa
                      } else {
                        setDialogState(() {
                          errorMessage = 'Error al agregar el vehículo. Intenta de nuevo.';
                        });
                      }
                    } catch (e) {
                      setDialogState(() {
                        errorMessage = 'Error: $e';
                      });
                    }
                  }
                },
                child: const Text('Añadir vehículo'),
              ),
            ],
          );
        },
      );
    },
  );
}


void _fetchLocations() async {
  try {
    // Llamada asíncrona al ViewModel para obtener las ubicaciones
    final fetchedLocations = await locationController.getLocationList(); // Esperar el resultado del Future
    setState(() {
      locations = fetchedLocations.toList(); // Convertir el Set a una lista y actualizar el estado
      locations = sortFavItems(locations);
    });
  } catch (e) {
    print('Error al obtener las ubicaciones: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar ubicaciones: $e')),
    );
  }
}

List<T> sortFavItems<T extends FavItem>(List<T> items) {
  // Crea una copia de la lista original
  List<T> sortedItems = List.from(items);

  // Ordena la nueva lista
  sortedItems.sort((itemA, itemB) {
    final isAFav = itemA.getFav();
    final isBFav = itemB.getFav();
    if (isAFav && !isBFav) {
      return -1; // itemA va antes
    } else if (!isAFav && isBFav) {
      return 1; // itemB va antes
    } else {
      return 0;
    }
  });

  // Devuelve la lista ordenada
  return sortedItems;
}

void _fetchRoutes() async {
  try {
    final fetchedRoutes = await routeController.getRouteList(); // Obtener la lista de rutas
    setState(() {
      routes = fetchedRoutes.cast<Routes>().toList(); // Convertir a lista y actualizar el estado
      routes = sortFavItems(routes);
    });
  } catch (e) {
    print('Error al obtener las rutas: $e');
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
    final fetchedVehicles = await vehicleController.getVehicleList(); // Obtener la lista de rutas
    setState(() {
      vehicles = fetchedVehicles.toList(); // Convertir a lista y actualizar el estado
      vehicles = sortFavItems(vehicles);
    });
  } catch (e) {
    print('Error al obtener los vehículos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar vehículos: $e')),
    );
  }

}
}