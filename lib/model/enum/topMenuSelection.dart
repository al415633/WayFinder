enum TopMenuSelection {
  locations,
  routes,
  vehicles,
  settings,
  noSeleccionado
}

extension TopMenuSelectionExtension on TopMenuSelection {
  String get name {
    switch (this) {
      case TopMenuSelection.locations:
        return 'Lugares de interés';
      case TopMenuSelection.routes:
        return 'Rutas';
      case TopMenuSelection.vehicles:
        return 'Vehiculos';
      case  TopMenuSelection.settings:
        return 'Ajustes';
      case TopMenuSelection.noSeleccionado:
        return '';
    }
  }
}