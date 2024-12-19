import 'package:WayFinder/model/vehicle.dart';

abstract class DbAdapterVehicle {
  Future<bool> createVehicle(Vehicle vehicle);
  Future<Set<Vehicle>> getVehicleList();
  Future<bool> deleteVehicle(Vehicle vehicle);
  void addFav(Vehicle vehicle);
  void removeFav(Vehicle vehicle);
  Future<bool> editVehicle(Vehicle vehicle);
}
