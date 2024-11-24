
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/coordinate.dart';

class Route {
  // Propiedades

late Location start;
late Location end;
late double distance;
late List<Coordinate> points;
late bool fav;
late String transportMode;
late String routeMode;


  // Constructor
  Route(Location start, Location end, double distance, List<Coordinate> points, String transportMode, String routeMode){
    start = start;
    end = end;
    distance = distance;
    points = [];
    fav = false;
    transportMode = transportMode;
    routeMode = routeMode;
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
      'points': points,
      'fav' : fav,
      'transportMode' : transportMode,
      'routeMode': routeMode,
    };
  }     
}
