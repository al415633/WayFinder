import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/IncorrectCalculationException.dart';
import 'package:WayFinder/exceptions/InvalidCalorieCalculationException.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/PriceProxy.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterRoute.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterRoute.dart';
import 'package:WayFinder/model/route.dart';
import 'package:latlong2/latlong.dart';

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

  double calculateCostKCal(Routes? route) {
    if (route == null) {
      throw InvalidCalorieCalculationException();
    }

    const double walkingKCalPerKMeter = 50.0; //50.0 si es por km
    const double bikingKCalPerKMeter = 30.0; //30.0 si es por km

    if (route.getTransportMode == TransportMode.aPie) {
      route.setCalories = route.distance * walkingKCalPerKMeter;
    } else if (route.getTransportMode == TransportMode.bicicleta) {
      route.setCalories = route.distance * bikingKCalPerKMeter;
    } else {
      throw InvalidCalorieCalculationException();
    }
    return route.getCalories;
  }

  Future<Routes> createRoute(
      String name,
      Location start,
      Location end,
      TransportMode transportMode,
      RouteMode? routeMode,
      Vehicle? vehicle) async {
    if (transportMode == TransportMode.coche &&
        routeMode == RouteMode.economica) {
      Map<String, dynamic> pointsDataShortest = await repository.getRouteData(
          start, end, transportMode, RouteMode.corta);

      List<LatLng> pointsShortest =
          pointsDataShortest['points'] as List<LatLng>;
      //print(points);
      double distanceShortest = pointsDataShortest['distance'] as double;
      //print("Distanciaaaa:$distance");
      double timeShortest = pointsDataShortest['duration'] as double;
      //print("Tiempooooo $time");
      Routes routeShortest = Routes(
          name,
          start,
          end,
          pointsShortest,
          distanceShortest,
          timeShortest,
          transportMode,
          RouteMode.corta,
          vehicle);

      double precioShortest = await calculatePrice(routeShortest, vehicle!);

      Map<String, dynamic> pointsDataFastest = await repository.getRouteData(
          start, end, transportMode, RouteMode.rapida);

      List<LatLng> pointsFastest = pointsDataFastest['points'] as List<LatLng>;
      //print(points);
      double distanceFastest = pointsDataFastest['distance'] as double;
      //print("Distanciaaaa:$distance");
      double timeFastest = pointsDataFastest['duration'] as double;
      //print("Tiempooooo $time");

      Routes routeFastest = Routes(
          name,
          start,
          end,
          pointsFastest,
          distanceFastest,
          timeFastest,
          transportMode,
          RouteMode.rapida,
          vehicle);

      double precioFastest = await calculatePrice(routeFastest, vehicle);

      if (precioFastest < precioShortest) {
        routeFastest.setCost = precioFastest;
        return routeFastest;
      } else {
        routeShortest.setCost = precioShortest;

        return routeShortest;
      }
    }

    Map<String, dynamic> pointsData =
        await repository.getRouteData(start, end, transportMode, routeMode!);

    List<LatLng> points = pointsData['points'] as List<LatLng>;
    //print(points);
    double distance = pointsData['distance'] as double;
    //print("Distanciaaaa:$distance");
    double time = pointsData['duration'] as double;
    //print("Tiempooooo $time");
    Routes route = Routes(name, start, end, points, distance, time,
        transportMode, routeMode, vehicle);
    if (vehicle != null) {
      double cost = await calculatePrice(route, vehicle);
      print("cost $cost");
      route.setCost = cost;
    } else {
      route.setCalories = calculateCostKCal(route);
    }

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
    print(route);
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

  void addFav(Routes route) async {
    try {
      // Llamar al adaptador para marcar como favorita en la base de datos
      repository.addFav(route);

      final currentSet = await routeList;
      route.addFav();
      routeList = Future.value(currentSet);
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  void removeFav(Routes route) async {
    try {
      // Llamar al adaptador para desmarcar como favorita en la base de datos
      repository.removeFav(route);
      final currentSet = await routeList;
      route.removeFav();
      routeList = Future.value(currentSet);
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  Future<double> calculatePrice(Routes? route, Vehicle vehiculo) async {
    if (route == null) {
      throw Incorrectcalculationexception();
    }

    double num = await PriceProxy.getPrice(route);

    return num;
  }

  void onTransportChanged(TransportMode newTransportMode, Routes route) async {
    route.setTransportMode = newTransportMode;
    RouteController routeController =
        RouteController.getInstance(FirestoreAdapterRoute());
    if (newTransportMode == TransportMode.coche) {
      route.setCost = await calculatePrice(route, route.vehicle!);
    } else {
      routeController.calculateCostKCal(route);
      print("OnTransportChanged: ${route.getCost}");
    }
  }

  Future<Routes> editRoute(Routes oldRoute, TransportMode newTransportMode,
      Vehicle? vehicle, RouteMode? newRouteMode) async {

         print("en edit");
    print(newTransportMode);
              //Es en coche pero y economica

    if (vehicle != null && newRouteMode != null) {
      if (newRouteMode == RouteMode.economica) {
        Map<String, dynamic> pointsDataShortest = await repository.getRouteData(
            oldRoute.getStart, oldRoute.getEnd, newTransportMode, RouteMode.corta);

        List<LatLng> pointsShortest =
            pointsDataShortest['points'] as List<LatLng>;
        //print(points);
        double distanceShortest = pointsDataShortest['distance'] as double;
        //print("Distanciaaaa:$distance");
        double timeShortest = pointsDataShortest['duration'] as double;
        //print("Tiempooooo $time");
       
        Routes routeShortest = Routes(
            oldRoute.getName,
            oldRoute.getStart,
            oldRoute.getEnd,
            pointsShortest,
            distanceShortest,
            timeShortest,
            newTransportMode,
            RouteMode.corta,
            vehicle);

        double precioShortest = await calculatePrice(routeShortest, vehicle);

        Map<String, dynamic> pointsDataFastest = await repository.getRouteData(
            oldRoute.getStart, oldRoute.getEnd, newTransportMode, RouteMode.rapida);

        List<LatLng> pointsFastest =
            pointsDataFastest['points'] as List<LatLng>;
        double distanceFastest = pointsDataFastest['distance'] as double;
        double timeFastest = pointsDataFastest['duration'] as double;

        Routes routeFastest = Routes(
            oldRoute.getName,
            oldRoute.getStart,
            oldRoute.getEnd,
            pointsFastest,
            distanceFastest,
            timeFastest,
            newTransportMode,
            RouteMode.rapida,
            vehicle);

        double precioFastest = await calculatePrice(routeFastest, vehicle);

        if (precioFastest < precioShortest) {
          routeFastest.setCost = precioFastest;
          return routeFastest;
        } else {
          routeShortest.setCost = precioShortest;

          return routeShortest;
        }
      }

      //Es en coche pero no economica

      Map<String, dynamic> pointsData =
          await repository.getRouteData(oldRoute.getStart, oldRoute.getEnd, newTransportMode, newRouteMode);

      List<LatLng> points = pointsData['points'] as List<LatLng>;
      //print(points);
      double distance = pointsData['distance'] as double;
      //print("Distanciaaaa:$distance");
      double time = pointsData['duration'] as double;
      //print("Tiempooooo $time");
      Routes route = Routes(oldRoute.getName, oldRoute.getStart, oldRoute.getEnd, points, distance, time,
          newTransportMode, newRouteMode, vehicle);
      double cost = await calculatePrice(route, vehicle);
      route.setCost = cost;
    
      return route;
    }
    else{
      
      Map<String, dynamic> pointsData =
          await repository.getRouteData(oldRoute.getStart, oldRoute.getEnd, newTransportMode, RouteMode.rapida);

      List<LatLng> points = pointsData['points'] as List<LatLng>;
      double distance = pointsData['distance'] as double;
      double time = pointsData['duration'] as double;
      Routes route = Routes(oldRoute.getName, oldRoute.getStart, oldRoute.getEnd, points, distance, time,
          newTransportMode, newRouteMode, vehicle);

      await calculateCostKCal(route);
      return route;


    }
  }
}
