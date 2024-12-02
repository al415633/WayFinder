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

  group('R5: Gestión de preferencias', () {
    
    test('H20-E1V - Marcar como favorito un lugar', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();

      final double lath5e1 = 39.98567;
      final double longh5e1 = -0.04935;
      final String aliash5e1 = "prueba 1";    

      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {
          Location.conFav(lath5e1,longh5e1, aliash5e1, true),
        },
      );


      // Crear la instancia del controlador
      final locationController = LocationController(mockDbAdapterLocation);

      // GIVEN
      String emailh20e1 = "Pruebah20e1@gmail.com";
      String passwordh20e1 = "Aaaaa,.8";
      String nameh20e1 = "Pruebah20e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh20e1, passwordh20e1))
          .thenAnswer((_) async => UserApp("id", nameh20e1, emailh20e1));

      UserApp? newUserApp = await userAppController.createUser(emailh20e1, passwordh20e1, nameh20e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterLocation.createLocationFromCoord(any))
          .thenAnswer((_) async => true);

      await locationController.createLocationFromCoord(lath5e1, longh5e1, aliash5e1);

       // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav("", aliash5e1))
          .thenAnswer((_) async => true);

      await locationController.addFav("", aliash5e1);

       
      // THEN
      final Set<Location> location = await mockDbAdapterLocation.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocationh5e1.getCoordinate().getLat(), equals(lath5e1)); // Verifica la latitud
      expect(firstLocationh5e1.getCoordinate().getLong(), equals(longh5e1)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(), equals("")); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias
      expect(firstLocationh5e1.getFav(), equals(true)); // Verifica el alias

    });
 
    test('H20-E2I - Marcar como favorito un lugar inválido', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();

      final double lath5e1 = 39.98567;
      final double longh5e1 = -0.04935;
      final String aliash5e1 = "prueba 1";    

      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {
          Location.conFav(lath5e1,longh5e1, aliash5e1, false),
        },
      );


      // Crear la instancia del controlador
      final locationController = LocationController(mockDbAdapterLocation);

      // GIVEN
      String emailh20e1 = "Pruebah20e1@gmail.com";
      String passwordh20e1 = "Aaaaa,.8";
      String nameh20e1 = "Pruebah20e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh20e1, passwordh20e1))
          .thenAnswer((_) async => UserApp("id", nameh20e1, emailh20e1));

      UserApp? newUserApp = await userAppController.createUser(emailh20e1, passwordh20e1, nameh20e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterLocation.createLocationFromCoord(any))
          .thenAnswer((_) async => true);

      await locationController.createLocationFromCoord(lath5e1, longh5e1, aliash5e1);

       // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav("", aliash5e1))
          .thenAnswer((_) async => false); // Aquí ponemos FALSE porque en este caso no "encuentra" el sitio

      await locationController.addFav("", aliash5e1);

       
      // THEN
      final Set<Location> location = await mockDbAdapterLocation.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocationh5e1.getCoordinate().getLat(), equals(lath5e1)); // Verifica la latitud
      expect(firstLocationh5e1.getCoordinate().getLong(), equals(longh5e1)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(), equals("")); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias
      expect(firstLocationh5e1.getFav(), equals(false)); // Verifica el alias

    });




 });

}


