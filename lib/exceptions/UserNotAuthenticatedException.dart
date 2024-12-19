class UserNotAuthenticatedException implements Exception {
 final String message = "Error, actualmente no hay ningún usuario autenticado.";

  @override
  String toString() => "UserNotAuthenticatedException: $message";
}
