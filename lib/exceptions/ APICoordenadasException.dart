class APICoordenadasException implements Exception {
 final String message = "Error al obtener las coordenadas de la API.";

  @override
  String toString() => "APICoordenadasException: $message";
}
