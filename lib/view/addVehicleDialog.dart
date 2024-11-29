import 'package:flutter/material.dart';

void showAddVehicleDialog(BuildContext context) {
  // Variables para los datos del vehículo
  String vehicleNameInput = '';
  String fuelTypeInput = ''; // Esto se actualizará con la opción seleccionada
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
                  decoration: const InputDecoration(labelText: 'Nombre del vehículo'),
                  onChanged: (value) {
                    setDialogState(() {
                      vehicleNameInput = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Tipo de combustible'),
                  onChanged: (value) {
                    setDialogState(() {
                      fuelTypeInput = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Consumo (L/100km)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setDialogState(() {
                      consumptionInput = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Número de placa'),
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
                onPressed: () {
                  if (vehicleNameInput.isEmpty ||
                      fuelTypeInput.isEmpty ||
                      consumptionInput <= 0 ||
                      numberPlateInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Por favor, complete todos los campos.';
                    });
                  } else {
                    // Aquí puedes agregar la lógica para guardar el vehículo
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