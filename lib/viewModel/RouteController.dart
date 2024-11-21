
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:WayFinder/model/Route.dart';


class RouteController {
  
  // Propiedades
  late Set<Route> routeList;
  final DbAdapterRoute _dbAdapter;

  RouteController(this._dbAdapter) : routeList = _dbAdapter.getRouteList();

 Set<Route> getRouteList(){
  return routeList;
 }

  Route? createRoute(Location start, Location end, String transportMode, String routeMode){

    Route route = Route(start, end, getDistance(start, end), getPoints(start, end), transportMode, routeMode) ;
    return route;
  }

  double getDistance(Location start, Location end) {
    throw UnimplementedError("Method not implemented");
  }
  
  List<Coordinate> getPoints(Location start, Location end) {
    throw UnimplementedError("Method not implemented");
  }


  Future<bool> saveRoute(Route route) {
     Future<bool> result = _dbAdapter.saveRoute(route);
    routeList.add(route);
    return result;
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
    try {
      await db.collection(_collectionName).add(routeRoute.toMap());
      return true;
    } catch (e) {
      print("Error al crear Location: $e");
      return false;

    }
  }
  

  
}



abstract class DbAdapterRoute {
  Future<Route?> createRoute(Route route);
  Set<Route> getRouteList();

    Future<bool> saveRoute(Route route);


}


