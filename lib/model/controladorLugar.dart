import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:WayFinder/paginas/api_ops.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ControladorLugar {
  // Propiedades

    late Set<Lugar> listaLugares;
    final DbAdapter _dbAdapter;

    ControladorLugar(this._dbAdapter) : listaLugares = _dbAdapter.getListaLugares();


    Set<Lugar> getListaLugares(){ 
      return listaLugares;
    }

    Future<bool> crearLugarPorCoord(double lat, double long, String apodo) async{


     if (lat > 90 || lat < -90) {
    throw Exception("InvalidCoordinatesException: La latitud debe estar entre -90 y 90 grados.");
    }
    if (long > 180 || long < -180) {
      throw Exception("InvalidCoordinatesException: La longitud debe estar entre -180 y 180 grados.");
    }
    if (!tieneMaximoSeisDecimales(lat)) {
      throw Exception("InvalidCoordinatesException: La latitud no debe tener más de 6 decimales.");
    }
    if (!tieneMaximoSeisDecimales(long)) {
      throw Exception("InvalidCoordinatesException: La longitud no debe tener más de 6 decimales.");
    }

      Lugar lugar = Lugar(lat, long, apodo);


 Set<Lugar> getListaLugares(){
  return listaLugares;
 }
      bool success =  await _dbAdapter.crearLugarPorCoord(lugar);
      
      if (success){
        listaLugares.add(lugar);
      }


      return success;
    }

    Future<bool> crearLugarPorTopo(String topo, String apodo) async{

      Lugar lugar = Lugar.fromTopnimo(topo, apodo);

      bool success = await _dbAdapter.crearLugarPorTopo(lugar);

      if (success){
        listaLugares.add(lugar);
      }

      return success;
    }


    Future<bool> ponerFav(String topo, String apodo) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada

        bool success = await _dbAdapter.ponerFav(topo, apodo);

        return success;
    }

    Future<bool> quitarFav(String topo, String apodo) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada


        bool success = await _dbAdapter.quitarFav(topo, apodo);

        return success;
    }




    
}


bool tieneMaximoSeisDecimales(double valor) {
  // Convierte el número a String
  String valorStr = valor.toString();
  
  // Divide la cadena en parte entera y parte decimal
  List<String> partes = valorStr.split('.');
  
  // Si no hay parte decimal, cumple la regla
  if (partes.length < 2) return true;
  
  // Verifica que la parte decimal tenga 6 o menos caracteres
  return partes[1].length <= 6;
}



class FirestoreAdapter implements DbAdapter {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapter({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Lugar> getListaLugares(){


    //implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<bool> crearLugarPorCoord(Lugar lugar) async {
    try {
      await db.collection(_collectionName).add(lugar.toMap());
      return true;
    } catch (e) {
      print("Error al crear lugar: $e");
      return false;
    }
  }
  @override
  Future<bool> crearLugarPorTopo(Lugar lugar) async {
    try {
      await db.collection(_collectionName).add(lugar.toMap());
      return true;
    } catch (e) {
      print("Error al crear lugar: $e");
      return false;
    }
  }
  
  @override
  Future<bool> ponerFav(String topo, String apodo) {
    // TODO: implement ponerFav
    throw UnimplementedError();
  }
  
  @override
  Future<bool> quitarFav(String topo, String apodo) {
    // TODO: implement quitarFav
    throw UnimplementedError();
  }
}



abstract class DbAdapter {
  Future<bool> crearLugarPorCoord(Lugar lugar);
  Future<bool> crearLugarPorTopo(Lugar lugar);
  Set<Lugar> getListaLugares();
  Future<bool> ponerFav(String topo, String apodo);
  Future<bool> quitarFav(String topo, String apodo);
}