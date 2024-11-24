import 'package:WayFinder/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LocationController {
    // Propiedades

    late Set<Location> locationList;
    final DbAdapterLocation _dbAdapter;

    // Constructor privado
  LocationController._internal(this._dbAdapter) : locationList = _dbAdapter.getLocationList();


    // Instancia única
   static LocationController? _instance;


    factory LocationController(DbAdapterLocation dbAdapter) {
    
    //SI NO EXISTE UNA INSTANCIA CREARLA
    _instance ??= LocationController._internal(dbAdapter);
    return _instance!;
  }





    Set<Location> getLocationList(){ 
      return locationList;
    }

    Future<bool> createLocationFromCoord(double lat, double long, String alias) async{
      throw UnimplementedError("Method Not Implemented");
    }

    Future<bool> createLocationFromTopo(String topo, String alias) async{

      throw UnimplementedError("Method Not Implemented");
    }


    Future<bool> addFav(String topo, String alias) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada

      throw UnimplementedError("Method Not Implemented");
    }

    Future<bool> removeFav(String topo, String alias) async{

      throw UnimplementedError("Method Not Implemented");
    }    
}




bool hasMaxSixDecimals(double value) {
  // Convierte el número a String
  throw UnimplementedError("Method Not Implemented");
}



class FirestoreAdapterLocation implements DbAdapterLocation {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapterLocation({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Location> getLocationList(){


    //implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<bool> createLocationFromCoord(Location location) async {
    throw UnimplementedError("Method Not Implemented");
  }
  @override
  Future<bool> createLocationFromTopo(Location location) async {
   throw UnimplementedError("Method Not Implemented");
  }
  
  @override
  Future<bool> addFav(String topo, String alias) {
    // TODO: implement ponerFav
    throw UnimplementedError();
  }
  
  @override
  Future<bool> removeFav(String topo, String alias) {
    // TODO: implement quitarFav
    throw UnimplementedError();
  }
  
  @override
  Location readBbddLocation(String alias) {
    // TODO: implement leerBbddLocation
    throw UnimplementedError();
  }
}



abstract class DbAdapterLocation {
  Future<bool> createLocationFromCoord(Location location);
  Future<bool> createLocationFromTopo(Location location);
  Set<Location> getLocationList();
  Future<bool> addFav(String topo, String alias);
  Future<bool> removeFav(String topo, String alias);
  Location readBbddLocation(String alias);
}