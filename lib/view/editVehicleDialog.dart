import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:flutter/material.dart';

void showEditVehicleDialog(BuildContext context, Vehicle vehicle,
    Function(Vehicle, String, double) onVehicleEdited) {
  // Variables para los datos del vehículo
  String vehicleNameInput = vehicle.name;
  FuelType fuelTypeInput = vehicle.fuelType;
  double consumptionInput = vehicle.consumption;
  String numberPlateInput = vehicle.numberPlate;

  // Mensajes de error
  String errorMessage = '';
  TextEditingController vehicleNameController =
      TextEditingController(text: vehicleNameInput);
  TextEditingController consumptionController =
      TextEditingController(text: consumptionInput.toString());
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Editar vehículo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: 'Nombre del vehículo'),
                    controller: vehicleNameController,
                    onChanged: (value) {
                      setDialogState(() {
                        vehicleNameInput = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Tipo de combustible',
                      labelStyle: TextStyle(
                          color:
                              Colors.grey), // Cambiar el color de la etiqueta
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .transparent), // Sin borde cuando no está enfocado
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .transparent), // Sin borde cuando está enfocado
                      ),
                    ),
                    controller: TextEditingController(text: fuelTypeInput.name),
                    readOnly: true,
                    style: TextStyle(
                        color: Colors.grey), // Cambiar el color del texto
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: fuelTypeInput == FuelType.electrico
                          ? 'Consumo (KW/h)'
                          : 'Consumo (L/100km)',
                    ),
                    keyboardType: TextInputType.number,
                    controller: consumptionController,
                    onChanged: (value) {
                      setDialogState(() {
                        consumptionInput = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Número de placa',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent)),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        )),
                    controller: TextEditingController(text: numberPlateInput),
                    readOnly: true,
                    style: TextStyle(color: Colors.grey),
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
                onPressed: () async {
                  if (vehicleNameInput.isEmpty ||
                      consumptionInput <= 0 ||
                      numberPlateInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'Por favor, completa todos los campos.';
                    });
                  } else {
                    // Llamar a la función para crear el vehículo
                    bool res = await onVehicleEdited(
                        vehicle, vehicleNameInput, consumptionInput);
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
                child: const Text('Guardar cambios'),
              ),
            ],
          );
        },
      );
    },
  );
}
