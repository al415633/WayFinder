import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/location.dart';
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

    test('H20-E1V - Marcar como favorito un lugar', () async {
      // Configurar los mocks y el controlador dentro del test
      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);
      final mockDbAdapterLocation = MockDbAdapterLocation();

      final double lath20e1 = 39.98567;
      final double longh20e1 = -0.04935;
      final String aliash20e1 = "prueba 1";
      final String topoh20e1 = "Caja Rural, Castellón de la Plana, VC, España";

      Location loc =
          Location(Coordinate(lath20e1, longh20e1), topoh20e1, aliash20e1);
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

      UserApp? newUserApp = await userAppController.createUser(
          emailh20e1, passwordh20e1, nameh20e1);

      // WHEN

      // Simular la creación de un lugar
      when(mockDbAdapterLocation.createLocationFromCoord(any))
          .thenAnswer((_) async => true);

      locationController.createLocationFromCoord(
          lath20e1, longh20e1, aliash20e1);

      // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav(loc)).thenAnswer((_) async {
        loc.fav = true;
        return true;
      });

      locationController.addFav(loc);

      // THEN
      final Set<Location> location =
          await mockDbAdapterLocation.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocationh5e1.getCoordinate().getLat,
          equals(lath20e1)); // Verifica la latitud
      expect(firstLocationh5e1.getCoordinate().getLong,
          equals(longh20e1)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(),
          equals(topoh20e1)); // Verifica el topónimo
      expect(firstLocationh5e1.getAlias(),
          equals(aliash20e1)); // Verifica el alias
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

      Location loca =
          Location(Coordinate(lath5e1, longh5e1), topoh5e1, aliash5e1);
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

      UserApp? newUserApp = await userAppController.createUser(
          emailh20e1, passwordh20e1, nameh20e1);

      // WHEN
      // Simular que guardamos el lugar en favoritos
      when(mockDbAdapterLocation.addFav(any)).thenThrow(
        Exception(),
      );

      Location location =
          Location(Coordinate(lath5e1, longh5e1), topoh5e1, "sdg resgw");

      // THEN
      expect(
        () => locationController.addFav(location),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'H21-E1V - Como usuario quiero establecer un modo de transporte por defecto',
        () async {
      // Configurar los mocks y el controlador dentro del test
      final mockVehicleAdapter = MockDbAdapterVehicle();

      when(mockVehicleAdapter.getVehicleList())
          .thenAnswer((_) async => <Vehicle>{});

      final vehicleController = VehicleController(mockVehicleAdapter);

      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);

      // GIVEN
      String emailh21e1 = "Pruebah21e1@gmail.com";
      String passwordh21e1 = "Aaaaa,.8";
      String nameh21e1 = "Pruebah21e1";

      // Simular la creación del usuario
      when(userAppController.repository.createUser(emailh21e1, passwordh21e1))
          .thenAnswer((_) async => UserApp("id", nameh21e1, emailh21e1));

      UserApp? newUserApp = await userAppController.createUser(
          emailh21e1, passwordh21e1, nameh21e1);

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final FuelType fuelType = FuelType.electrico;

      final vehicleMock = Vehicle(fuelType, consumption, numberPlate, namec);

      when(mockVehicleAdapter.createVehicle(any)).thenAnswer((_) async => true);

      await vehicleController.createVehicle(
          numberPlate, consumption, fuelType, namec);

      when(userAppController.setTransportModeDefault(
              newUserApp, TransportMode.bicicleta, null))
          .thenAnswer(
        (_) async => newUserApp?.defaultTransportMode = TransportMode.bicicleta,
      );

      // WHEN

      when(mockDbAdapterUserApp.setTransportModeDefault(
              TransportMode.coche, vehicleMock))
          .thenAnswer((_) async => true);

      userAppController.setTransportModeDefault(
          newUserApp, TransportMode.coche, vehicleMock);

      // THEN
      expect(
          newUserApp?.getDefaultTransportMode,
          equals(TransportMode
              .coche)); // Verifica que se ponga el RouteMode por defecto que queremos
    });


     test(
        'H21-EI3 No se puede establecer un modo de transporte por defecto si no hay usuario registrado',
        () async {
      // Configurar los mocks y el controlador dentro del test
      final mockVehicleAdapter = MockDbAdapterVehicle();

      when(mockVehicleAdapter.getVehicleList())
          .thenAnswer((_) async => <Vehicle>{});

      final vehicleController = VehicleController(mockVehicleAdapter);

      final mockAuth = MockFirebaseAuth();
      final mockDbAdapterUserApp = MockDbAdapterUserApp();
      final userAppController = UserAppController(mockDbAdapterUserApp);

      // GIVEN

      UserApp? newUserApp = null;

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final FuelType fuelType = FuelType.electrico;

      final vehicleMock = Vehicle(fuelType, consumption, numberPlate, namec);

      // WHEN

    when(mockDbAdapterUserApp.setTransportModeDefault(
              TransportMode.bicicleta, null))
          .thenThrow(UserNotAuthenticatedException());

      // THEN
       expect(
          () async => userAppController.setTransportModeDefault(
              newUserApp, TransportMode.bicicleta, null),
          throwsA(isA<UserNotAuthenticatedException>()));
    });
  });
}
