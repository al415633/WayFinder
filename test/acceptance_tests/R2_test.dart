// precio_luz_service_acceptance_test.dart

import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R2: Gestión de lugares de interés', () {


    late DbAdapterLocation locationAdapter;

    late LocationController locationController;

    late DbAdapterUserApp userAppAdapter;
    late UserAppController userAppController;

    setUpAll(() async {
      // Inicializar el entorno de pruebas

      // no se si hace falta el test delante
      TestWidgetsFlutterBinding.ensureInitialized();

      // Cargar la configuración desde firebase_config.json

      //google serviceds
      

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
          authDomain: "wayfinder-df8eb.firebaseapp.com",
          projectId: "wayfinder-df8eb",
          storageBucket: "wayfinder-df8eb.appspot.com",
          messagingSenderId: "571791500413",
          appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
          measurementId: "G-TZLW8P5J8V"
        ),
      );
    });
    

    setUp(() async {
      locationAdapter = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(locationAdapter);

      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(userAppAdapter);
    });

    test('H5-E1V - Crear lugar', () async {

      //GIVEN

      //Loguear usuario
   
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? user = userAppController.createUser(email, password);
      user = userAppController.logInCredenciales(email, password);


      //WHEN

      final double lat = 39.98567;
      final double long = -0.04935;
      final String alias = "prueba 1";

      await locationController.createLocationFromCoord(lat, long, alias);


      //THEN

      final Set<Location> location = locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationList = location.toList();
      
      // Acceder al primer objeto en la lista
      final firstLocation = locationList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocation.getCoordinate(), equals(Coordinate(lat, long))); // Verifica la latitud
      expect(firstLocation.getToponym(), equals("Castelló de la Plana")); // Verifica la longitud
      expect(firstLocation.getAlias(), equals("prueba 1")); // Verifica el alias


    });


    test('H5-E3I - Coordenadas del Lugar incorrectas', () async {

      //GIVEN

      //Loguear usuario
      
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? user = userAppController.createUser(email, password);
      user = userAppController.logInCredenciales(email, password);


      //WHEN

      final double lat = 91;
      final double long = 181;
      final String alias = "prueba 2";

      locationController.createLocationFromCoord(lat, long, alias);


      //THEN

      expect(() {
      locationController.createLocationFromCoord(lat, long, alias);
    }, throwsException);


    });


    test('H6', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });


    test('H7-E1V - Listar lugares', () async {
       //GIVEN

      //Loguear usuario
      
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? user = userAppController.createUser(email, password);
      user = userAppController.logInCredenciales(email, password);

      final double lat1 = 39.98567;
      final double long1 = -0.4935;
      final String alias1 = "Castellon";

      await locationController.createLocationFromCoord(lat1, long1, alias1);

      final String topo2 = "mi casa";
      final String alias2 = "Burriana";

      await locationController.createLocationFromTopo(topo2, alias2);

      //WHEN

      final Set<Location> location = locationController.getLocationList();

      //THEN

      // Convertir el set a una lista para acceder al primer elemento
      final locationList = location.toList();
      
      // Acceder al primer objeto en la lista
      final firstLocation = locationList[0];
      final secondLocation = locationList[1];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstLocation.getCoordinate(), equals(Coordinate(lat1, long1))); // Verifica las coordenadas
      expect(firstLocation.getToponym(), equals("Castelló de la Plana")); // Verifica el toponimo
      expect(firstLocation.getAlias(), equals("castellon")); // Verifica el alias


      // Verificar que los valores del segundo lugar son los esperados
      expect(secondLocation.getToponym(), equals("Burriana")); // Verifica el toponimo
      expect(secondLocation.getAlias(), equals("mi casa")); // Verifica el alias

    });


    test('H7-E4I - Listar lugares inválida porque no hay conexion BBDD', () async {
       //GIVEN

      //Loguear usuario
      
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? user = userAppController.createUser(email, password);
      user = userAppController.logInCredenciales(email, password);

      //WHEN Y THEN

      expect(() {
      locationController.getLocationList();
    }, throwsException);

    });


    test('H8', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });
   


  });
}
