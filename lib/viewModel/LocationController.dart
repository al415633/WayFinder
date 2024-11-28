import 'package:WayFinder/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';






class LocationController {
 // Propiedades


   late Future<Set<Location>> locationList;
   final DbAdapterLocation _dbAdapter;


    LocationController(this._dbAdapter) {
    try {
      locationList = _dbAdapter.getLocationList();
    } catch (e) {
      // Manejo de errores durante la inicialización
      locationList = Future.error(e);
    }
  }

  Future<Set<Location>> getLocationList() async {
    try {
      return await locationList;
    } catch (e) {
      throw Exception("Error al obtener la lista de ubicaciones: $e");
    }
  }


   Future<bool> createLocationFromCoord(double lat, double long, String alias) async{


  lat = double.parse(lat.toStringAsFixed(6));
  long = double.parse(long.toStringAsFixed(6));


    if (lat > 90 || lat < -90) {
   throw Exception("InvalidCoordinatesException: La latitud debe estar entre -90 y 90 grados.");
   }
   if (long > 180 || long < -180) {
     throw Exception("InvalidCoordinatesException: La longitud debe estar entre -180 y 180 grados.");
   }
   
     Location location = Location(lat, long, alias);

     try{

        bool success =  await this._dbAdapter.createLocationFromCoord(location);
        
        if (success){

          final currentSet = await locationList;

          // Agregar el nuevo Location al Set
          currentSet.add(location);
        }

        return success;
     } catch (e) {
    print("Error al crear el lugar: $e");
    return false;
  }
   }


   Future<bool> createLocationFromTopo(String topo, String alias) async{

     Location location = Location.fromToponym(topo, alias);

     bool success = await _dbAdapter.createLocationFromTopo(location);

          if (success){

      final currentSet = await locationList;

      // Agregar el nuevo Location al Set
      currentSet.add(location);
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


 
}








class FirestoreAdapterLocation implements DbAdapterLocation {
 final String _collectionName;
 final FirebaseFirestore db = FirebaseFirestore.instance;

  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterLocation({String collectionName = "production"})
      : _collectionName = collectionName {
    // Configurar el listener para authStateChanges
    _initializeAuthListener();
  }

  // Método para inicializar el listener de autenticación
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
      if (user != null) {
        print('Usuario autenticado: ${user.uid}');
      } else {
        print('No hay usuario autenticado.');
      }
    });
  }


 @override
 Future<Set<Location>> getLocationList() async{

  try {
    final querySnapshot = await db
        .collection(_collectionName) 
        .doc(_currentUser?.uid) 
        .collection("LocationList") 
        .get(); 

  // Convertir cada documento a una instancia de Location
    Set<Location> locations = querySnapshot.docs.map((doc) {
      return Location.fromMap(doc.data());
    }).toSet();

  return locations;

 
  } catch (e) {
    throw Exception('No se pudo obtener la lista de ubicaciones. Verifica la conexión.');
  }


 }


 @override
 Future<bool> createLocationFromCoord(Location location) async {
   try {

      if (location.coordinate.lat == null || location.coordinate.long == null) {
        throw Exception("Coordenadas inválidas: latitud o longitud no pueden ser nulas.");
      }

       await db
        .collection(_collectionName) // Colección raíz (por ejemplo, "production")
        .doc(_currentUser?.uid) // Documento del usuario actual
        .collection("LocationList") // Subcolección "LocationList"
        .add(location.toMap()); // Agregar el lugar

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

}






abstract class DbAdapterLocation {
 Future<bool> createLocationFromCoord(Location location);
 Future<bool> createLocationFromTopo(Location location);
 Future<Set<Location>> getLocationList();
 Future<bool> addFav(String topo, String alias);
 Future<bool> removeFav(String topo, String alias);
}
