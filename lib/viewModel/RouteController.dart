import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';


import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:WayFinder/model/route.dart';
import 'package:firebase_auth/firebase_auth.dart';




class RouteController {
  // Propiedades
 late Future<Set<Routes>> routeList;
 final DbAdapterRoute _dbAdapter;



RouteController(this._dbAdapter) {
    try {
      routeList = _dbAdapter.getRouteList();
    } catch (e) {
      routeList = Future.error(e);
    }
  }

 Future<Set<Routes>> getRouteList() async {
    try {
      return await routeList;
    } catch (e) {
      throw Exception("Error al obtener la lista de rutas: $e");
    }
  }



 Routes createRoute(String name, Location start, Location end, String transportMode, String routeMode) {

   Routes route = Routes(name, start, end, getDistance(start, end), getPoints(start, end), transportMode, routeMode) ;

  return route;
    
 }

Future<bool> saveRoute(Routes route) async{
 try{

        bool success =  await this._dbAdapter.saveRoute(route);
        
        if (success){

          final currentSet = await routeList;

          // Agregar el nuevo Location al Set
          currentSet.add(route);
        }

        return success;
     } catch (e) {
    print("Error al crear la ruta: $e");
    return false;
  }
}

 double getDistance(Location start, Location end) {
   
   return 0;
 }
  List<Coordinate> getPoints(Location start, Location end) {
   return [];
 }

  Future<bool> addFav(String routeName) async {
    try {
      // Llamar al adaptador para marcar como favorita en la base de datos
      bool success = await _dbAdapter.addFav(routeName);

      if (success) {
        // Si se actualiza con éxito, reflejar en la lista local
        final currentSet = await routeList;
        for (var route in currentSet) {
          if (route.name == routeName) {
            route.fav = true; // Actualizar la propiedad `fav` en la lista local
            break;
          }
        }
      }

      return success;
    } catch (e) {
      print("Error al añadir la ruta a favoritos: $e");
      return false;
    }
  }

  Future<bool> removeFav(String routeName) async {
    try {
      // Llamar al adaptador para desmarcar como favorita en la base de datos
      bool success = await _dbAdapter.removeFav(routeName);

      if (success) {
        // Si se actualiza con éxito, reflejar en la lista local
        final currentSet = await routeList;
        for (var route in currentSet) {
          if (route.getName() == routeName) {
            route.fav = false; // Actualizar la propiedad `fav` en la lista local
            break;
          }
        }
      }

      return success;
    } catch (e) {
      print("Error al eliminar la ruta de favoritos: $e");
      return false;
    }
  }

}




class FirestoreAdapterRoute implements DbAdapterRoute {
 final String _collectionName;
 final FirebaseFirestore db = FirebaseFirestore.instance;

 User? _currentUser; // Propiedad para almacenar el usuario actual



 FirestoreAdapterRoute({String collectionName = "production"})
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
  Future<Set<Routes>> getRouteList() async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .get();

      // Convertir cada documento a una instancia de Route
      Set<Routes> routes = querySnapshot.docs.map((doc) {
        return Routes.fromMap(doc.data());
      }).toSet();

      return routes;
    } catch (e) {
      throw Exception("Error al obtener la lista de rutas: $e");
    }
  }




  @override
 Future<bool> saveRoute(Routes route) async{
    try {
      await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .add(route.toMap());
      return true;
    } catch (e) {
      print("Error al guardar la ruta: $e");
      return false;
    }
 }


 Future<bool> addFav(String routeName) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: routeName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': true});
      }

      return true;
    } catch (e) {
      print("Error al añadir la ruta a favoritos en la base de datos: $e");
      return false;
    }
  }

  Future<bool> removeFav(String routeName) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: routeName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': false});
      }

      return true;
    } catch (e) {
      print("Error al eliminar la ruta de favoritos en la base de datos: $e");
      return false;
    }
  }

 }






abstract class DbAdapterRoute {
 Future<bool> saveRoute(Routes route);
 Future<Set<Routes>> getRouteList();
 Future<bool> removeFav(String routeName) ;
 Future<bool> addFav(String routeName) ;




}







