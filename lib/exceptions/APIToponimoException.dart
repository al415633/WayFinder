class APIToponimoException implements Exception {
 final String message = "Error al obtener el toponimo de la API.";

  @override
  String toString() => "APICoordenadasException: $message";
}
