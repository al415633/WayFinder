import 'package:WayFinder/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LocationController {
  // Propiedades

    late Set<Location> locationList;
    final DbAdapterLocation _dbAdapter;

    LocationController(this._dbAdapter) : locationList = _dbAdapter.getLocationList();


    Set<Location> getLocationList(){ 
      return locationList;
    }

    Future<bool> createLocationFromCoord(double lat, double long, String alias) async{
     if (lat > 90 || lat < -90) {
    throw Exception("InvalidCoordinatesException: La latitud debe estar entre -90 y 90 grados.");
    }
    if (long > 180 || long < -180) {
      throw Exception("InvalidCoordinatesException: La longitud debe estar entre -180 y 180 grados.");
    }
    if (!hasMaxSixDecimals(lat)) {
      throw Exception("InvalidCoordinatesException: La latitud no debe tener más de 6 decimales.");
    }
    if (!hasMaxSixDecimals(long)) {
      throw Exception("InvalidCoordinatesException: La longitud no debe tener más de 6 decimales.");
    }

      Location location = Location(lat, long, alias);


 
      bool success =  await this._dbAdapter.createLocationFromCoord(location);
      
      if (success){
        locationList.add(location);
      }


      return success;
    }

    Future<bool> createLocationFromTopo(String topo, String alias) async{

      Location location = Location.fromToponym(topo, alias);

      bool success = await _dbAdapter.createLocationFromTopo(location);

      if (success){
        locationList.add(location);
      }

      return success;
    }


    Future<bool> addFav(String topo, String alias) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada

        bool success = await _dbAdapter.addFav(topo, alias);

        return success;
    }

    Future<bool> removeFav(String topo, String alias) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada


        bool success = await _dbAdapter.removeFav(topo, alias);

        return success;
    }

    Location readBbddLocation(String alias){
      return _dbAdapter.readBbddLocation(alias);
    }    
}


bool hasMaxSixDecimals(double value) {
  // Convierte el número a String
  String valueStr = value.toString();
  
  // Divide la cadena en parte entera y parte decimal
  List<String> divisions = valueStr.split('.');
  
  // Si no hay parte decimal, cumple la regla
  if (divisions.length < 2) return true;
  
  // Verifica que la parte decimal tenga 6 o menos caracteres
  return divisions[1].length <= 6;
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
    try {
      await db.collection(_collectionName).add(location.toMap());
      return true;
    } catch (e) {
      print("Error al crear el lugar: $e");
      return false;
    }
  }
  @override
  Future<bool> createLocationFromTopo(Location location) async {
    try {
      await db.collection(_collectionName).add(location.toMap());
      return true;
    } catch (e) {
      print("Error al crear el lugar: $e");
      return false;
    }
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