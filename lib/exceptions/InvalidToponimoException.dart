class InvalidToponimoException implements Exception {
 final String message = "Error, el topónimo introducido no es válido.";

  @override
  String toString() => "InvalidToponimoException: $message";
}
