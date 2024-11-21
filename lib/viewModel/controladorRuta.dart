
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:WayFinder/model/ruta.dart';





class ControladorRuta {
  
  // Propiedades
 late Set<Ruta> listaRutas;
final DbAdapterRuta _dbAdapter;

    ControladorRuta(this._dbAdapter) : listaRutas = _dbAdapter.getListaRutas();



 Set<Ruta> getListaRutas(){
  return listaRutas;
 }

Ruta? crearRuta(Lugar inicio, Lugar fin, String modoTransporte, String modoRuta){

  Ruta ruta = Ruta(inicio, fin, getDistancia(inicio, fin), getPoints(inicio, fin), modoTransporte, modoRuta) ;
 
  return ruta;
}

  double getDistancia(Lugar inicio, Lugar fin) {

    throw UnimplementedError("Method not implemented");
  }
  
  List<Coordenada> getPoints(Lugar inicio, Lugar fin) {
    throw UnimplementedError("Method not implemented");
  }


  Future<bool> guardarRuta(Ruta ruta) {
     Future<bool> resultado = _dbAdapter.guardarRuta(ruta);
    listaRutas.add(ruta);
    return resultado;
  }

}


class FirestoreAdapterRuta implements DbAdapterRuta {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapterRuta({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Ruta> getListaRutas(){


    //implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<Ruta?> crearRuta(Ruta ruta) async {
    throw UnimplementedError("Method not implemented");
  }
  
  @override
  Future<bool> guardarRuta(Ruta ruta) async{
    try {
      await db.collection(_collectionName).add(ruta.toMap());
      return true;
    } catch (e) {
      print("Error al crear lugar: $e");
      return false;

    }
  }
  
}



abstract class DbAdapterRuta {
  Future<Ruta?> crearRuta(Ruta ruta);
  Set<Ruta> getListaRutas();

    Future<bool> guardarRuta(Ruta ruta);


}


