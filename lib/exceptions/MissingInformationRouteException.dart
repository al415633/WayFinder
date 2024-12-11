class MissingInformationRouteException implements Exception {
  final String message;

  MissingInformationRouteException([this.message = "Información de ruta faltante"]);

  @override
  String toString() {
    return "MissingInformationRouteException: $message";
  }
}