
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:WayFinder/model/Route.dart';


class RouteController {
  
  // Propiedades
  late Set<Route> routeList;
  final DbAdapterRoute _dbAdapter;

  // Constructor privado
  RouteController._internal(this._dbAdapter) : routeList = _dbAdapter.getRouteList();


  // Instancia única
  static RouteController? _instance;
  
  factory RouteController(DbAdapterRoute dbAdapter) {
      _instance ??= RouteController._internal(dbAdapter);
      return _instance!;
    }


 Set<Route> getRouteList(){
  return routeList;
 }

  Route? createRoute(Location start, Location end, String transportMode, String routeMode){

       throw UnimplementedError("Method Not Implemented");

  }

  double getDistance(Location start, Location end) {
    throw UnimplementedError("Method not implemented");
  }
  
  List<Coordinate> getPoints(Location start, Location end) {
    throw UnimplementedError("Method not implemented");
  }


  Future<bool> saveRoute(Route route) {
          throw UnimplementedError("Method Not Implemented");

  }

}


class FirestoreAdapterRoute implements DbAdapterRoute {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapterRoute({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Route> getRouteList(){


    //implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<Route?> createRoute(Route route) {
    // TODO: implement crearRoute
    throw UnimplementedError("Method not implemented");
  }
  
  @override
  Future<bool> saveRoute(Route routeRoute) async{
         throw UnimplementedError("Method Not Implemented");

  }
  

  
}



abstract class DbAdapterRoute {
  Future<Route?> createRoute(Route route);
  Set<Route> getRouteList();

    Future<bool> saveRoute(Route route);


}


