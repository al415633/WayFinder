import 'dart:convert';
import 'dart:ffi';

import 'package:WayFinder/model/lugar.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/paginas/api_ops.dart';

class Ruta {
  // Propiedades

late Lugar inicio;
late Lugar fin;
late double distancia;
late List<LatLng> points;
late bool fav;
late String modoTransporte;
late String modoRuta;


  // Constructor
  Ruta(Lugar inicio, Lugar fin, double distancia, List<LatLng> points, String modoTransporte, String modoRuta){
    this.inicio = inicio;
    this.fin = fin;
    this.distancia = distancia;
    this.points = [];
    fav = false;
    this.modoTransporte = modoTransporte;
    this.modoRuta = modoRuta;
  }

  double calcularCosteCarb(String tipoGas, double consumo){

    //TO DO : FALTA IMPLEMENTAR
    return 0;
  }

  double calcularCosteKCal(){
   double consumoMedio = 55;
    return distancia * consumoMedio;
  }
     
}