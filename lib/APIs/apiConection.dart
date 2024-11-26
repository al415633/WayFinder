/// OPENROUTESERVICE DIRECTION SERVICE REQUEST 
/// Parameters are : startPoint, endPoint and api key
library;

import 'package:WayFinder/model/coordinate.dart';

const String apiKey = '5b3ce3597851110001cf6248f55d7a31499e40848c6848d7de8fa624';
const String urlCar = 'https://api.openrouteservice.org/v2/directions/driving-car';
const String urlBike = 'https://api.openrouteservice.org/v2/directions/cycling-regular';
const String urlWalk = 'https://api.openrouteservice.org/v2/directions/foot-walking';
const String urlToponym= 'https://api.openrouteservice.org/geocode/search';
const String urlCoordinate= 'https://api.openrouteservice.org/geocode/reverse';

getCarRouteUrl(String startPoint, String endPoint){
  return Uri.parse('$urlCar?api_key=$apiKey&start=$startPoint&end=$endPoint');
}

getBikeRouteUrl(String startPoint, String endPoint){
  return Uri.parse('$urlBike?api_key=$apiKey&start=$startPoint&end=$endPoint');
}

getWalkRouteUrl(String startPoint, String endPoint){
  return Uri.parse('$urlWalk?api_key=$apiKey&start=$startPoint&end=$endPoint');
}

getCoordinatesLocation(String topo){
  return Uri.parse('$urlToponym?api_key=$apiKey&text=$topo&size=1');
}


getToponymLocation(Coordinate coord) {
  return Uri.parse('$urlCoordinate?api_key=$apiKey&point.lat=${coord.getLat}&point.lon=${coord.getLong}');
}
