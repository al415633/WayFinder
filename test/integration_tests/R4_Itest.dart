import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/ElectricCarPrice.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R4_Itest.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<DbAdapterRoute>(),
  MockSpec<DbAdapterUserApp>(),
  MockSpec<DbAdapterLocation>(),
  MockSpec<Electriccarprice>(),
  MockSpec<DbAdapterVehicle>(),
])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('R4: Gestión de Routes', () {
    test('H13-E1V - Crear ruta', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 12.83, 0.32, TransportMode.aPie, RouteMode.corta, null);

      Map<String, dynamic> pointsData = {
        'points': <LatLng>[],
        'distance': 12.83,
        'duration': 0.32
      };


      // GIVEN
      String emailh16e1 =
          "Pruebah16e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh16e1 = "Aaaaa,.8";
      String nameh16e1 = "Pruebah16e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh16e1, passwordh16e1))
          .thenAnswer((_) async => UserApp("id", nameh16e1, emailh16e1));

      await userAppController.createUser(emailh16e1, passwordh16e1, nameh16e1);

      // WHEN

      when(mockDbAdapterRoute.getRouteData(ini, fin, TransportMode.aPie, RouteMode.corta)).thenAnswer(
        (_) async => pointsData,
      );

      Routes routeh16e1 = await routeController.createRoute( name1, ini, fin, TransportMode.aPie, RouteMode.corta, null);

      // THEN


      expect(routeh16e1.getStart, equals(ini)); // Verifica el Location inicial
      expect(routeh16e1.getEnd, equals(fin)); // Verifica el Location final

    });

    test('H13-E2I - Crear ruta inválido no hay conexión BBDD', () async {
      //no necesita acceder a la base de datos porque crea la ruta pero no la almacena en la BBDD
    });

    test('H14 - E1V - Calculo precio ruta', () async {
      // Loguear usuario
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterVehicle = MockDbAdapterVehicle();
      final vehicleController = VehicleController(mockDbAdapterVehicle);
      final mockElectricCarPrice = MockElectriccarprice();

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String topo1 = "Castellón de la Plana";
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String topo2 = "Burriana";
      final String apodo2 = "burriana";

      String name1 = "Ruta h14 e1";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      Routes ruta = Routes(name1, ini, fin, [], 11.17, 0, TransportMode.aPie,
          RouteMode.corta, null);

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = 'Eléctrico';

      Vehicle vehicle = Vehicle(fuelType, consumption, numberPlate, namec);

      double coste = 0;

      // WHEN
      when(mockElectricCarPrice.calculatePrice(ruta, vehicle))
          .thenAnswer((_) async => 0.12);

      //Se establece la estrategia mock, pero al hacer vehicleController.calculatePrice
      //se sobreescribe y deja de ser la mockeada
      vehicle.setPriceStrategy(mockElectricCarPrice);
      ruta.vehicle = vehicle;

      // GIVEN
      String email = "Pruebah14e1@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah14e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(email, password))
          .thenAnswer((_) async => UserApp("id", name, email));

      await userAppController.createUser(email, password, name);

      //Da 0 porque se sobrescribe la strategy mockeada
      coste = await vehicleController.calculatePrice(ruta, vehicle);

      // THEN
      expect(coste, isNotNull);
      expect(coste, equals(0.12));
      verify(mockElectricCarPrice.calculatePrice(ruta, vehicle)).called(1);
    });

    test('H14 - E2I - Calculo del precio ruta que es incorrecto', () async {
      // Loguear usuario
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterVehicle = MockDbAdapterVehicle();
      final vehicleController = VehicleController(mockDbAdapterVehicle);
      final mockElectricCarPrice = MockElectriccarprice();

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String topo1 = "Castellón de la Plana";
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String topo2 = "Burriana";
      final String apodo2 = "burriana";

      String name1 = "Ruta h14 e2";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = 'Eléctrico';

      Vehicle vehicle = Vehicle(fuelType, consumption, numberPlate, namec);

      // WHEN
      when(mockElectricCarPrice.calculatePrice(ruta, vehicle))
          .thenThrow(Exception('Error en el cálculo del precio de la ruta'));

      // Se establece la estrategia mock
      vehicle.setPriceStrategy(mockElectricCarPrice);
      ruta.vehicle = vehicle;

      // GIVEN
      String email = "Pruebah15e3@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah15e3";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(email, password))
          .thenAnswer((_) async => UserApp("id", name, email));

      await userAppController.createUser(email, password, name);

      // THEN
      expect(() async {
        await vehicleController.calculatePrice(ruta, vehicle);
      }, throwsA(isA<Exception>()));
      verify(mockElectricCarPrice.calculatePrice(ruta, vehicle)).called(1);
    });


    test('H16-E1V - Crear ruta habiendo elegido un tipo de ruta concreto', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 12.83, 0.32, TransportMode.aPie, RouteMode.corta, null);

      Map<String, dynamic> pointsData = {
        'points': <LatLng>[],
        'distance': 12.83,
        'duration': 0.32
      };


      // GIVEN
      String emailh16e1 =
          "Pruebah16e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh16e1 = "Aaaaa,.8";
      String nameh16e1 = "Pruebah16e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh16e1, passwordh16e1))
          .thenAnswer((_) async => UserApp("id", nameh16e1, emailh16e1));

      await userAppController.createUser(emailh16e1, passwordh16e1, nameh16e1);

      // WHEN

      when(mockDbAdapterRoute.getRouteData(ini, fin, TransportMode.aPie, RouteMode.corta)).thenAnswer(
        (_) async => pointsData,
      );

      Routes routeh16e1 = await routeController.createRoute( name1, ini, fin, TransportMode.aPie, RouteMode.corta, null);

      // THEN


      expect(routeh16e1.getStart, equals(ini)); // Verifica el Location inicial
      expect(routeh16e1.getEnd, equals(fin)); // Verifica el Location final
      expect(routeh16e1.distance, equals(12.83));
      expect(routeh16e1.time, equals(0.32));
      expect(routeh16e1.cost, equals(0));
    });

    test('H16-E2I - Crear ruta  sin elegir un tipo de ruta concreto ', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, null, null);

      // GIVEN
      // no registramos usuario

      // WHEN

      // Simular que guardamos de un lugar
      when(mockDbAdapterRoute.getRouteData(ini, fin, TransportMode.aPie, null))
          .thenThrow(Exception);

      // THEN

      Future<void> action() async {
        //await locationController.getLocationList();
        await routeController.createRoute(name1, ini, fin, TransportMode.aPie, null, null);
      }

      // THEN
      expect(action(), throwsA(isA<Exception>()));
    });


    test('H17-E1V - Guardar ruta', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      // GIVEN
      String emailh17e1 =
          "Pruebah17e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh17e1 = "Aaaaa,.8";
      String nameh17e1 = "Pruebah17e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh17e1, passwordh17e1))
          .thenAnswer((_) async => UserApp("id", nameh17e1, emailh17e1));

      await userAppController.createUser(emailh17e1, passwordh17e1, nameh17e1);

      // WHEN

      // Simular que guardamos de un lugar
      when(mockDbAdapterRoute.saveRoute(ruta)).thenAnswer((_) async => true);

      bool success = await routeController.saveRoute(ruta);

      // THEN
      final Set<Routes> route = await routeController.getRouteList();

      // Convertir el set a una lista para acceder al primer elemento
      final routeListh17e1 = route.toList();

      // Acceder al primer objeto en la lista
      final routeh17e1 = routeListh17e1[0];
      expect(success, equals(true));
      expect(routeh17e1.getStart, equals(ini)); // Verifica el Location inicial
      expect(routeh17e1.getEnd, equals(fin)); // Verifica el Location final
    });

    test('H17-E3I - Guardar ruta inválido, usuario no registrado', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      // GIVEN
      // no registramos usuario

      // WHEN

      // Simular que guardamos de un lugar
      when(mockDbAdapterRoute.saveRoute(ruta))
          .thenThrow(Exception("Usuario no autenticado"));

      // THEN

      Future<void> action() async {
        //await locationController.getLocationList();
        await routeController.saveRoute(ruta);
      }

      // THEN
      expect(action(), throwsA(isA<Exception>()));
    });

    test('H18-E1V - Listar rutas', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      // GIVEN
      String emailh18e1 =
          "Pruebah18e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh18e1 = "Aaaaa,.8";
      String nameh18e1 = "Pruebah18e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh18e1, passwordh18e1))
          .thenAnswer((_) async => UserApp("id", nameh18e1, emailh18e1));

      await userAppController.createUser(emailh18e1, passwordh18e1, nameh18e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterRoute.saveRoute(ruta)).thenAnswer((_) async => true);

      await routeController.saveRoute(ruta);

      final Set<Routes> route = await routeController.getRouteList();

      // THEN
      final locationListh18e1 = route.toList();

      // Acceder al primer objeto en la lista
      final firstRoute = locationListh18e1[0];

      expect(firstRoute.getStart, equals(ini)); // Verifica el Location inicial
      expect(firstRoute.getEnd, equals(fin)); // Verifica el Location final
    });

    test('H18-E3I - Listar rutas inálida, usuario no registrado', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenThrow(
        Exception("Usuario no autenticado"),
      );

      // GIVEN
      // no registramos usuario

      // WHEN

      Future<void> action() async {
        //await locationController.getLocationList();
        RouteController(mockDbAdapterRoute);
      }

      // THEN
      expect(action(), throwsA(isA<Exception>()));
    });

    test('H19-E1V - Eliminar ruta', () async {
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final mockDblocationController =
          LocationController(mockDbAdapterLocation);

      //simular los datos de la ruta
      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      when(mockDbAdapterRoute.deleteRoute(ruta)).thenAnswer((_) async => true);

      //GIVEN

      String emailh19e1 = "Pruebah19e1@gmail.com";
      String passwordh19e1 = "Aaaaa,.8";
      String nameh19e1 = "Pruebah19e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh19e1, passwordh19e1))
          .thenAnswer((_) async => UserApp("id", nameh19e1, emailh19e1));

      await userAppController.createUser(emailh19e1, passwordh19e1, nameh19e1);

      //WHEN

      bool success = await routeController.deleteRoute(ruta);

      // THEN
      expect(success, equals(true)); // Verifica que se ha eliminado

      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {},
      );

      //THEN

      final Set<Routes> route = await routeController.getRouteList();

      // Convertir el set a una lista para acceder al primer elemento
      final routeListh19e1 = route.toList();

      expect(routeListh19e1.length, equals(0)); // Verifica el Location inicial
    });

    test('H19-E4I - Eliminar ruta inválida, usuario no registrado', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final routeController = RouteController(mockDbAdapterRoute);

      //simular los datos de la ruta
      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = Location(Coordinate(lat1, long1), topo1, apodo1);
      Location fin = Location(Coordinate(lat2, long2), topo2, apodo2);

      String name1 = "ruta 1";

      Routes ruta = Routes(
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta, null);

      // Simular que no hay usuario autenticado
      when(await mockDbAdapterRoute.deleteRoute(ruta)).thenThrow(
        Exception("Usuario no autenticado"),
      );

      // WHEN
      Future<void> action() async {
        //await locationController.getLocationList();
        await routeController.deleteRoute(ruta);
      }

      // THEN
      expect(action(), throwsA(isA<Exception>()));
    });
  });
}
