enum RouteMode {
  rapida,
  corta,
  economica
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
      default:
        return '';
    }
  }
}