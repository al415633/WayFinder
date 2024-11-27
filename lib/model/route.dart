
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/coordinate.dart';

class Routes {
  // Propiedades

Location start = Location(0, 0, "");
Location end = Location(0, 0, "");
double distance = 0;
List<Coordinate> points = [];
bool fav = false;
String transportMode = "a pie";
String routeMode = "rápida";


  // Constructor
  Routes(Location start, Location end, double distance, List<Coordinate> points, String transportMode, String routeMode){
    this.start = start;
    this.end = end;
    this.distance = distance;
    this.points = points;
    this.fav = false;
    this.transportMode = transportMode;
    this.routeMode = routeMode;
  }

/*
  Route.fromMap(Map<String, dynamic> map) {
    
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

   Routes.fromMap(Map<String, dynamic> mapa) {
  
  this.start = Location.fromMap(mapa['start']);
  this.end = Location.fromMap(mapa['end']);
  this.distance = mapa['distance'];
  this.points = (mapa['points'] as List<dynamic>)
          .map((point) => Coordinate.fromMap(point))
          .toList();

  this.fav = fav;
  this.transportMode = mapa['transportMode'];
  this.routeMode = mapa['routeMode'];
   }



  double calculateCostFuel(String fuelType, double consumption){
    //TO DO : FALTA IMPLEMENTAR
    return 0;
  }

  double calculateCostKCal(){
   double avgConsumption = 55;
    return distance * avgConsumption;
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

  String getTransportMode(){
    return transportMode;
  }

  String getRouteMode(){
    return routeMode;
  }

  Map<String, dynamic> toMap() {
    return {
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





