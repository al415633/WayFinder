import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterVehicle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'R5_Itest.mocks.dart';

@GenerateMocks(
    [FirebaseAuth, DbAdapterUserApp, DbAdapterLocation, DbAdapterVehicle])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('R5: Gestión de preferencias', () {
    late MockDbAdapterVehicle mockVehicleAdapter;
    late MockDbAdapterUserApp mockDbAdapterUserApp;
    late MockDbAdapterLocation mockDbAdapterLocation;
    late UserAppController userAppController;

    setUp(() {
      mockVehicleAdapter = MockDbAdapterVehicle();
      mockDbAdapterUserApp = MockDbAdapterUserApp();
      mockDbAdapterLocation = MockDbAdapterLocation();
      userAppController = UserAppController(mockDbAdapterUserApp);
    });

    test('H20-E1V - Marcar como favorito un lugar', () async {
      final double lat = 39.98567;
      final double long = -0.04935;
      final String alias = "prueba 1";
      final String toponym = "Caja Rural, Castellón de la Plana, VC, España";

      Location loc = Location(Coordinate(lat, long), toponym, alias);

      when(mockDbAdapterLocation.getLocationList()).thenAnswer(
        (_) async => {loc},
      );

      final locationController = LocationController(mockDbAdapterLocation);

      String email = "Pruebah20e1@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah20e1";

      when(userAppController.repository.createUser(email, password))
          .thenAnswer((_) async => UserApp("id", name, email));

      UserApp? newUserApp = await userAppController.createUser(email, password, name);

      when(mockDbAdapterLocation.addFav(loc)).thenAnswer((_) async {
        loc.fav = true;
        return true;
      });

      locationController.addFav(loc);

      final Set<Location> locations = await mockDbAdapterLocation.getLocationList();
      final locationList = locations.toList();
      final firstLocation = locationList[0];

      expect(firstLocation.getCoordinate().getLat, equals(lat));
      expect(firstLocation.getCoordinate().getLong, equals(long));
      expect(firstLocation.getToponym(), equals(toponym));
      expect(firstLocation.getAlias(), equals(alias));
      expect(firstLocation.getFav(), equals(true));
    });

    test('H20-E2I - Marcar como favorito un lugar inválido', () async {
      final double lat = 39.98567;
      final double long = -0.04935;
      final String alias = "prueba 1";
      final String toponym = "Caja Rural, Castellón de la Plana, VC, España";

      Location loc = Location(Coordinate(lat, long), toponym, alias);

      when(mockDbAdapterLocation.addFav(any)).thenThrow(Exception());

      final locationController = LocationController(mockDbAdapterLocation);

      expect(
        () => locationController.addFav(loc),
        throwsA(isA<Exception>()),
      );
    });

    test('H21-E1V - Establecer un modo de transporte por defecto', () async {
      when(mockVehicleAdapter.getVehicleList()).thenAnswer((_) async => <Vehicle>{});
      final vehicleController = VehicleController(mockVehicleAdapter);

      String email = "Pruebah21e1@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah21e1";

      when(userAppController.repository.createUser(email, password))
          .thenAnswer((_) async => UserApp("id", name, email));

      UserApp? newUserApp = await userAppController.createUser(email, password, name);

      final String vehicleName = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final FuelType fuelType = FuelType.electrico;

      final vehicle = Vehicle(fuelType, consumption, numberPlate, vehicleName);

      when(mockVehicleAdapter.createVehicle(any)).thenAnswer((_) async => true);

      await vehicleController.createVehicle(numberPlate, consumption, fuelType, vehicleName);

      when(mockDbAdapterUserApp.setTransportModeDefault(TransportMode.coche, vehicle))
          .thenAnswer((_) async => true);

      userAppController.setTransportModeDefault(newUserApp, TransportMode.coche, vehicle);

      expect(newUserApp?.getDefaultTransportMode, equals(TransportMode.coche));
    });

    test('H22-E1V - Establecer un modo de ruta por defecto', () async {
      String email = "Pruebah22e1@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah22e1";

      when(userAppController.repository.createUser(email, password))
          .thenAnswer((_) async => UserApp("id", name, email));

      UserApp? newUserApp = await userAppController.createUser(email, password, name);

      when(mockDbAdapterUserApp.setRouteModeDefault(RouteMode.rapida))
          .thenAnswer((_) async => true);

      userAppController.setRouteModeDefault(newUserApp, RouteMode.rapida);

      expect(newUserApp?.getDefaultRouteMode, equals(RouteMode.rapida));
    });

    test('H22-EI4 - No se puede establecer un modo de ruta por defecto sin usuario registrado', () async {
      UserApp? newUserApp = null;

      when(mockDbAdapterUserApp.setRouteModeDefault(RouteMode.corta))
          .thenThrow(UserNotAuthenticatedException());

      expect(
        () => userAppController.setRouteModeDefault(newUserApp, RouteMode.corta),
        throwsA(isA<UserNotAuthenticatedException>()),
      );
    });
  });
}
