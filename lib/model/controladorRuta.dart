
import 'package:WayFinder/model/lugar.dart';
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/ruta.dart';


class ControladorRuta {
  
  // Propiedades

 late Set<Ruta> listaRutas;

 ControladorRuta(){
  listaRutas = {};
 }

 Set<Ruta> getListaRutas(){
  return listaRutas;
 }

bool crearRuta(Lugar inicio, Lugar fin, double distancia, List<LatLng> points, String modoTransporte, String modoRuta){
  listaRutas.add(Ruta(inicio, fin, distancia, points, modoTransporte, modoRuta) );
  return true;
}

    
}
