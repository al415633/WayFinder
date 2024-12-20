import 'package:WayFinder/main.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:flutter/material.dart';

Future<void> showDefaultRouteDialog(
    BuildContext context, UserApp? userApp, Function(RouteMode) onDefaultRouteSelected) async {
  RouteMode routeModeInput = userAppController.getRouteModeDefault(userApp);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Ruta por defecto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<RouteMode>(
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
                  onDefaultRouteSelected(routeModeInput);
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
