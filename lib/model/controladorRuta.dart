import 'dart:convert';

import 'package:WayFinder/model/lugar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/ruta.dart';
import 'package:WayFinder/paginas/api_ops.dart';


class ControladorRuta {
  
  // Propiedades
 late Set<Ruta> listaRutas;

 final DbAdapter _dbAdapter;

  ControladorRuta(this._dbAdapter) : listaRutas = _dbAdapter.getListaRutas();


 Set<Ruta> getListaRutas(){
  return this.listaRutas;
 }

bool crearRuta(Lugar inicio, Lugar fin, List<Coordenada> points, String modoTransporte, String modoRuta){

  Ruta ruta = Ruta(inicio, fin, getDistancia(inicio, fin), getPoints(inicio, fin), modoTransporte, modoRuta); 
  
  listaRutas.add(ruta);
  return true;
}

  double getDistancia(Lugar inicio, Lugar fin) {

    throw UnimplementedError("Method not implemented");
  }
  
  List<Coordenada> getPoints(Lugar inicio, Lugar fin) {
    throw UnimplementedError("Method not implemented");
  }
}


class FirestoreAdapter implements DbAdapter {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapter({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Ruta> getListaRutas(){


    //implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<bool> crearRuta(Ruta ruta) async {
    try {
      await db.collection(_collectionName).add(ruta.toMap());
      return true;
    } catch (e) {
      print("Error al crear lugar: $e");
      return false;
    }
  }
  
}



abstract class DbAdapter {
  Future<bool> crearRuta(Ruta ruta);
  Set<Ruta> getListaRutas();
}
