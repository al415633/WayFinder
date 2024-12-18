class ConnectionBBDDException implements Exception {
 final String message = "Error de conexión a la BBDD.";

  @override
  String toString() => "ConnectionBBDDException: $message";
}