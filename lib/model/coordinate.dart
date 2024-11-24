import 'package:latlong2/latlong.dart';

class Coordinate {
  // Propiedades

late LatLng coordinate;
late double lat;
late double lon;

  // Constructor
  Coordinate(double lat, double long) {
    coordinate = LatLng(lat, long);
    lat = lat;
    lon = lon;
  }

  double getLat(){
    return lat;
  }

  double getLon(){
    return lon;
  }

}
