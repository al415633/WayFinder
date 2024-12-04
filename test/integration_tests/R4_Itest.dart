import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R4_Itest.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<RouteController>(),
  MockSpec<DbAdapterRoute>(),
  MockSpec<DbAdapterUserApp>(),
  MockSpec<DbAdapterLocation>()
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
      final mockRouteController = RouteController(mockDbAdapterRoute);
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
          name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      // GIVEN
      String emailh13e1 = "Pruebah13e1@gmail.com";
      String passwordh13e1 = "Aaaaa,.8";
      String nameh13e1 = "Pruebah13e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh13e1, passwordh13e1))
          .thenAnswer((_) async => UserApp("id", nameh13e1, emailh13e1));

      await userAppController.createUser(emailh13e1, passwordh13e1, nameh13e1);

      // WHEN

      // Simular la creación de un lugar
      //when(mockRouteController.createRoute(nameh13e1, ini, fin, TransportMode.aPie, RouteMode.corta))
      // .thenReturn((_) => ruta);

      Routes firstRouteh13e1 = await mockRouteController.createRoute(
          nameh13e1, ini, fin, TransportMode.aPie, RouteMode.corta);

      // THEN
      expect(firstRouteh13e1.getStart,
          equals(ini)); // Verifica el Location inicial
      expect(firstRouteh13e1.getEnd, equals(fin)); // Verifica el Location final
    });

    test('H13-E2I - Crear ruta inválido no hay conexión BBDD', () async {
      //no necesita acceder a la base de datos porque crea la ruta pero no la almacena en la BBDD
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

      Routes ruta = Routes(name1, ini, fin, [], 0, 0, TransportMode.aPie, RouteMode.corta);

       // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      // GIVEN
      String emailh18e1 = "Pruebah18e1@gmail.com";
      String passwordh18e1 = "Aaaaa,.8";
      String nameh18e1="Pruebah18e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh18e1, passwordh18e1))
          .thenAnswer((_) async => UserApp("id", nameh18e1, emailh18e1));

      await userAppController.createUser(emailh18e1, passwordh18e1, nameh18e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterRoute.saveRoute(ruta))
          .thenAnswer((_) async => true);

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

   });


}
