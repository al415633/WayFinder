import 'package:WayFinder/exceptions/%20APICoordenadasException.dart';
import 'package:WayFinder/exceptions/APIToponimoException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/InvalidCoordinatesException.dart';
import 'package:WayFinder/exceptions/InvalidToponimoException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<bool> addFav(String topo, String alias) async {
    try {
      bool success = await _dbAdapter.addFav(topo, alias);

      if (success) {
        // Si la operación fue exitosa, actualizar la lista local
        final currentSet = await locationList;
        for (var location in currentSet) {
          if (location.getToponym() == topo && location.getAlias() == alias) {
            location.fav = true; // Marcar como favorito en la lista local

            break;
          }
        }
      }
      return success;
    } catch (e) {
      throw Exception("Error al añadir a favoritos en el controlador: $e");
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
      throw  APICoordenadasException();
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
      throw  APIToponimoException();
    }
  }

  Future<bool> removeFav(String topo, String alias) async {
    try {
      // Llamar al método del adaptador para quitar de favoritos en la base de datos
      bool success = await _dbAdapter.removeFav(topo, alias);

      if (success) {
        // Si la operación fue exitosa, actualizar la lista local
        final currentSet = await locationList;
        for (var location in currentSet) {
          if (location.getToponym() == topo && location.getAlias() == alias) {
            location.fav = false; // Desmarcar como favorito en la lista local
            break;
          }
        }
      }
      return success;
    } catch (e) {
      throw Exception("Error al eliminar de favoritos en el controlador: $e");
    }
  }
}

class FirestoreAdapterLocation implements DbAdapterLocation {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterLocation({String collectionName = "production"})
      : _collectionName = collectionName {
    // Configurar el listener para authStateChanges
    _initializeAuthListener();
  }

  // Método para inicializar el listener de autenticación
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
    });
  }

  @override
  Future<Set<Location>> getLocationList() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("LocationList")
          .get();

      // Convertir cada documento a una instancia de Location
      Set<Location> locations = querySnapshot.docs.map((doc) {
        return Location.fromMap(doc.data());
      }).toSet();

      return locations;
    } catch (e) {
      throw ConnectionBBDDException(
          'No se pudo obtener la lista de ubicaciones. Verifica la conexión.');
    }
  }

  @override
  Future<bool> createLocationFromCoord(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("LocationList")
          .add(location.toMap());
      return true;
    } catch (e) {
      throw ConnectionBBDDException('Error al crear el lugar: $e');
    }
  }

  @override
  Future<bool> createLocationFromTopo(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(_currentUser?.uid) // Documento del usuario actual
          .collection("LocationList") // Subcolección "LocationList"
          .add(location.toMap());
      return true;
    } catch (e) {
      print("Error al crear el lugar: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteLocation(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      // Obtener la colección de lugares de interés del usuario
      var collectionRef = db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("LocationList");

      // Buscar el documento por algún atributo único del lugar de interés, como no lo tiene, revisamos tres para asegurarnos de que sea el correcto
      var querySnapshot = await collectionRef
          .where('lat', isEqualTo: location.getCoordinate().lat)
          .where('long', isEqualTo: location.getCoordinate().long)
          .where('toponym', isEqualTo: location.getToponym())
          .where('alias', isEqualTo: location.getAlias())
          .get();

      // Verificar si se encontró el documento
      if (querySnapshot.docs.isEmpty) {
        throw ConnectionBBDDException('Lugar de interés no encontrado.');
      }

      // Eliminar el primer documento encontrado
      await querySnapshot.docs.first.reference.delete();

      return true;
    } catch (e) {
      throw ConnectionBBDDException("Error al eliminar el lugar de interés: $e");
    }
  }

  @override
  Future<bool> addFav(String topo, String alias) async {
    // Obtener la referencia al documento con el topónimo y alias correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("LocationList")
        .where("toponym", isEqualTo: topo)
        .where("alias", isEqualTo: alias)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException(
          "No se encontró la ubicación con el topónimo '$topo' y alias '$alias'.");
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": true});

    return true;
  }

  @override
  Future<bool> removeFav(String topo, String alias) async {
    try {
      // Obtener la referencia al documento con el topónimo y alias correspondiente
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("LocationList")
          .where("toponym", isEqualTo: topo)
          .where("alias", isEqualTo: alias)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw ConnectionBBDDException(
            "No se encontró la ubicación con el topónimo '$topo' y alias '$alias'.");
      }

      // Actualizar el campo 'fav' a false en el primer documento encontrado
      await querySnapshot.docs.first.reference.update({"fav": false});

      return true;
    } catch (e) {
      print("Error al eliminar de favoritos: $e");
      return false;
    }
  }
}

abstract class DbAdapterLocation {
  Future<bool> createLocationFromCoord(Location location);
  Future<bool> createLocationFromTopo(Location location);
  Future<bool> deleteLocation(Location location);
  Future<Set<Location>> getLocationList();
  Future<bool> addFav(String topo, String alias);
  Future<bool> removeFav(String topo, String alias);
}
