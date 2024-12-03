import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:flutter/material.dart';

void showAddLocationToponymDialog(BuildContext context, String alias) {
  String locationNameInput = '';
  String errorMessage = '';
  LocationController locationController = LocationController.getInstance(FirestoreAdapterLocation());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Introduce el topónimo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Topónimo'),
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
                      errorMessage = 'El campo no puede estar vacío';
                    });
                  } else {
                    locationController.createLocationFromTopo(locationNameInput, alias);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Crear Lugar'),
              ),
            ],
          );
        },
      );
    },
  );
}