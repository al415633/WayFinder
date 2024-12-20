import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';

abstract class DbAdapterUserApp {
  Future<UserApp?> createUser(String email, String password);
  Future<UserApp?> logInCredenciales(String email, String password);
  Future<bool> logOut();
  void setTransportModeDefault(TransportMode transportMode, Vehicle? vehicle);
}