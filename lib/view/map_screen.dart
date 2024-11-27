import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
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
  String selectedMode = 'car'; // por defecto
  LatLng initialPoint = LatLng(39.98567, -0.04935); // por defecto
  bool showInterestPlaces = false; 
  bool isSelectingLocation = false; // Nuevo estado para habilitar la selección en el mapa
  String? locationName; // Nombre del lugar seleccionado
  final LocationController locationController = LocationController(FirestoreAdapterLocation());
  List<Location> locations = []; // Lista para almacenar los nombres de las locations



  


  @override
  void initState() {
    super.initState();
     _fetchLocations(); 
  }

  void _onModeChanged(String mode) {
    setState(() {
      //selectedMode = mode;
      if (mode == 'locations') {
        showInterestPlaces = true; // Muestra el panel lateral
      } else {
        showInterestPlaces = false; // Oculta el panel lateral
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
                  _buildTopButton('Lugares de interés', selectedMode == 'locations', () {
                    _onModeChanged('locations');
                  }),
                  _buildTopButton('Rutas', selectedMode == 'routes', () {
                    _onModeChanged('routes');
                  }),
                  _buildTopButton('Vehículos', selectedMode == 'vehicles', () {
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
                      _onModeChanged('reload');
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
                          ...locations.map((placeName) => _buildInterestPlaceItem(placeName.getAlias())),
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
              ),)
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

void _fetchLocations() async {
  try {
    // Llamada asíncrona al ViewModel para obtener las ubicaciones
    final fetchedLocations = await locationController.getLocationList(); // Esperar el resultado del Future
    setState(() {
      locations = fetchedLocations.toList(); // Convertir el Set a una lista y actualizar el estado
    });
  } catch (e) {
    print('Error al obtener las ubicaciones: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar ubicaciones: $e')),
    );
  }
}

}
