import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R4_Itest.mocks.dart';


@GenerateMocks([FirebaseAuth, DbAdapterUserApp, DbAdapterRoute])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('R4: Gestión de Routes', () {

    test('H13-E1V - Crear ruta', () async {
      // Datos de prueba
      final String routeName = "ruta 1";
      final Location ini = Location(39.98567, -0.04935, "castellon");
      final Location fin = Location(39.8890, -0.08499, "burriana");

      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterRoute = MockDbAdapterRoute();

      // Configurar el stub de `getRouteList`
      when(mockDbAdapterRoute.getRouteList()).thenAnswer((_) async => <Routes>{});

      // Configurar el stub de `createRoute` para lanzar una excepción si es llamado
      when(mockDbAdapterRoute.createRoute(
        any,
        any,
        any,
        any,
        any,
      )) .thenAnswer((_) async => Routes(routeName, ini, fin, 0, [], TransportMode.aPie, "rápido"));

      // Crear el controlador después de configurar los stubs
      final routeController = RouteController(mockDbAdapterRoute);

      String emailh13e1 = "Pruebah13e1@gmail.com";
      String passwordh13e1 = "Aaaaa,.8";
      String nameh13e1 = "Pruebah13e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh13e1, passwordh13e1))
          .thenAnswer((_) async => UserApp("id", nameh13e1, emailh13e1));

      UserApp? newUserApp = await userAppController.createUser(emailh13e1, passwordh13e1, nameh13e1);


      // WHEN: Crear la ruta
      final Routes createdRoute = await routeController.createRoute(
        routeName,
        ini,
        fin,
        TransportMode.aPie,
        "rápida",
      );

      expect(createdRoute.getStart(), equals(ini)); // Verifica el Location inicial
      expect(createdRoute.getEnd(), equals(fin)); // Verifica el Location final
    
    });





  });

}