import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';


import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:WayFinder/model/Route.dart';
import 'package:firebase_auth/firebase_auth.dart';




class RouteController {
  // Propiedades
 late Future<Set<Route>> routeList;
 final DbAdapterRoute _dbAdapter;



RouteController(this._dbAdapter) {
    try {
      routeList = _dbAdapter.getRouteList();
    } catch (e) {
      routeList = Future.error(e);
    }
  }

 Future<Set<Route>> getRouteList() async {
    try {
      return await routeList;
    } catch (e) {
      throw Exception("Error al obtener la lista de rutas: $e");
    }
  }



 Future<bool> createRoute(Location start, Location end, String transportMode, String routeMode) async{

   Route route = Route(start, end, getDistance(start, end), getPoints(start, end), transportMode, routeMode) ;

     try{

        bool success =  await this._dbAdapter.createRoute(route);
        
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
   throw UnimplementedError("Method not implemented");
 }
  List<Coordinate> getPoints(Location start, Location end) {
   throw UnimplementedError("Method not implemented");
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
  Future<Set<Route>> getRouteList() async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .get();

      // Convertir cada documento a una instancia de Route
      Set<Route> routes = querySnapshot.docs.map((doc) {
        return Route.fromMap(doc.data());
      }).toSet();

      return routes;
    } catch (e) {
      throw Exception("Error al obtener la lista de rutas: $e");
    }
  }




  @override
 Future<bool> createRoute(Route route) async{
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


 }






abstract class DbAdapterRoute {
 Future<bool> createRoute(Route route);
 Future<Set<Route>> getRouteList();




}







