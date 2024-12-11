import 'package:WayFinder/exceptions/InvalidCalorieCalculationException.dart';
import 'package:WayFinder/exceptions/MissingInformationRouteException.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'dart:convert';
import 'package:WayFinder/APIs/apiConection.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:WayFinder/model/route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';



class RouteController {
  // Propiedades
  late Future<Set<Routes>> routeList;

  // Propiedad privada
  final DbAdapterRoute repository;

  // Constructor privado
  RouteController(this.repository) {
    routeList = repository.getRouteList();
  }

  // Instancia única
  static RouteController? _instance;

  static RouteController getInstance(DbAdapterRoute repository) {
    _instance ??= RouteController(repository);
    return _instance!;
  }

  Future<Set<Routes>> getRouteList() async {
    return routeList;
  }

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


  double calculateCostKCal(Routes? route) {
    if (route == null || route.transportMode == TransportMode.coche) {
      throw Invalidcaloriecalculationexception();
    }

    const double walkingKCalPerKMeter = 50.0; //50.0 si es por km
    const double bikingKCalPerKMeter = 30.0; //30.0 si es por km

    switch (route.transportMode) {
      case TransportMode.aPie:
        return route.distance * walkingKCalPerKMeter;
      case TransportMode.bicicleta:
        return route.distance * bikingKCalPerKMeter;
      default:
        throw Invalidcaloriecalculationexception();
    }
  }


  double _roundToDecimalPlaces(double value, int decimalPlaces) {
    double mod = pow(10.0, decimalPlaces).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }



  Future<Map<String, dynamic>> getPoints(LatLng initialPoint,
      LatLng destination, TransportMode transportMode, RouteMode routeMode) async {
    http.Response? response;

    String routeModeString = getApiPreferenceFromRouteMode(routeMode);

    if (transportMode == TransportMode.coche) {
      response = await postCarRoute(initialPoint, destination, routeModeString);
    } else if (transportMode == TransportMode.aPie) {
      response = await postWalkRoute(initialPoint, destination, routeModeString);
    } else if (transportMode == TransportMode.bicicleta) {
      response = await postBikeRoute(initialPoint, destination, routeModeString);
    }

    if (response?.statusCode == 200) {
      var data = jsonDecode(response!.body);

      // Acceder a las coordenadas en GeoJSON
      final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

      // Convertir a List<LatLng>
      List<LatLng> points = coordinates.map((coord) {
        final double lng = coord[0];
        final double lat = coord[1];
        return LatLng(lat, lng);
      }).toList();

      // Acceder a distancia y duración
      double distance = data['features'][0]['properties']['summary']['distance'] / 1000; // en km
      double duration = data['features'][0]['properties']['summary']['duration'] / 3600; // en horas

      // Devolver los resultados
      return {
        'points': points,
        'distance': _roundToDecimalPlaces(distance, 2),
        'duration': _roundToDecimalPlaces(duration, 2),
      };
    } else {
      print('Error al obtener la ruta: ${response?.statusCode}, ${response?.body}');
      throw Exception('Error al obtener la ruta.');
    }
  }



  Future<Routes> createRoute(
      String name,
      Location start,
      Location end,
      TransportMode transportMode,
      RouteMode? routeMode,
      Vehicle? vehicle) async {

    if (routeMode == null) {
  throw MissingInformationRouteException("El modo de ruta no puede ser nulo.");
    }

    LatLng initialPoint =
        LatLng(start.getCoordinate().getLat, start.getCoordinate().getLong);
    LatLng destination =
        LatLng(end.getCoordinate().getLat, end.getCoordinate().getLong);

    Map<String, dynamic> pointsData =
          await getPoints(initialPoint, destination, transportMode, routeMode);

    List<LatLng> points = pointsData['points'] as List<LatLng>;
    //print(points);
    double distance = pointsData['distance'] as double;
    //print("Distanciaaaa:$distance");
    double time = pointsData['duration'] as double;
    //print("Tiempooooo $time");
    Routes route = Routes(name, start, end, points, distance, time,
        transportMode, routeMode, vehicle);
    return route;
  }

  Future<bool> deleteRoute(Routes route) async {
    try {
      bool success = await repository.deleteRoute(route);

      if (success) {
        final currentSet = await routeList;
        // Agregar el nuevo Location al Set
        currentSet.remove(route);
        routeList = Future.value(currentSet);
      }

      return success;
    } catch (e) {
      throw Exception("Error al crear la ruta: $e");
    }
  }

  Future<bool> saveRoute(Routes route) async {
    try {
      bool success = await repository.saveRoute(route);

      if (success) {
        final currentSet = await routeList;

        // Agregar el nuevo Location al Set
        currentSet.add(route);
        routeList = Future.value(currentSet);
      }

      return success;
    } catch (e) {
      throw Exception("Error al crear la ruta: $e");
    }
  }


  Future<bool> addFav(String routeName) async {
    try {
      // Llamar al adaptador para marcar como favorita en la base de datos
      bool success = await repository.addFav(routeName);

      if (success) {
        // Si se actualiza con éxito, reflejar en la lista local
        final currentSet = await routeList;
        for (var route in currentSet) {
          if (route.name == routeName) {
            route.fav = true; // Actualizar la propiedad `fav` en la lista local
            break;
          }
        }
      }

      return success;
    } catch (e) {
      throw Exception(
          "Error al añadir el location a favoritos en el controlador: $e");
    }
  }

  Future<bool> removeFav(String routeName) async {
    try {
      // Llamar al adaptador para desmarcar como favorita en la base de datos
      bool success = await repository.removeFav(routeName);

      if (success) {
        // Si se actualiza con éxito, reflejar en la lista local
        final currentSet = await routeList;
        for (var route in currentSet) {
          if (route.getName == routeName) {
            route.fav =
                false; // Actualizar la propiedad `fav` en la lista local
            break;
          }
        }
      }

      return success;
    } catch (e) {
      throw Exception(
          "Error al eliminar el location a favoritos en el controlador: $e");
    }
  }
}

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
    /*
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado. No se puede crear la ruta.');
    }

    */

    try {
      final querySnapshot = await db
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
      throw Exception("Error al obtener la lista de rutas: $e");
    }
  }

  @override
  Future<bool> saveRoute(Routes route) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado. No se puede crear el location.');
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado. No se puede eliminar la ruta.');
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
        throw Exception('Ruta no encontrada.');
      }

      // Eliminar el primer documento encontrado (asumiendo que el nombre es único)
      await querySnapshot.docs.first.reference.delete();

      return true;
    } catch (e) {
      throw Exception("Error al eliminar la ruta: $e");
    }
  }

  @override
  Future<bool> addFav(String routeName) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: routeName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': true});
      }

      return true;
    } catch (e) {
      print("Error al añadir la ruta a favoritos en la base de datos: $e");
      return false;
    }
  }

  @override
  Future<bool> removeFav(String routeName) async {
    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("RouteList")
          .where('name', isEqualTo: routeName)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'fav': false});
      }

      return true;
    } catch (e) {
      print("Error al eliminar la ruta de favoritos en la base de datos: $e");
      return false;
    }
  }
}

abstract class DbAdapterRoute {
  Future<bool> saveRoute(Routes route);
  Future<bool> deleteRoute(Routes route);
  Future<Set<Routes>> getRouteList();
  Future<bool> removeFav(String routeName);
  Future<bool> addFav(String routeName);
}
