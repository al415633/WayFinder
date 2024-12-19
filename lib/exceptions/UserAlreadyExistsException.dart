class UserAlreadyExistsException implements Exception {
 final String message = "Error, el usuario que intentas crear ya existe.";

  @override
  String toString() => "UserAlreadyExistsException: $message";
}
