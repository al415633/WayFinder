
import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/model/coordinate.dart';

class Location implements FavItem{
  // Propiedades

  Coordinate coordinate = Coordinate(0, 0); 
  String toponym = "";
  String alias = "";
  late bool fav;

  // Constructor
    Location(Coordinate coordinate, String toponym, String alias, {this.fav = false}) {
    this.coordinate = coordinate;
    this.toponym = toponym;
    this.alias = alias;
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

  Coordinate getCoordinate(){
    return coordinate;
  }

  String getToponym() {
    return toponym;
  }

  String getAlias() {
    return alias;
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

  @override
  String toString() {
    return 'Location(toponym: $toponym, alias: $alias, coordinate: $coordinate, fav: $fav)';
  }

  // Sobrescribe `==` para comparar por nombre
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Compara la referencia
    if (other is! Location) return false; // Verifica el tipo
    return alias == other.alias; 
  }

    //return alias == other.alias && coordinate == other.coordinate && toponym == other.toponym;

  // Sobrescribe `hashCode` para usar `alias`
  @override
  int get hashCode => alias.hashCode;

  //Object.hash(alias, coordinate, toponym);
  
}
