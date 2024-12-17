import 'package:flutter/material.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/vehicle.dart';

void showCarSelectionDialog(
  BuildContext context,
  List<Vehicle> vehicles, // Lista de vehículos pasados al diálogo
  Function(RouteMode, Vehicle) onSelectionConfirmed,
) {
  // Variables locales para la selección
  RouteMode selectedRouteMode = RouteMode.noSeleccionado; // Default
  Vehicle? selectedVehicle;

  // Mensaje de error si no se selecciona algo
  String errorMessage = '';

  void confirmSelection() {
    if (selectedRouteMode != RouteMode.noSeleccionado &&
        selectedVehicle != null) {
      onSelectionConfirmed(selectedRouteMode, selectedVehicle!);
      Navigator.of(context).pop();
    } else {
      errorMessage = 'Seleccione un tipo de ruta y un vehículo.';
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Seleccione el tipo de ruta y vehículo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<RouteMode>(
                  hint: const Text('Tipo de ruta'),
                  value: selectedRouteMode,
                  items: RouteMode.values.map((mode) {
                    return DropdownMenuItem<RouteMode>(
                      value: mode,
                      child: Text(mode.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRouteMode = value!;
                      errorMessage = '';
                    });
                  },
                ),
                if (vehicles.isNotEmpty)
                  DropdownButton<Vehicle>(
                    hint: const Text('Seleccione vehículo'),
                    value: selectedVehicle,
                    items: vehicles.map((vehicle) {
                      return DropdownMenuItem<Vehicle>(
                        value: vehicle,
                        child: Text(vehicle.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedVehicle = value;
                        errorMessage = '';
                      });
                    },
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No tiene coches registrados. Registre uno para ver rutas en coche.',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
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
                onPressed: vehicles.isEmpty
                    ? null
                    : confirmSelection, // Desactiva el botón si no hay vehículos
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    },
  );
}
