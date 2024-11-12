import 'package:latlong2/latlong.dart';

class Coordenada {
  // Propiedades

late LatLng coordenada;
late double lat;
late double lon;

  // Constructor
  Coordenada(double lat, double long) {
    coordenada = LatLng(lat, long);
    this.lat = lat;
    this.lon = lon;
  }

  double getLat(){
    return this.lat;
  }

  double getLon(){
    return this.lon;
  }

}
