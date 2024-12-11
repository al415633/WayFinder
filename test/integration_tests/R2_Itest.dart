
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R2_Itest.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseAuth>(),
MockSpec<DbAdapterLocation>(), MockSpec<DbAdapterUserApp>()])
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
      final String topoh5e1 = "Caja Rural, Castellón de la Plana, VC, España";  

      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {
          Location(Coordinate(lath5e1, longh5e1), topoh5e1, aliash5e1)},
      );

      // GIVEN
      String emailh5e1 = "Pruebah5e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
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
      expect((firstLocationh5e1.getCoordinate().getLat - lath5e1).abs() < 0.001, equals(true)); // Verifica la latitud
      expect((firstLocationh5e1.getCoordinate().getLong - longh5e1).abs() < 0.001 , equals(true)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(), equals(topoh5e1)); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias
    });
 


  test('H5-E3I - Coordenadas del Lugar incorrectas', () async {
    // Configurar los mocks y el controlador dentro del test
    final mockAuth = MockFirebaseAuth();
    final mockDbAdapterUserApp = MockDbAdapterUserApp();
    final userAppController = UserAppController(mockDbAdapterUserApp);
    final mockDbAdapterLocation = MockDbAdapterLocation();
    final locationController = LocationController.getInstance(mockDbAdapterLocation);
    final double lath5e3 = 91;
    final double longh5e3 = 181;
    final String aliash5e3 = "prueba 1";
    final String topoh5e3 = "Caja Rural, Castellón de la Plana, VC, España";  


    // Configurar el stub de `getLocationList`
    when(mockDbAdapterLocation.getLocationList()).thenAnswer(
      (_) async => {},
    );

    // GIVEN
    String emailh5e3 = "Pruebah5e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
    String passwordh5e3 = "Aaaaa,.8";
    String nameh5e3 = "Pruebah5e3";

    // Simular la creación del usuario
    when(userAppController.repository.createUser(emailh5e3, passwordh5e3))
        .thenAnswer((_) async => UserApp("id", nameh5e3, emailh5e3));

    await userAppController.createUser(emailh5e3, passwordh5e3, nameh5e3);

    // Simular la creación de un lugar que arroja una excepción
    when(mockDbAdapterLocation.createLocationFromCoord(any)).thenThrow(Exception("Coordenadas inválidas"));

    // WHEN

    // THEN
    //expect(await locationController.createLocationFromCoord(lath5e3, longh5e3, aliash5e3), throwsA(isA<Exception>)); // Verificar que devuelve false en caso de error


    Future<void> action() async {
      //await locationController.getLocationList();
      await locationController.createLocationFromCoord(lath5e3, longh5e3, aliash5e3);
    }

    // THEN
    expect(() async => await action(), throwsA(isA<Exception>()));
  });


  test('H6-E1V - Crear lugar', () async {
     // Configurar los mocks y el controlador dentro del test
     final mockAuth = MockFirebaseAuth();
     final mockDbAdapterUserApp = MockDbAdapterUserApp();
     final userAppController = UserAppController(mockDbAdapterUserApp);
     final mockDbAdapterLocation = MockDbAdapterLocation();
     final locationController = LocationController.getInstance(mockDbAdapterLocation);


     final double lath6e1 = 39.98567;
     final double longh6e1 = -0.04935;
     final String aliash6e1 = "prueba 1";
     final String topoh6e1 = "Caja Rural, Castellón de la Plana, VC, España";


     // Configurar el stub de `getLocationList`
     when(mockDbAdapterLocation.getLocationList()).thenAnswer(
           (_) async => {
             Location(Coordinate(lath6e1, longh6e1), topoh6e1, aliash6e1)
           },
     );


     // GIVEN
     String emailh6e1 = "Pruebah6e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
     String passwordh6e1 = "Aaaaa,.8";
     String nameh6e1 = "Pruebah6e1";


     // Simular la creación del usuario
     when(userAppController.repository.createUser(emailh6e1, passwordh6e1))
         .thenAnswer((_) async => UserApp("id", nameh6e1, emailh6e1));


     await userAppController.createUser(emailh6e1, passwordh6e1, nameh6e1);


     // WHEN


     // Simular la creación de un lugar
     when(mockDbAdapterLocation.createLocationFromTopo(any))
         .thenAnswer((_) async => true);


     await locationController.createLocationFromTopo(topoh6e1, aliash6e1);


     // THEN
     final Set<Location> location = await locationController.getLocationList();


     // Convertir el set a una lista para acceder al primer elemento
     final locationListh5e1 = location.toList();


     // Acceder al primer objeto en la lista
     final firstLocationh5e1 = locationListh5e1[0];


     // Verificar que los valores del primer lugar son los esperados
     expect((firstLocationh5e1.getCoordinate().getLat - lath6e1).abs() < 0.001, equals(true)); // Verifica la latitud
     expect((firstLocationh5e1.getCoordinate().getLong - longh6e1).abs() < 0.001, equals(true)); // Verifica la longitud
     expect(firstLocationh5e1.getToponym(), equals(topoh6e1)); // Verifica el topónimo
     expect(firstLocationh5e1.getAlias(), equals(aliash6e1)); // Verifica el alias
   });




 test('H6-E3I - Toponimo del Lugar incorrecto', () async {
   // Configurar los mocks y el controlador dentro del test
   final mockAuth = MockFirebaseAuth();
   final mockDbAdapterUserApp = MockDbAdapterUserApp();
   final userAppController = UserAppController(mockDbAdapterUserApp);
   final mockDbAdapterLocation = MockDbAdapterLocation();
   final locationController = LocationController.getInstance(mockDbAdapterLocation);
   final double lath6e3 = 39.98567;
   final double longh6e3 = -0.04935;
   final String aliash6e3 = "prueba 1";
   final String topoh6e3 = "aoneutcg go5gog";

   // Configurar el stub de `getLocationList`
   when(mockDbAdapterLocation.getLocationList()).thenAnswer(
     (_) async => {},
   );


   // GIVEN
   String emailh6e3 = "Pruebah6e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
   String passwordh6e3 = "Aaaaa,.8";
   String nameh6e3 = "Pruebah6e3";


   // Simular la creación del usuario
   when(userAppController.repository.createUser(emailh6e3, passwordh6e3))
       .thenAnswer((_) async => UserApp("id", nameh6e3, emailh6e3));


   await userAppController.createUser(emailh6e3, passwordh6e3, nameh6e3);


   // Simular la creación de un lugar que arroja una excepción
   when(mockDbAdapterLocation.createLocationFromTopo(any)).thenThrow(Exception("Toponimo inválido"));


   // WHEN

   Future<void> action() async {
     //await locationController.getLocationList();
     await locationController.createLocationFromTopo(topoh6e3, aliash6e3);
   }

   // THEN
   expect(() async => await action(), throwsA(isA<Exception>()));
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
    final String alias1h7e1 = "prueba 1";
    final String topoh7e1 = "Caja Rural, Castellón de la Plana, VC, España";


    // Configurar el stub de `getLocationList`
    when(mockDbAdapterLocation.getLocationList()).thenAnswer(
      (_) async => { Location(Coordinate(lat1, long1), alias1h7e1, topoh7e1),
      },
    );

    // Simular la creación del usuario
    String emailh7e1 = "Pruebah7e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
    String passwordh7e1 = "Aaaaa,.8";
    String nameh7e1 = "Pruebah7e1";

    when(userAppController.repository.createUser(emailh7e1, passwordh7e1))
        .thenAnswer((_) async => UserApp("id", nameh7e1, emailh7e1));

    await userAppController.createUser(emailh7e1, passwordh7e1, nameh7e1);

    // Simular la creación de lugares en el adaptador
    when(mockDbAdapterLocation.createLocationFromCoord(any)).thenAnswer((_) async => true);

    await locationController.createLocationFromCoord(lat1, long1, alias1h7e1);

    // WHEN
    final Set<Location> locations = await locationController.getLocationList();

    // THEN
    final locationList = locations.toList();

    // Verificar que los valores del primer lugar son los esperados
    final firstLocation = locationList[0];
    expect((firstLocation.getCoordinate().getLat -lat1).abs() < 0.001, equals(true)); // Verifica la latitud
    expect((firstLocation.getCoordinate().getLong - long1).abs() < 0.001, equals(true)); // Verifica la longitud      
    expect(firstLocation.getToponym(), equals(topoh7e1)); // Verifica el toponimo
    expect(firstLocation.getAlias(), equals(alias1h7e1)); // Verifica el alias


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

  test('H8-E1V - Eliminar lugar de interés', () async {
    // GIVEN
    // Configurar los mocks y el controlador dentro del test
     final mockDbAdapterUserApp = MockDbAdapterUserApp();
     final userAppController = UserAppController(mockDbAdapterUserApp);
     final mockDbAdapterLocation = MockDbAdapterLocation();
     final locationController = LocationController.getInstance(mockDbAdapterLocation);


     
     // WHEN
     final double lath8e1 = 39.98567;
     final double longh8e1 = -0.04935;
     final String aliash8e1 = "prueba 1";
     final String topoh8e1 = "Caja Rural, Castellón de la Plana, VC, España";

    final locationMock = Location(Coordinate(lath8e1, longh8e1), topoh8e1, aliash8e1);
    
    when(mockDbAdapterLocation.createLocationFromCoord(any)).thenAnswer((_) async => true);

    await locationController.createLocationFromCoord(lath8e1, longh8e1, aliash8e1);

     // THEN
    when(mockDbAdapterLocation.deleteLocation(any)).thenAnswer((_) async => true);
    when(mockDbAdapterLocation.getLocationList()).thenAnswer((_) async => {});

    await locationController.deleteLocation(locationMock);
    final Set<Location> locationList = await locationController.getLocationList();
    expect(locationList.isEmpty, true);

    verify(mockDbAdapterLocation.createLocationFromCoord(any)).called(1);
    verify(mockDbAdapterLocation.getLocationList()).called(1);
    verify(mockDbAdapterLocation.deleteLocation(any)).called(1);


 });

});
}


