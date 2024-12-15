class NotValidVehicleException implements Exception {
 final String message = "Error, el vehículo introducido no es válido.";

  @override
  String toString() => "APICoordenadasException: $message";
}
