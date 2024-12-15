class NotAuthenticatedUserException implements Exception {
 final String message = "Error, actualmente no hay ningún usuario autenticado.";

  @override
  String toString() => "APICoordenadasException: $message";
}
