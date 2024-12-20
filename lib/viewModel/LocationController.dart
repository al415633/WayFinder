import 'package:WayFinder/exceptions/%20APICoordenadasException.dart';
import 'package:WayFinder/exceptions/APIToponimoException.dart';
import 'package:WayFinder/exceptions/InvalidCoordinatesException.dart';
import 'package:WayFinder/exceptions/InvalidToponimoException.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:WayFinder/APIs/apiConection.dart';

class LocationController {
  // Propiedades

  late Future<Set<Location>> locationList;
  final DbAdapterLocation _dbAdapter;

  LocationController(this._dbAdapter) {
    locationList = _dbAdapter.getLocationList();
  }

  static LocationController? _instance;

  static LocationController getInstance(DbAdapterLocation dbAdapter) {
    _instance ??= LocationController(dbAdapter);
    return _instance!;
  }

  static void destroyInstance() {
    _instance = null;
  }


  Future<Set<Location>> getLocationList() async {
    return locationList;
  }

  Future<Location> createLocationFromCoord(
      double lat, double long, String alias) async {
    lat = double.parse(lat.toStringAsFixed(6));
    long = double.parse(long.toStringAsFixed(6));
    if (lat > 90 || lat < -90) {
      throw InvalidCoordinatesException();
    }
    if (long > 180 || long < -180) {
      throw InvalidCoordinatesException();
    }

    Coordinate coordinate = Coordinate(lat, long);
    String toponym = await CoordToToponym(coordinate);

    Location location = Location(coordinate, toponym, alias);

    try {
      await _dbAdapter.createLocationFromCoord(location);
      final currentSet = await locationList;
      currentSet.add(location);
      locationList = Future.value(currentSet);
      return location;
    } catch (e) {
      throw Exception("Error al crear el lugar: $e");
    }
  }

  Future<Location> createLocationFromTopo(String topo, String alias) async {
    Coordinate coordinate = await ToponymToCoord(topo);

    Location location = Location(coordinate, topo, alias);

    try {
      await _dbAdapter.createLocationFromTopo(location);
      final currentSet = await locationList;
      currentSet.add(location);
      locationList = Future.value(currentSet);
      return location;
    } catch (e) {
      throw Exception("Error al crear el lugar: $e");
    }
  }

  Future<bool> deleteLocation(Location location) async {
    try {
      bool success = await _dbAdapter.deleteLocation(location);

      if (success) {
        final currentSet = await locationList;
        // Agregar el nuevo Location al Set
        currentSet.remove(location);
        locationList = Future.value(currentSet);
      }

      return success;
    } catch (e) {
      throw Exception("Error al crear el lugar de interés: $e");
    }
  }

  void addFav(Location location) async {
    try {
      _dbAdapter.addFav(location);
      final currentSet = await locationList;
      location.addFav();
      locationList = Future.value(currentSet);
    } catch (e) {
      throw Exception("Error al añadir a favoritos en el controlador: $e");
    }
  }

  void removeFav(Location location) async {
    try {
      _dbAdapter.removeFav(location);
      final currentSet = await locationList;
      location.removeFav();
      locationList = Future.value(currentSet);
      
    } catch (e) {
      throw Exception("Error al eliminar de favoritos en el controlador: $e");
    }
  }

  // Método para pasar de coordinates a toponym
  Future<String> CoordToToponym(Coordinate coord) async {
    http.Response? response;
    response = await http.get(getToponymLocation(coord));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        final name = data['features'][0]['properties']['label'];
        return name;
      } else {
        throw Exception(
            "InvalidCoordinatesException: 'No se encontró ningún lugar para las coordenadas dadas.");
      }
    } else {
      throw APICoordenadasException();
    }
  }

  // Método para pasar de  toponym a coordinates
  //TO DO: Revisar los nulos y que en vez de eso mande excepción
  Future<Coordinate> ToponymToCoord(String topo) async {
    http.Response? response;

    response = await http.get(getCoordinatesLocation(topo));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        return Coordinate(coords[1], coords[0]); // latitud y longitud
      } else {
        throw InvalidToponimoException();
      }
    } else {
      throw APIToponimoException();
    }
  }
}

