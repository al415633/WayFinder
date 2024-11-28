import 'dart:convert';

import 'package:WayFinder/model/favItemController.dart';
import 'package:http/http.dart' as http;
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/APIs/apiConection.dart';

class Location implements FavItem{
  // Propiedades

  Coordinate coordinate = Coordinate(0, 0); 
  String toponym = "";
  String alias = "";
  late bool fav;

  // Constructor
  Location(double lat, double long, String alias)  {
    coordinate = Coordinate(lat, long);
    //obtainToponym(CoordToToponym(coordinate));
    //toponym =  CoordToToponym(coordinate) as String ;
    this.alias = alias;
    this.fav = false;
  }

  Location.fromToponym(String toponym, String alias) {
    this.toponym = toponym;
    coordinate = ToponymToCoord(toponym) as Coordinate;
    this.alias = alias;
    this.fav = false;
  }

 Location.fromMap(Map<String, dynamic> mapa) {
  if (mapa['lat'] == null || mapa['long'] == null) {
    throw Exception("Datos incompletos: latitud o longitud faltantes.");
  }
  coordinate = Coordinate(mapa['lat'], mapa['long']);
  toponym = mapa['toponym'] ?? "Sin topónimo";
  alias = mapa['alias'] ?? "Sin alias";
  fav = mapa['fav'] ?? false;
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

  // Método para pasar de coordinates a toponym
  Future<String> CoordToToponym(Coordinate coord) async{
    http.Response? response;
   
    response = await http.get(getToponymLocation(coord));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        final name = data['features'][0]['properties']['label'];
        return name; // Devuelve el nombre del lugar
      } else {

         throw Exception("InvalidCoordinatesException: 'No se encontró ningún lugar para las coordenadas dadas.");
      }
    } else {
         throw Exception("InvalidCoordinatesException: ${response.statusCode}");

      
    }
  }

  Coordinate getCoordinate(){
    return coordinate;
  }

  String getToponym() {
    return toponym;
  }

  void obtainToponym(Future<String> topo) async{

    //toponym = await topo;
    

  }

  String getAlias() {
    return alias;
  }

    void setFav(bool b) {
     this.fav = b;
  }

  // Método para pasar de  toponym a coordinates
  //TO DO: Revisar los nulos y que en vez de eso mande excepción 
  Future<Coordinate?> ToponymToCoord(String topo)  async {
    http.Response? response;
   
    response = await http.get(getCoordinatesLocation(topo));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        return Coordinate(coords[1], coords[0]); // latitud y longitud
      } else {
        print('No se encontró ningún resultado para el topónimo dado.');
        return null;
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return null;
    }
  }



  Map<String, dynamic> toMap() {
    return {
      //'coord': coordinate,
      'lat': coordinate.lat,
      'long' : coordinate.long,
      'toponym': toponym,
      'alias': alias,
      'fav' : fav
    };
  }
  
}
