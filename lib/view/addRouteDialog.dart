import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:WayFinder/model/location.dart';

Future<void> showAddRouteDialog(
    BuildContext context,
    List<Location> locations,
    List<Vehicle> vehicles,
    UserApp? userApp,
    Function(String, Location, Location, TransportMode, RouteMode, Vehicle?,
            bool)
        onRouteSelected) async {
  // Variables para los datos de la ruta
  String routeNameInput = '';
  Location? startLocationInput;
  Location? endLocationInput;
  TransportMode transportModeInput = userAppController.getTransportModeDefault(userApp);// Default value
  RouteMode routeModeInput = RouteMode.noSeleccionado; // Default value
  Vehicle? selectedVehicle;

  // Mensajes de error
  String errorMessage = '';


  generateRoute(bool saveRoute) {
    if (routeNameInput.isEmpty ||
        startLocationInput == null ||
        endLocationInput == null) {
      errorMessage = 'Por favor, complete todos los campos.';
    } else {
      onRouteSelected(routeNameInput, startLocationInput!, endLocationInput!,
          transportModeInput, routeModeInput, selectedVehicle, saveRoute);
      Navigator.of(context).pop();
    }
  }

  showDialog (
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
                  items: locations
                      .where((location) =>
                          location !=
                          endLocationInput) // Excluir la ubicación de fin
                      .map((location) {
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
                  items: locations
                      .where((location) =>
                          location !=
                          startLocationInput) // Excluir la ubicación de inicio
                      .map((location) {
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
                      if (transportModeInput == TransportMode.aPie ||
                          transportModeInput == TransportMode.bicicleta) {
                        // Asigna un valor predeterminado válido para routeModeInput
                        routeModeInput = RouteMode.economica;
                      } else {
                        routeModeInput = RouteMode.noSeleccionado;
                      }
                    });
                  },
                ),
                if (transportModeInput == TransportMode.coche)
                  vehicles.isNotEmpty
                      ? (DropdownButton<Vehicle>(
                          value: userAppController.getVehicleDefault(userApp),
                          items: vehicles.map((vehicle) {
                            return DropdownMenuItem<Vehicle>(
                              value: vehicle,
                              child: Text(vehicle.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedVehicle = value;
                            });
                          },
                        ))
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'El usuario no tiene coches dados de alta',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                if (transportModeInput != TransportMode.aPie &&
                    transportModeInput != TransportMode.bicicleta)
                  DropdownButton<RouteMode>(
                    hint: const Text('Tipo de ruta:'),
                    value: routeModeInput,
                    items: RouteMode.values.map((mode) {
                      return DropdownMenuItem<RouteMode>(
                        value: mode,
                        child: Text(mode.name),
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
                onPressed: () async {
                  generateRoute(true);
                },
                child: const Text('Guardar y generar ruta'),
              ),
              ElevatedButton(
                onPressed: () async {
                  generateRoute(false);
                },
                child: const Text('Generar ruta'),
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
