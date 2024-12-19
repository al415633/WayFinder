import 'package:WayFinder/model/location.dart';

abstract class DbAdapterLocation {
  Future<bool> createLocationFromCoord(Location location);
  Future<bool> createLocationFromTopo(Location location);
  Future<bool> deleteLocation(Location location);
  Future<Set<Location>> getLocationList();
  Future<bool> addFav(Location location);
  Future<bool> removeFav(Location location);
}
