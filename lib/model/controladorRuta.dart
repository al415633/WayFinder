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
  return this.listaRutas;
 }

bool crearRuta(Lugar inicio, Lugar fin, List<Coordenada> points, String modoTransporte, String modoRuta){

  Ruta ruta = Ruta(inicio, fin, getDistancia(inicio, fin), getPoints(inicio, fin), modoTransporte, modoRuta) 
  listaRutas.add(ruta);
  return true;
}

    
}
