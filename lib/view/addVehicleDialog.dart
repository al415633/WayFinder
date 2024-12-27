import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:flutter/material.dart';

void showAddVehicleDialog(BuildContext context,
    Function(String, FuelType, double, String) onVehicleSelected) {
  // Variables para los datos del vehículo
  String vehicleNameInput = '';
  FuelType fuelTypeInput = FuelType.gasolina;
  double consumptionInput = 0.0;
  String numberPlateInput = '';

  // Mensajes de error
  String errorMessage = '';

  bool validNumberPlate(String? numberPlate) {
    if (numberPlate == null) return false;

    numberPlate = numberPlate.toUpperCase();

    // Formatos existentes
    final format1 = RegExp(r'^[A-Z]{3}\d{4}$'); // Ejemplo: ABC1234
    final format2 = RegExp(r'^[A-Z]{1}\d{4}$'); // Ejemplo: A1234
    final format3 =
        RegExp(r'^[A-Z]{1,2}\d{4}[A-Z]{2}$'); // Ejemplo: A1234BC, AB1234XY

    // Formato para números seguidos de letras (como 1879ABC)
    final format4 = RegExp(r'^\d{4}[A-Z]{3}$'); // Ejemplo: 1879ABC

    // Verifica si alguna de las expresiones regulares coincide
    return format1.hasMatch(numberPlate) ||
        format2.hasMatch(numberPlate) ||
        format3.hasMatch(numberPlate) ||
        format4.hasMatch(numberPlate);
  }

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
                DropdownButtonFormField<FuelType>(
                  decoration:
                      const InputDecoration(labelText: 'Tipo de combustible'),
                  items: const [
                    DropdownMenuItem(
                        value: FuelType.gasolina, child: Text('Gasolina')),
                    DropdownMenuItem(
                        value: FuelType.diesel, child: Text('Diésel')),
                    DropdownMenuItem(
                        value: FuelType.electrico, child: Text('Eléctrico')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      fuelTypeInput = value!;
                    });
                  },
                ),
                TextField(
                  decoration:
                        InputDecoration(
                        labelText: fuelTypeInput == FuelType.electrico
                          ? 'Consumo (KW/h)'
                          : 'Consumo (L/100km)',
                        ),
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
                      consumptionInput <= 0 ||
                      numberPlateInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Por favor, completa todos los campos.';
                    });
                  } else if (!validNumberPlate(numberPlateInput)) {
                    setDialogState(() {
                      errorMessage = 'La matrícula no es válida.';
                    });
                  } else {
                    // Llamar a la función para crear el vehículo
                    bool res = await onVehicleSelected(vehicleNameInput,
                        fuelTypeInput, consumptionInput, numberPlateInput);
                    if (!res) {
                      setDialogState(() {
                        errorMessage =
                            'Ya existe un vehículo con esa matrícula.'; // Muestra el error en el diálogo
                      });
                    } else {
                      Navigator.of(context).pop();
                    }
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
