class NotValidEmailException implements Exception {
 final String message = "Error, el mail introducido no es válido.";

  @override
  String toString() => "APICoordenadasException: $message";
}
