import 'package:latlong2/latlong.dart';

class Coordinate {
  // Propiedades

late LatLng coordinate;
late double lat;
late double long;

  // Constructor
  Coordinate(double lat, double long) {
    coordinate = LatLng(lat, long);
    lat = lat;
    long = long;
  }

  double getLat(){
    return lat;
  }

  double getLong(){
    return long;
  }

}
