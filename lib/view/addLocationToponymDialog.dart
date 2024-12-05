
import 'package:flutter/material.dart';

Future<Map<String, String>?> showAddLocationToponymDialog(BuildContext context, String alias) async {
  String toponymInput = '';
  String errorMessage = '';

  return showDialog<Map<String, String>>(
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
                      toponymInput = value; // Actualizar el valor del topónimo
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
                  if (toponymInput.isEmpty) {
                    setDialogState(() {
                      errorMessage = 'El campo no puede estar vacío';
                    });
                  } else {
                    Navigator.of(context).pop({'alias': alias, 'toponym': toponymInput});
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