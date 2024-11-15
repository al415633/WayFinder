import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:WayFinder/paginas/api_ops.dart';


class ControladorLugar {
  // Propiedades

 late Set<Lugar> listaLugares;

 ControladorLugar(){
  listaLugares = {};
 }

 Set<Lugar> getListaLugares(){
  return listaLugares;
 }

bool crearLugarPorCoord(double lat, double long, String apodo){
  listaLugares.add(Lugar(lat, long, apodo));
  return true;
}

bool crearLugarPorTopo(String topo, String apodo){
  listaLugares.add(Lugar.fromTopnimo(topo, apodo));
  return true;
}

    
}
