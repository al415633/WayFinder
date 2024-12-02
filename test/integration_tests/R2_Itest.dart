import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R2_Itest.mocks.dart';

@GenerateMocks([FirebaseAuth, DbAdapterUserApp, DbAdapterLocation])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('R2: Gestión de lugares de interés', () {
    
    test('H5-E1V - Crear lugar', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();
      final locationController = LocationController.getInstance(mockDbAdapterLocation);

      final double lath5e1 = 39.98567;
      final double longh5e1 = -0.04935;
      final String aliash5e1 = "prueba 1";    

      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => { await locationController.createLocationFromCoord(lath5e1, longh5e1, aliash5e1),

        },
      );

      // GIVEN
      String emailh5e1 = "Pruebah5e1@gmail.com";
      String passwordh5e1 = "Aaaaa,.8";
      String nameh5e1 = "Pruebah5e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh5e1, passwordh5e1))
          .thenAnswer((_) async => UserApp("id", nameh5e1, emailh5e1));

      await userAppController.createUser(emailh5e1, passwordh5e1, nameh5e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterLocation.createLocationFromCoord(any))
          .thenAnswer((_) async => true);

      await locationController.createLocationFromCoord(lath5e1, longh5e1, aliash5e1);

      // THEN
      final Set<Location> location = await locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocationh5e1.getCoordinate().getLat, equals(lath5e1)); // Verifica la latitud
      expect(firstLocationh5e1.getCoordinate().getLong, equals(longh5e1)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(), equals("")); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias
    });
 


  test('H5-E3I - Coordenadas del Lugar incorrectas', () async {
    // Configurar los mocks y el controlador dentro del test
    final mockAuth = MockFirebaseAuth();
    final mockDbAdapterUserApp = MockDbAdapterUserApp();
    final userAppController = UserAppController(mockDbAdapterUserApp);
    final mockDbAdapterLocation = MockDbAdapterLocation();
    final locationController = LocationController.getInstance(mockDbAdapterLocation);
    final double lath5e3 = 39.98567;
    final double longh5e3 = -0.04935;
    final String aliash5e3 = "prueba 1";

    // Configurar el stub de `getLocationList`
    when(mockDbAdapterLocation.getLocationList()).thenAnswer(
      (_) async => { await locationController.createLocationFromCoord(lath5e3, longh5e3, aliash5e3),
      },
    );

    // GIVEN
    String emailh5e3 = "Pruebah5e3@gmail.com";
    String passwordh5e3 = "Aaaaa,.8";
    String nameh5e3 = "Pruebah5e3";

    // Simular la creación del usuario
    when(userAppController.repository.createUser(emailh5e3, passwordh5e3))
        .thenAnswer((_) async => UserApp("id", nameh5e3, emailh5e3));

    await userAppController.createUser(emailh5e3, passwordh5e3, nameh5e3);

    // Simular la creación de un lugar que arroja una excepción
    when(mockDbAdapterLocation.createLocationFromCoord(any)).thenThrow(Exception("Coordenadas inválidas"));

    // WHEN
    final result = await locationController.createLocationFromCoord(lath5e3, longh5e3, aliash5e3);

    // THEN
    expect(result, isFalse); // Verificar que devuelve false en caso de error
  });


  test('H7-E1V - Listar lugares', () async {
    // Configurar los mocks y el controlador dentro del test
    final mockAuth = MockFirebaseAuth();
    final mockDbAdapterUserApp = MockDbAdapterUserApp();
    final userAppController = UserAppController(mockDbAdapterUserApp);
    final mockDbAdapterLocation = MockDbAdapterLocation();
    final locationController = LocationController.getInstance(mockDbAdapterLocation);

    // Simular los datos de los lugares
    final double lat1 = 39.98567;
    final double long1 = -0.04935;
    final String alias1h7e1 = "Castellon";

    final double lat2 = 40.12345;
    final double long2 = -1.12345;
    final String alias2 = "mi casa";

    // Configurar el stub de `getLocationList`
    when(mockDbAdapterLocation.getLocationList()).thenAnswer(
      (_) async => { await locationController.createLocationFromCoord(lat1, long1, alias1h7e1),
      await locationController.createLocationFromCoord(lat2, long2, alias2)
      },
    );

    // Simular la creación del usuario
    String emailh7e1 = "Pruebah7e1@gmail.com";
    String passwordh7e1 = "Aaaaa,.8";
    String nameh7e1 = "Pruebah7e1";

    when(userAppController.repository.createUser(emailh7e1, passwordh7e1))
        .thenAnswer((_) async => UserApp("id", nameh7e1, emailh7e1));

    await userAppController.createUser(emailh7e1, passwordh7e1, nameh7e1);

    // Simular la creación de lugares en el adaptador
    when(mockDbAdapterLocation.createLocationFromCoord(any)).thenAnswer((_) async => true);

    await locationController.createLocationFromCoord(lat1, long1, alias1h7e1);
    await locationController.createLocationFromCoord(lat2, long2, alias2);

    // WHEN
    final Set<Location> locations = await locationController.getLocationList();

    // THEN
    final locationList = locations.toList();

    // Verificar que los valores del primer lugar son los esperados
    final firstLocation = locationList[0];
    expect(firstLocation.getCoordinate().getLat, equals(lat1)); // Verifica la latitud
    expect(firstLocation.getCoordinate().getLong, equals(long1)); // Verifica la longitud
    expect(firstLocation.getAlias(), equals(alias1h7e1)); // Verifica el alias

    // Verificar que los valores del segundo lugar son los esperados
    final secondLocation = locationList[1];
    expect(secondLocation.getCoordinate().getLat, equals(lat2)); // Verifica la latitud
    expect(secondLocation.getCoordinate().getLong, equals(long2)); // Verifica la longitud
    expect(secondLocation.getAlias(), equals(alias2)); // Verifica el alias
  });


  test('H7-E3I - Listar lugares inválida porque no hay usuario autenticado', () async {
    // Configurar los mocks y el controlador dentro del test
    final mockAuth = MockFirebaseAuth();
    final mockDbAdapterLocation = MockDbAdapterLocation();
    //final locationController = LocationController.getInstance(mockDbAdapterLocation);

    // Simular que no hay usuario autenticado
    when(mockDbAdapterLocation.getLocationList()).thenThrow(
      Exception("Usuario no autenticado"),
    );


    // WHEN
    Future<void> action() async {
      //await locationController.getLocationList();
      LocationController(mockDbAdapterLocation);
    }

    // THEN
    expect(action(), throwsA(isA<Exception>()));
  });


 });

}


