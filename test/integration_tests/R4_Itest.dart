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
    test('H13-E2V - Eliminar ruta', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();
      final mockRouteController = RouteController(mockDbAdapterRoute);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final mockDblocationController = LocationController(mockDbAdapterLocation);

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      //final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      //final double lat2 = 39.8890;
      //final double long2 = -0.08499;
      final String apodo2 = "burriana";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      Location ini = await mockDblocationController.createLocationFromCoord(lat1, long1, apodo1);
      Location fin = await mockDblocationController.createLocationFromTopo(topo2, apodo2);

      String name1 = "ruta 1";

            Routes ruta = await mockRouteController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.corta);

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer(
        (_) async => {ruta},
      );

      // Guardar la ruta
      await mockRouteController.saveRoute(ruta);

      // Verificar que la ruta se ha guardado
      var routeList = await mockRouteController.getRouteList();
      expect(routeList.contains(ruta), isTrue);

      // Eliminar la ruta
      await mockRouteController.deleteRoute(ruta);

      // Verificar que la ruta se ha eliminado
      routeList = await mockRouteController.getRouteList();
      expect(routeList.contains(ruta), isFalse);
    });

  });
}
