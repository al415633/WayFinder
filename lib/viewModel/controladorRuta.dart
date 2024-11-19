
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
  _dbAdapter.crearRuta(ruta);
  listaRutas.add(ruta);
  return null;
}

  double getDistancia(Lugar inicio, Lugar fin) {

    throw UnimplementedError("Method not implemented");
  }
  
  List<Coordenada> getPoints(Lugar inicio, Lugar fin) {
    throw UnimplementedError("Method not implemented");
  }


  Future<bool> guardarRuta(Ruta ruta) {
    // TODO: implement guardarRuta
    throw UnimplementedError("Method not implemented");
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
    try {
      await db.collection(_collectionName).add(ruta.toMap());
      return null;
    } catch (e) {
      print("Error al crear lugar: $e");
      return null;

    }
  }
  
  @override
  Future<bool> guardarRuta(Ruta ruta) {
    // TODO: implement guardarRuta
    throw UnimplementedError();
  }
  
}



abstract class DbAdapterRuta {
  Future<Ruta?> crearRuta(Ruta ruta);
  Set<Ruta> getListaRutas();

    Future<bool> guardarRuta(Ruta ruta);


}


