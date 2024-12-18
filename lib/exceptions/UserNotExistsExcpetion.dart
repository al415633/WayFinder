class UserNotExistException implements Exception {
 final String message = "Error, el usuario con el que estás intentando iniciar sesión no existe.";

  @override
  String toString() => "UserNotExistException: $message";
}
