import 'package:flutter/material.dart';

void showAddVehicleDialog(BuildContext context, Function(String, String, double, String) onVehicleSelected) {
  // Variables para los datos del vehículo
  String vehicleNameInput = '';
  String fuelTypeInput = '';
  double consumptionInput = 0.0;
  String numberPlateInput = '';


  // Mensajes de error
  String errorMessage = '';

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
                  decoration:
                      const InputDecoration(labelText: 'Nombre del vehículo'),
                  onChanged: (value) {
                    setDialogState(() {
                      vehicleNameInput = value;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Tipo de combustible'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Gasolina', child: Text('Gasolina')),
                    DropdownMenuItem(value: 'Diésel', child: Text('Diésel')),
                    DropdownMenuItem(
                        value: 'Eléctrico', child: Text('Eléctrico')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      fuelTypeInput = value ?? '';
                    });
                  },
                  value: fuelTypeInput.isEmpty ? null : fuelTypeInput,
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Consumo (L/100km)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setDialogState(() {
                      consumptionInput = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Número de placa'),
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
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (vehicleNameInput.isEmpty ||
                      fuelTypeInput.isEmpty ||
                      consumptionInput <= 0 ||
                      numberPlateInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Por favor, completa todos los campos.';
                    });
                  } else {
                    onVehicleSelected(vehicleNameInput, fuelTypeInput, consumptionInput, numberPlateInput); // Notifica a la pantalla principal
                    Navigator.of(context).pop();
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
