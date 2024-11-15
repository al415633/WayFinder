import 'dart:convert';

import 'package:WayFinder/model/lugar.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/ruta.dart';
import 'package:WayFinder/paginas/api_ops.dart';


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
