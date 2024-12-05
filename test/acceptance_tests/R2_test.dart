import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    late FirebaseAuth auth;
    late UserApp? userApp;

    // Esto se ejecuta antes de todas las pruebas
    setUpAll(() async {
      // Inicializar Firebase solo una vez
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
          authDomain: "wayfinder-df8eb.firebaseapp.com",
          projectId: "wayfinder-df8eb",
          storageBucket: "wayfinder-df8eb.appspot.com",
          messagingSenderId: "571791500413",
          appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
          measurementId: "G-TZLW8P5J8V",
        ),
      );

      // Configurar los adaptadores y controladores
      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollectionR2");
      userAppController = UserAppController(userAppAdapter);
    });

    // Esto se ejecuta antes de cada prueba
    setUp(() async {
      // Configura las dependencias necesarias
      locationAdapter = FirestoreAdapterLocation(collectionName: "testCollectionR2");
      locationController = LocationController(locationAdapter);
    });


    Future<void> cleanUp() async {
      // Limpiar la colección de usuarios y ubicaciones
      var collectionRef = FirebaseFirestore.instance.collection('testCollectionR2');
      var querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); 
      }
    }

    // Esto se ejecuta después de cada prueba
    tearDown(() async {
      // Limpiar cualquier dato residual
      await cleanUp(); // Limpiar la colección de pruebas
    });

    // Esto se ejecuta después de todas las pruebas
    tearDownAll(() async {
      // Limpiar la base de datos de prueba, por ejemplo, eliminar todos los usuarios
      await cleanUp();
    });


    // Método para limpiar y eliminar el usuario
    Future<void> deleteUser(String email, String password) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await userCredential.user!.delete();
      } catch (e) {
        // Manejar errores si el usuario ya no existe
        print('Error al eliminar el usuario: $e');
      }
    }

    test('H5-E1V - Crear lugar por coordenadas', () async {
      // GIVEN

      // Crear y autenticar el usuario
      String emailh5e1 = "Pruebah5e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh5e1 = "Aaaaa,.8";
      String nameh5e1 = "Pruebah5e1";
      await userAppController.createUser(emailh5e1, passwordh5e1, nameh5e1);
      await userAppController.logInCredenciales(emailh5e1, passwordh5e1);

      // WHEN
      final double lath5e1 = 39.98567;
      final double longh5e1 = -0.04935;
      final String aliash5e1 = "prueba 1";
      final String topoh5e1 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromCoord(lath5e1, longh5e1, aliash5e1);

      // THEN
      final Set<Location> location = await locationController.getLocationList();
      final locationListh5e1 = location.toList();
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh5e1.getCoordinate().getLat - lath5e1) < 0.001, equals(true));
      expect((firstLocationh5e1.getCoordinate().getLong - longh5e1) < 0.001 , equals(true));
      expect(firstLocationh5e1.getToponym(), equals(topoh5e1));
      expect(firstLocationh5e1.getAlias(), equals(aliash5e1));

      // Limpiar los datos de usuario
      await deleteUser(emailh5e1, passwordh5e1);
    });

    test('H5-E3I - Coordenadas del Lugar incorrectas', () async {
      // GIVEN
      String emailh5e3 = "Pruebah5e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh5e3 = "Aaaaa,.8";
      String nameh5e3 = "Pruebah5e3";
      await userAppController.createUser(emailh5e3, passwordh5e3, nameh5e3);
      await userAppController.logInCredenciales(emailh5e3, passwordh5e3);

      // WHEN
      final double lath5e3 = 91; // Latitud fuera de rango
      final double longh5e3 = 181; // Longitud fuera de rango
      final String aliash5e3 = "prueba 2";

      // THEN
      expect(
        () async => await locationController.createLocationFromCoord(lath5e3, longh5e3, aliash5e3),
        throwsA(isA<Exception>()),
      );

      // Limpiar datos del usuario
      await deleteUser(emailh5e3, passwordh5e3);
    });

    test('H6-E1V - Crear lugar por toponimo', () async {
      // GIVEN
      String emailh6e1 = "Pruebah6e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e1 = "Aaaaa,.8";
      String nameh6e1 = "Pruebah6e1";
      await userAppController.createUser(emailh6e1, passwordh6e1, nameh6e1);
      await userAppController.logInCredenciales(emailh6e1, passwordh6e1);

      // WHEN
      final double lath6e1 = 39.98567;
      final double longh6e1 = -0.04935;
      final String aliash6e1 = "prueba 1";
      final String topoh6e1 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromTopo(topoh6e1, aliash6e1);

      // THEN
      final Set<Location> location = await locationController.getLocationList();
      final locationListh6e1 = location.toList();
      final firstLocationh6e1 = locationListh6e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh6e1.getCoordinate().getLat - lath6e1) < 0.001, equals(true));
      expect((firstLocationh6e1.getCoordinate().getLong - longh6e1) < 0.001, equals(true));
      expect(firstLocationh6e1.getToponym(), equals(topoh6e1));
      expect(firstLocationh6e1.getAlias(), equals(aliash6e1));

      // Limpiar los datos de usuario
      await deleteUser(emailh6e1, passwordh6e1);
    });

    test('H6-E2I - Topónimo lugar inválido', () async {
      // GIVEN
      String emailh6e2 = "Pruebah6e2${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e2 = "Aaaaa,.8";
      String nameh6e2 = "Pruebah6e2";
      await userAppController.createUser(emailh6e2, passwordh6e2, nameh6e2);
      await userAppController.logInCredenciales(emailh6e2, passwordh6e2);

      // WHEN
      final String aliash6e2 = "prueba 1";
      final String topoh6e2 = "dfhve5buy"; // Topónimo no válido

      // THEN
      expect(
        () async => await locationController.createLocationFromTopo(topoh6e2, aliash6e2),
        throwsA(isA<Exception>()),
      );

      // Limpiar datos del usuario
      await deleteUser(emailh6e2, passwordh6e2);
    });

    test('H7-E1V - Obtener lugar por coordenadas', () async {
      // GIVEN
      String emailh7e1 = "Pruebah7e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh7e1 = "Aaaaa,.8";
      String nameh7e1 = "Pruebah7e1";
      await userAppController.createUser(emailh7e1, passwordh7e1, nameh7e1);
      await userAppController.logInCredenciales(emailh7e1, passwordh7e1);

      // WHEN
      final double lath7e1 = 39.98567;
      final double longh7e1 = -0.04935;
      final String aliash7e1 = "prueba 1";

      await locationController.createLocationFromCoord(lath7e1, longh7e1, aliash7e1);

      // THEN
      final Set<Location> location = await locationController.getLocationList();
      final locationListh7e1 = location.toList();
      final firstLocationh7e1 = locationListh7e1[0];

      expect((firstLocationh7e1.getCoordinate().getLat - lath7e1) < 0.001, equals(true));
      expect((firstLocationh7e1.getCoordinate().getLong - longh7e1) < 0.001, equals(true));
      expect(firstLocationh7e1.getAlias(), equals(aliash7e1));

      // Limpiar los datos de usuario
      await deleteUser(emailh7e1, passwordh7e1);
    });




    test('H7-E3I - Listar lugares inválida porque no hay usuario autenticado', () async {

      locationAdapter = FirestoreAdapterLocation(collectionName: "testCollectionR2");


       //GIVEN

       
      //THEN

      
          expect(
        () async => LocationController(locationAdapter),
        throwsA(isA<Exception>()),
        
      );
      



    }, skip: true);


    test('H8', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });
   


  });
}
