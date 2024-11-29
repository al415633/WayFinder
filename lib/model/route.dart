
import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/transportMode.dart';

class Routes implements FavItem {
  // Propiedades

String name = "";
Location start = Location(0, 0, "");
Location end = Location(0, 0, "");
double distance = 0;
List<Coordinate> points = [];
bool fav;
TransportMode transportMode = TransportMode.aPie;
String routeMode = "rápida";


  // Constructor
  Routes(String name, Location start, Location end, double distance, List<Coordinate> points, TransportMode transportMode, String routeMode, {this.fav = false}){
    this.name = name;
    this.start = start;
    this.end = end;
    this.distance = distance;
    this.points = points;
    fav = false;
    this.transportMode = transportMode;
    this.routeMode = routeMode;
  }

/*
  Route.fromMap(Map<String, dynamic> map): fav = mapa['fav'] ?? false  {
    
      start = Location.fromMap(map['start']);
      end = Location.fromMap(map['end']);
      distance = map['distance'];
      points = (map['points'] as List<dynamic>)
          .map((point) => Coordinate.fromMap(point))
          .toList();
      transportMode = map['transportMode'];
      routeMode = map['routeMode'];
    
  }
  */

  Routes.fromMap(Map<String, dynamic> mapa) : fav = mapa['fav'] ?? false {

  name = mapa['name'];
  start = Location.fromMap(mapa['start']);
  end = Location.fromMap(mapa['end']);
  distance = mapa['distance'];
  points = (mapa['points'] as List<dynamic>)
          .map((point) => Coordinate.fromMap(point))
          .toList();
  fav = fav;
  transportMode = mapa['transportMode'];
  routeMode = mapa['routeMode'];
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

  double calculateCostFuel(String fuelType, double consumption){
    //TO DO : FALTA IMPLEMENTAR
    return 0;
  }

  double calculateCostKCal(){
   double avgConsumption = 55;
    return distance * avgConsumption;
  }

  String getName(){
    return name;
  }

  Location getStart(){
      return start;
  }


  Location getEnd(){
    return end;
  }

  double getDistance(){
    return distance;
  }

  

  List<Coordinate> getPoints(){
    return points;
  }

  TransportMode getTransportMode(){
    return transportMode;
  }

  void setTransportMode(TransportMode transportMode){
  transportMode = transportMode;
  }

  String getRouteMode(){
    return routeMode;
  }

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'start': start.toMap(),
      'end': end.toMap(),
      'distance': distance,
      'points': points.map((point) => point.toMap()).toList(),      
      'fav' : fav,
      'transportMode' : transportMode,
      'routeMode': routeMode,
    };
  }     
}





