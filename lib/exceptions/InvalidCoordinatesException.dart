class InvalidCoordinatesException implements Exception {
 final String message = "Error, las coordenadas introducidas no son válidas.";

  @override
  String toString() => "APICoordenadasException: $message";
}
