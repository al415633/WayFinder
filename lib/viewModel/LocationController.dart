import 'package:WayFinder/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationController {
 // Propiedades


   late Future<Set<Location>> locationList;
   final DbAdapterLocation _dbAdapter;


  LocationController(this._dbAdapter) {
    locationList = _dbAdapter.getLocationList();
  }

  static LocationController? _instance;

  static LocationController getInstance(DbAdapterLocation dbAdapter){
    _instance ??= LocationController(dbAdapter);
    return _instance!;
  }

  Future<Set<Location>> getLocationList() async {
    //locationList = _dbAdapter.getLocationList();
    return locationList;
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

        bool success =  await _dbAdapter.createLocationFromCoord(location);
        
        if (success){
          final currentSet = await locationList;
          // Agregar el nuevo Location al Set
          currentSet.add(location);
          locationList = Future.value(currentSet) ;
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
      locationList = Future.value(currentSet) ;

     }

     return success;
   }





   Future<bool> addFav(String topo, String alias) async{

      try {
          bool success = await _dbAdapter.addFav(topo, alias);

          if (success) {
            // Si la operación fue exitosa, actualizar la lista local
            final currentSet = await locationList;
            for (var location in currentSet) {
              if (location.getToponym() == topo && location.getAlias() == alias) {
                location.fav = true; // Marcar como favorito en la lista local

                break;
              }
            }
          }

          return success;
        } catch (e) {
          throw Exception("Error al añadir a favoritos en el controlador: $e");
        }
      
   }


   Future<bool> removeFav(String topo, String alias) async{

     try {
    // Llamar al método del adaptador para quitar de favoritos en la base de datos
    bool success = await _dbAdapter.removeFav(topo, alias);

    if (success) {
      // Si la operación fue exitosa, actualizar la lista local
      final currentSet = await locationList;
      for (var location in currentSet) {
        if (location.getToponym() == topo && location.getAlias() == alias) {
          location.fav = false; // Desmarcar como favorito en la lista local
          break;
        }
      }
    }

    return success;
  } catch (e) {
          throw Exception("Error al eliminar de favoritos en el controlador: $e");
        }
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
    print("llega aqui");
    throw Exception('No se pudo obtener la lista de ubicaciones. Verifica la conexión.');
  }


 }


 @override
 Future<bool> createLocationFromCoord(Location location) async {
   
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado. No se puede crear el location.');
    }

    try {
      await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("LocationList")
          .add(location.toMap());
      return true;
    } catch (e) {
      throw Exception('Error al crear el lugar: $e');
    }
 }
 
 @override
 Future<bool> createLocationFromTopo(Location location) async {
   try {
     await db
        .collection(_collectionName)
        .doc(_currentUser?.uid) // Documento del usuario actual
        .collection("LocationList") // Subcolección "LocationList"
        .add(location.toMap());
     return true;
   } catch (e) {
     print("Error al crear el lugar: $e");
     return false;
   }
 }
  @override
 Future<bool> addFav(String topo, String alias) async {

    // Obtener la referencia al documento con el topónimo y alias correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("LocationList")
        .where("toponym", isEqualTo: topo)
        .where("alias", isEqualTo: alias)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No se encontró la ubicación con el topónimo '$topo' y alias '$alias'.");
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": true});

    return true;
  
 }

  @override
 Future<bool> removeFav(String topo, String alias) async {
  try {
    // Obtener la referencia al documento con el topónimo y alias correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("LocationList")
        .where("toponym", isEqualTo: topo)
        .where("alias", isEqualTo: alias)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No se encontró la ubicación con el topónimo '$topo' y alias '$alias'.");
    }

    // Actualizar el campo 'fav' a false en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": false});

    return true;
  } catch (e) {
    print("Error al eliminar de favoritos: $e");
    return false;
  }
 }

}






abstract class DbAdapterLocation {
 Future<bool> createLocationFromCoord(Location location);
 Future<bool> createLocationFromTopo(Location location);
 Future<Set<Location>> getLocationList();
 Future<bool> addFav(String topo, String alias);
 Future<bool> removeFav(String topo, String alias);
}
