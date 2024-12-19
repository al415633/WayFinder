import 'package:WayFinder/exceptions/APIRoutesExcpetion.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/MissingInformationRouteException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'dart:convert';
import 'package:WayFinder/APIs/apiConection.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterRoute.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:WayFinder/model/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';


class FirestoreAdapterRoute implements DbAdapterRoute {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterRoute({String collectionName = "production"})
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
  Future<Set<Routes>> getRouteList() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .get();

      // Convertir cada documento a una instancia de Route
      Set<Routes> routes = querySnapshot.docs.map((doc) {
        return Routes.fromMap(doc.data());
      }).toSet();

      return routes;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> saveRoute(Routes route) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .add(route.toMap());
      return true;
    } catch (e) {
      print("Error al guardar la ruta: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteRoute(Routes route) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      // Obtener la colección de rutas del usuario
      var collectionRef = db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList");

      // Buscar el documento por algún atributo único de la ruta, por ejemplo, 'name'
      var querySnapshot =
          await collectionRef.where('name', isEqualTo: route.getName).get();

      // Verificar si se encontró el documento
      if (querySnapshot.docs.isEmpty) {
        throw ConnectionBBDDException();
      }

      // Eliminar el primer documento encontrado (asumiendo que el nombre es único)
      await querySnapshot.docs.first.reference.delete();

      return true;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  void addFav(Routes route) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: route.getName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': true});
      }
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  void removeFav(Routes route) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: route.getName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': false});
      }
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<Map<String, dynamic>> getRouteData(Location start, Location end,
      TransportMode transportMode, RouteMode? routeMode) async {
   
    if (routeMode == RouteMode.noSeleccionado ) {
      throw MissingInformationRouteException();
    }
    LatLng initialPoint =
        LatLng(start.getCoordinate().getLat, start.getCoordinate().getLong);
    LatLng destination =
        LatLng(end.getCoordinate().getLat, end.getCoordinate().getLong);

    Map<String, dynamic> pointsData =
        await getPoints(initialPoint, destination, transportMode, routeMode!);

    return pointsData;
  }

  @override
  String getApiPreferenceFromRouteMode(RouteMode mode) {
    switch (mode) {
      case RouteMode.rapida:
        return 'fastest'; // Ruta más rápida
      case RouteMode.corta:
        return 'shortest'; // Ruta más corta
      case RouteMode.economica:
        return 'recommended'; // Ruta recomendada
      default:
        return 'fastest'; // Valor por defecto
    }
  }


  @override
  Future<Map<String, dynamic>> getPoints(
      LatLng initialPoint,
      LatLng destination,
      TransportMode transportMode,
      RouteMode routeMode) async {
    http.Response? response;

    String routeModeString = getApiPreferenceFromRouteMode(routeMode);

    if (transportMode == TransportMode.coche) {
      response = await postCarRoute(initialPoint, destination, routeModeString);
    } else if (transportMode == TransportMode.aPie) {
      response =
          await postWalkRoute(initialPoint, destination, routeModeString);
    } else if (transportMode == TransportMode.bicicleta) {
      response =
          await postBikeRoute(initialPoint, destination, routeModeString);
    }

    if (response?.statusCode == 200) {
      var data = jsonDecode(response!.body);

      // Acceder a las coordenadas en GeoJSON
      final List<dynamic> coordinates =
          data['features'][0]['geometry']['coordinates'];

      // Convertir a List<LatLng>
      List<LatLng> points = coordinates.map((coord) {
        final double lng = coord[0];
        final double lat = coord[1];
        return LatLng(lat, lng);
      }).toList();

      // Acceder a distancia y duración
      double distance = data['features'][0]['properties']['summary']
              ['distance'] /
          1000; // en km
      double duration = data['features'][0]['properties']['summary']
              ['duration'] /
          3600; // en horas

      // Devolver los resultados
      return {
        'points': points,
        'distance': _roundToDecimalPlaces(distance, 2),
        'duration': _roundToDecimalPlaces(duration, 2),
      };
    } else {
      throw APIRoutesException();
    }
  }

  double _roundToDecimalPlaces(double value, int decimalPlaces) {
    double mod = pow(10.0, decimalPlaces).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }



   
}


