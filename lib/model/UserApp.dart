import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserApp {
  // Por defeto que se ponga a A Pie  el modo de transporte y que se pueda cambiar


  late String id;
  late String name;
  late String email;
  late User? user;

  late TransportMode defaultTransportMode;
  late Vehicle vehicledefault;

  TransportMode get getDefaultTransportMode => defaultTransportMode;
  Vehicle get getVehicleDefault => vehicledefault;


  set setDefaultTransportMode(TransportMode defaultTransportMode) => this.defaultTransportMode = defaultTransportMode;
  set setVehicleDefault(Vehicle vehicledefault) => this.vehicledefault = vehicledefault;


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
}