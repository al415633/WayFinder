import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:latlong2/latlong.dart';

abstract class DbAdapterRoute {
  Future<bool> saveRoute(Routes route);
  Future<bool> deleteRoute(Routes route);
  Future<Set<Routes>> getRouteList();
  void removeFav(Routes route);
  void addFav(Routes route);
  Future<Map<String, dynamic>> getRouteData(Location start, Location end,
      TransportMode transportMode, RouteMode routeMode);
  Future<Map<String, dynamic>> getPoints(LatLng initialPoint,
      LatLng destination, TransportMode transportMode, RouteMode routeMode);
  String getApiPreferenceFromRouteMode(RouteMode mode);
}
