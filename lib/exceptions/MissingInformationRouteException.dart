class MissingInformationRouteException implements Exception {
 final String message = "Error, falta información para calcular la ruta.";

  @override
  String toString() => "APICoordenadasException: $message";
}