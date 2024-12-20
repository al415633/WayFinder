import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R6_Itest.mocks.dart';

@GenerateMocks([DbAdapterUserApp, DbAdapterLocation])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('R6:Persistencia de los contenidos de la aplicación', () {
    
    test('H23-E1V', () async {
      //TEST PERSISTENCIA

      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();

      final double lath23e1 = 39.98567;
      final double longh23e1 = -0.04935;
      final String aliash23e1 = "prueba 1";   
      final String topoh23e1 =  "Caja Rural, Castellón de la Plana, VC, España";

      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {},);

      final locationController = LocationController(mockDbAdapterLocation);
      //GIVEN
      String email = "Pruebah23e1@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah23e1";
      
      when(mockDbAdapterUserApp.logInCredenciales(email, password)).thenAnswer(
        (_) async => UserApp("id", name, email),
      );

      when(mockDbAdapterUserApp.logOut()).thenAnswer(
        (_) async => true,
      );

      final loc = Location(Coordinate(lath23e1, longh23e1), topoh23e1, aliash23e1);
      when(mockDbAdapterLocation.createLocationFromCoord(loc)).thenAnswer(
        (_) async => true,
      );

      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {Location(Coordinate(lath23e1, longh23e1), topoh23e1, aliash23e1)},
      );

      //WHEN
      await userAppController.logInCredenciales(email, password);
      await locationController.createLocationFromCoord(lath23e1, longh23e1, aliash23e1);

      await userAppController.logOut();

      await userAppController.logInCredenciales(email, password);

      //THEN

      final locationList = await locationController.getLocationList();
      expect(locationList.length, 1);
      expect(locationList.contains(Location(Coordinate(lath23e1, longh23e1), topoh23e1, aliash23e1)), true);
    });

 
    test('H23-E2I - Persistencia de los contenidos pero no hay conexión a la BBDD', () async {
      //TEST PERSISTENCIA
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();


      //GIVEN
      String email = "Pruebah23e3@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah23e3";  

      when(mockDbAdapterUserApp.logInCredenciales(email, password)).thenAnswer(
        (_) async => UserApp("id", name, email),
      );

      when(mockDbAdapterLocation.getLocationList()).thenThrow(Exception(),);

      //WHEN
      await userAppController.logInCredenciales(email, password);

      // THEN
      expect(
        () => LocationController(mockDbAdapterLocation), //Aqui se hace el getLocationList
        throwsA(isA<Exception>()),
      );


    });




 });

}


