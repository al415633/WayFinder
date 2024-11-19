import 'package:latlong2/latlong.dart';

class Coordenada {
  // Propiedades

late LatLng coordenada;
late double lat;
late double lon;

  // Constructor
  Coordenada(double lat, double long) {
    coordenada = LatLng(lat, long);
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
