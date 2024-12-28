import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserApp {
  late String id;
  late String name;
  late String email;
  late User? user;

  // Por defeto que se ponga a A Pie  el modo de transporte y que se pueda cambiar
  TransportMode defaultTransportMode = TransportMode.noSeleccionado;
  RouteMode defaultRouteMode = RouteMode.noSeleccionado;
  //Para si elige en coche
  Vehicle? vehicledefault;

  TransportMode get getDefaultTransportMode => defaultTransportMode;
  RouteMode get getDefaultRouteMode => defaultRouteMode;

  Vehicle? get getVehicleDefault => vehicledefault;

  set setDefaultTransportMode(TransportMode defaultTransportMode) =>
      this.defaultTransportMode = defaultTransportMode;
  set setVehicleDefault(Vehicle? vehicledefault) =>
      this.vehicledefault = vehicledefault;
  set setDefaultRouteMode(RouteMode defaultRouteMode) =>
      this.defaultRouteMode = defaultRouteMode;

  // Constructor
  UserApp(this.id, this.name, this.email);

  // Getters
  String get getId => id;
  String get getName => name;
  String get getEmail => email;
  User? get getUser => user;

  // Setters
  set setId(String id) => this.id = id;
  set setName(String name) => this.name = name;
  set setEmail(String email) => this.email = email;
  set setUser(User? user) => this.user = user;

  // Método toString
  @override
  String toString() {
    return 'User name: $name, email: $email';
  }

  // Método fromMap
  UserApp.fromMap(Map<String, dynamic> map) {
    defaultTransportMode = map['defaultTransportMode'];
    vehicledefault = map['vehicledefault'] != null
        ? Vehicle.fromMap(map['vehicledefault'])
        : null;
    defaultRouteMode = map['defaultRouteMode'];
  }

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'defaultTransportMode': defaultTransportMode.name,
      'vehicledefault': vehicledefault?.toMap(),
      'defaultRouteMode': defaultRouteMode.name,
    };
  }
}
