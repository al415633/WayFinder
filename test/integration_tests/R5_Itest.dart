import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
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

      final double lath20e1 = 39.98567;
      final double longh20e1 = -0.04935;
      final String aliash20e1 = "prueba 1";   
      final String topoh20e1 =  "Caja Rural, Castellón de la Plana, VC, España";

      Location loc = Location(Coordinate(lath20e1, longh20e1), topoh20e1, aliash20e1);
      loc.addFav;

      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {
          loc,
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

      locationController.createLocationFromCoord(lath20e1, longh20e1, aliash20e1);

       // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav(loc)).thenAnswer((_) async {
        loc.fav = true;
        return true;
      });

      locationController.addFav(loc);
       
      // THEN
      final Set<Location> location = await mockDbAdapterLocation.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocationh5e1.getCoordinate().getLat, equals(lath20e1)); // Verifica la latitud
      expect(firstLocationh5e1.getCoordinate().getLong, equals(longh20e1)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(), equals(topoh20e1)); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(), equals(aliash20e1)); // Verifica el alias
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
      final String topoh5e1 = "Caja Rural, Castellón de la Plana, VC, España";    

      Location loca = Location(Coordinate(lath5e1, longh5e1), topoh5e1, aliash5e1);
      loca.addFav;


      // Configurar el stub de `getLocationList`
      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {
          loca,
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
       // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav(any))
        .thenThrow(Exception(),);

      Location location = Location(Coordinate(lath5e1, longh5e1), topoh5e1, "sdg resgw");
       
      // THEN
      expect(
        () =>locationController.addFav(location),
        throwsA(isA<Exception>()),
      );


    });

    test('H22-E1V - Como usuario quiero establecer un modo de ruta por defecto', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);

      // GIVEN
      String emailh22e1 = "Pruebah22e1@gmail.com";
      String passwordh22e1 = "Aaaaa,.8";
      String nameh22e1 = "Pruebah22e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh22e1, passwordh22e1))
          .thenAnswer((_) async => UserApp("id", nameh22e1, emailh22e1));

      UserApp? newUserApp = await userAppController.createUser(emailh22e1, passwordh22e1, nameh22e1);


            // Configurar el stub de `getLocationList`
      when(mockDbAdapterUserApp.setRouteModeDefault(RouteMode.rapida)).thenAnswer(
        (_) async => 
            newUserApp?.defaultRouteMode = RouteMode.rapida,
      );

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterUserApp.setRouteModeDefault(RouteMode.rapida))
          .thenAnswer((_) async => true);

      userAppController.setRouteModeDefault(newUserApp, RouteMode.rapida);

       
      // THEN

      // Verificar que se ha llamado a `setRouteModeDefault` con el RouteMode correcto
      expect(newUserApp?.getDefaultRouteMode, equals(RouteMode.rapida)); // Verifica que se ponga el RouteMode por defecto que queremos

    });
 
    test('H22-EI4 No se puede establecer un modo de ruta por defecto si no hay usuario registrado', () async {
      
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);


      // GIVEN
      UserApp? newUserApp = null;

      // WHEN

      // Simular el metodo setRouteModeDefault
      when(mockDbAdapterUserApp.setRouteModeDefault(RouteMode.corta))
        .thenThrow(Exception(),);
      
      // THEN

      expect(
        () =>userAppController.setRouteModeDefault(newUserApp, RouteMode.corta),
        throwsA(isA<Exception>()),
      );      

    });

 });

}


