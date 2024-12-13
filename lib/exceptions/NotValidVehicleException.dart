class NotValidVehicleException implements Exception {
  final String? message;

  NotValidVehicleException([this.message]);

  @override
  String toString() {
    return message != null
        ? "ConnectionBBDDException: $message"
        : "ConnectionBBDDException: ocurrió un error.";
  }
}
