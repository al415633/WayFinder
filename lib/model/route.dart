import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:latlong2/latlong.dart';

class Routes implements FavItem {
  // Propiedades
  late String name;
  late Location start;
  late Location end;
  late double distance;
  late double time;
  List<LatLng> points = [];
  bool fav;
  late TransportMode transportMode;
  late RouteMode? routeMode;
  late double calories;
  late double cost;
  late Vehicle? vehicle;

  // Constructor
  Routes(String name, Location start, Location end, List<LatLng> points,
      double distance, double time, TransportMode transportMode, RouteMode? routeMode, Vehicle? vehicle,
      {this.fav = false, this.calories = 0.0, this.cost = 0.0}) {
    this.name = name;
    this.start = start;
    this.end = end;
    this.distance = distance;
    this.time = time;
    this.points = points;
    this.transportMode = transportMode;
    this.routeMode = routeMode;
    this.vehicle = vehicle;
  }

  Routes.fromMap(Map<String, dynamic> mapa) : fav = mapa['fav'] ?? false {
    name = mapa['name'];
    start = Location.fromMap(mapa['start']);
    end = Location.fromMap(mapa['end']);
    distance = mapa['distance'];
    time = mapa['time'];
    points = (mapa['points'] as List<dynamic>)
        .map((point) => Coordinate.fromMap(point)).cast<LatLng>()
        .toList();
    fav = fav;
    transportMode = TransportMode.values.firstWhere((e) => e.toString().split('.').last == mapa['transportMode']);
    routeMode = RouteMode.values.firstWhere((e) => e.toString().split('.').last == mapa['routeMode']);
    calories = mapa['calories'] ?? 0.0;
    cost = mapa['cost'] ?? 0.0;
    vehicle = mapa['vehicle'];
 }

  @override
  bool getFav() => fav;

  @override
  void addFav() {
    fav = true;
  }

  @override
  void removeFav() {
    fav = false;
  }
 

  String get getName => name;
  Location get getStart => start;
  Location get getEnd => end;
  double get getDistance => distance;
  double get getTime => time;
  List<LatLng> get getPoints => points;
  TransportMode get getTransportMode => transportMode;
  RouteMode? get getRouteMode => routeMode;
  double get getCalories => calories;
  double get getCost => cost;
  Vehicle? get getVehicle => vehicle;

  set setName(String name) => this.name = name;
  set setStart(Location start) => this.start = start;
  set setEnd(Location end) => this.end = end;
  set setDistance(double distance) => this.distance = distance;
  set setTime(double time) => this.time = time;
  set setPoints(List<LatLng> points) => this.points = points;
  set setTransportMode(TransportMode transportMode) => this.transportMode = transportMode;
  set setRouteMode(RouteMode routeMode) => this.routeMode = routeMode;
  set setCalories(double calories) => this.calories = calories;
  set setCost(double cost) => this.cost = cost;
  set setVehicle(Vehicle vehicle) => this.vehicle = vehicle;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start': start.toMap(),
      'end': end.toMap(),
      'distance': distance,
      'time': time,
      'points': points.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      'fav': fav,
      'transportMode': transportMode.toString().split('.').last,  // Convertimos el enum a string
      'routeMode': routeMode.toString().split('.').last,  // Convertimos el enum a string
      'calories' : calories,
      'cost' : cost,
      'vehicle' : vehicle,
  };
  }
}
