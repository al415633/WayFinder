import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/view/routeMapScreen.dart';
import 'package:flutter/material.dart';
import 'package:WayFinder/model/location.dart';

void showAddRouteDialog(BuildContext context, List<Location> locations) {
  // Variables para los datos de la ruta
  String routeNameInput = '';
  Location? startLocationInput;
  Location? endLocationInput;
  TransportMode transportModeInput = TransportMode.coche; // Default value
  String routeModeInput = 'Rápida'; // Default value

  // Mensajes de error
  String errorMessage = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Nueva ruta'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Nombre de la ruta'),
                  onChanged: (value) {
                    setDialogState(() {
                      routeNameInput = value;
                      errorMessage = ''; // Limpiar el mensaje de error
                    });
                  },
                ),
                DropdownButton<Location>(
                  hint: const Text('Ubicación de inicio'),
                  value: startLocationInput,
                  items: locations.map((location) {
                    return DropdownMenuItem<Location>(
                      value: location,
                      child: Text(location.getAlias()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      startLocationInput = value;
                    });
                  },
                ),
                DropdownButton<Location>(
                  hint: const Text('Ubicación de fin'),
                  value: endLocationInput,
                  items: locations.map((location) {
                    return DropdownMenuItem<Location>(
                      value: location,
                      child: Text(location.getAlias()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      endLocationInput = value;
                    });
                  },
                ),
                DropdownButton<TransportMode>(
                  value: transportModeInput,
                  items: TransportMode.values.map((mode) {
                  return DropdownMenuItem<TransportMode>(
                    value: mode,
                    child: Text(mode.name),
                  );
                  }).toList(),
                  onChanged: (value) {
                  setDialogState(() {
                    transportModeInput = value!;
                  });
                  },
                ),
                DropdownButton<String>(
                  value: routeModeInput,
                  items: ['Rápida', 'Corta'].map((mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      routeModeInput = value!;
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
                onPressed: () {
                  if (routeNameInput.isEmpty ||
                      startLocationInput == null ||
                      endLocationInput == null) {
                    setDialogState(() {
                      errorMessage = 'Por favor, complete todos los campos.';
                    });
                  } else {
                    // Crear la ruta
                    Routes newRoute = Routes(
                      routeNameInput,
                      startLocationInput!,
                      endLocationInput!,
                      0.0, // Distance will be calculated later
                      [], // Points will be fetched later
                      transportModeInput,
                      routeModeInput,
                    );

                    // Navegar a RouteMapScreen
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RouteMapScreen(route: newRoute),
                      ),
                    );
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

extension on Future<Set<Location>> {
  map(DropdownMenuItem<Location> Function(dynamic location) param0) {}
}
