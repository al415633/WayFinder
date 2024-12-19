class IncorrectPasswordException implements Exception {
 final String message = "Error, la contraseña no es correcta.";

  @override
  String toString() => "IncorrectPasswordException: $message";
}
