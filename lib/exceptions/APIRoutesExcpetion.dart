class APIRoutesException implements Exception {
 final String message = "Error al obtener la ruta de la API.";

  @override
  String toString() => "APIRoutesException: $message";
}