enum RouteMode {
  rapida,
  corta,
  economica,
  noSeleccionado
}

extension RouteModeExtension on RouteMode {
  String get name {
    switch (this) {
      case RouteMode.rapida:
        return 'Rápida';
      case RouteMode.corta:
        return 'Corta';
      case RouteMode.economica:
        return 'Económica';
      case  RouteMode.noSeleccionado:
        return '';
    }
  }
}