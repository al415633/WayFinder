class APIRoutesException implements Exception {
  final String? message;

  APIRoutesException([this.message]);

  @override
  String toString() {
    return message != null
        ? "ConnectionBBDDException: $message"
        : "ConnectionBBDDException: ocurrió un error.";
  }
}