import 'package:latlong2/latlong.dart';

class Coordinate {
  // Propiedades
  late LatLng coordinate;
  late double lat;
  late double long;

  // Constructor
  Coordinate(double lat, double long) {
    this.lat = lat; // Asignar al campo de la clase
    this.long = long; // Asignar al campo de la clase
    coordinate = LatLng(lat, long);
  }

  double getLat() {
    return lat;
  }

  double getLong() {
    return long;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Coordinate) return false;

    return lat == other.lat && long == other.long;
  }

  @override
  int get hashCode => lat.hashCode ^ long.hashCode;
}
