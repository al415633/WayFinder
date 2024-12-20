import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:flutter/material.dart';

Future<void> showDefalutTransportDialog(BuildContext context, List<Vehicle> vehicles, UserApp? userApp,
    Function(TransportMode, Vehicle?) onDefaultTransportSelected) async {
  TransportMode transportModeInput = userAppController.getTransportModeDefault(userApp);
  Vehicle? selectedVehicle;

  // Mensajes de error
  String errorMessage = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Transporte por defecto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  onDefaultTransportSelected(
                      transportModeInput, selectedVehicle);
                  Navigator.of(context).pop();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
