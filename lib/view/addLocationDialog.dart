import 'package:flutter/material.dart';

void showAddLocationDialog(BuildContext context, Function(String) onLocationSelected) {
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
                    onLocationSelected(locationNameInput);
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