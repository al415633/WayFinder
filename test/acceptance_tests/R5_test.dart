// precio_luz_service_acceptance_test.dart
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterUserApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R5: Gestión de preferencias', () {
    late DbAdapterLocation adapterLocation;
    late LocationController locationController;

    late DbAdapterUserApp adapterUserApp;
    late UserAppController userAppController;

    late UserApp? userApp;

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
            measurementId: "G-TZLW8P5J8V"),
      );

      adapterUserApp =
          FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(adapterUserApp);

      // Crear usuario de prueba
      const email = "pruebaR5@gmail.com";
      const password = "Qaaaa,.8";
      const nameU = "Qsa";

      try {
        await userAppController.createUser(email, password, nameU);
      } catch (e) {
        if (e is FirebaseAuthException && e.code != 'email-already-in-use') {
          rethrow;
        }
      }

      // Iniciar sesión
      await userAppController.logInCredenciales(email, password);
    });

    tearDownAll(() async {
      // Borrar todos los documentos de testCollection
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollection');
      var querySnapshot = await collectionRef.get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Eliminar el usuario
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }
    });

    Future<void> deleteLocation(String alias) async {
      var collectionRef = FirebaseFirestore.instance.collection('location');
      var querySnapshot =
          await collectionRef.where('alias', isEqualTo: alias).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Actualizar la lista de ubicaciones si es necesario, similar a como se hacía en el ejemplo del vehículo
      locationController.locationList = Future.value(<Location>{});
    }

    // Helper para limpiar la colección y eliminar usuario
    Future<void> cleanUp() async {
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollection');
      var querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }

    Future<UserApp?> signInAndDeleteUser(String email, String password) async {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cleanUp();
      await userCredential.user!.delete();
      return null;
    }

    test('H20-E1V - Marcar como favorito un lugar', () async {
      // GIVEN
      String emailh20e1 =
          "Pruebah20e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh20e1 = "Aaaaa,.8";
      String nameh20e1 = "Pruebah20e1";
      await userAppController.createUser(emailh20e1, passwordh20e1, nameh20e1);
      userApp =
          await userAppController.logInCredenciales(emailh20e1, passwordh20e1);

      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      // WHEN
      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";
      final String topo1 = "Caja Rural, Castellón de la Plana, VC, España";

      Location loc =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);

      // Verificar que la ubicación se ha añadido correctamente
      locationController.addFav(loc);

      final Set<Location> locations =
          await locationController.getLocationList();
      expect(locations.isNotEmpty, true); // Asegúrate de que no esté vacío

      // THEN
      final locationList = locations.toList();

      final Location primerLugar = locationList[0];

      expect(primerLugar.getFav(),
          equals(true)); // Verifica que el lugar se haya marcado como favorito

      await signInAndDeleteUser(emailh20e1, passwordh20e1);
      await deleteLocation(apodo1);
    });

//No se puede probar en aceptación ya que no se puede crear un lugar inválido
//Menos aún marcarlo como favorito

/*
    test('H20-E2I - Marcar como favorito un lugar inválido', () async {
      // GIVEN
      String emailh20e2 =
          "Pruebah20e2${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh20e2 = "Aaaaa,.8";
      String nameh20e2 = "Pruebah20e2";
      await userAppController.createUser(emailh20e2, passwordh20e2, nameh20e2);
      userApp =
          await userAppController.logInCredenciales(emailh20e2, passwordh20e2);

      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      Location loc;

      // WHEN Y THEN
      expect(
        () => locationController.addFav(loc),
        throwsA(isA<Exception>()),
      );
    });
    */

    test(
        'H21-EV1 Como usuario quiero establecer un modo de transporte por defecto',
        () async {
      // GIVEN
      String email =
          "Pruebah21e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah21e1";

      UserApp? userApp =
          await userAppController.createUser(email, password, name);
      userApp = await userAppController.logInCredenciales(email, password);

      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      // WHEN
      userAppController.setTransportModeDefault(
          userApp!, TransportMode.bicicleta, null);
      //THEN
      expect(userApp?.getDefaultTransportMode, TransportMode.bicicleta);

      await signInAndDeleteUser(email, password);
    });

    test(
        'H21-EI3 No se puede establecer un modo de transporte por defecto si no hay usuario registrado',
        () async {
      // GIVEN
      userApp = null;

      //WHEN Y THEN
      expect(
          () => userAppController.setTransportModeDefault(
              userApp, TransportMode.bicicleta, null),
          throwsA(isA<UserNotAuthenticatedException>()));
    });

    test(
        'H22-EV1 Como usuario quiero establecer un modo de ruta por defecto',
        () async {
      // GIVEN
      String email =
          "Pruebah22e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah22e1";

      UserApp? userApp =
          await userAppController.createUser(email, password, name);
      userApp = await userAppController.logInCredenciales(email, password);

      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      // WHEN
      userAppController.setRouteModeDefault(
          userApp!, RouteMode.corta);
      //THEN
      expect(userApp?.getDefaultRouteMode, RouteMode.corta);

      await signInAndDeleteUser(email, password);
    });

    test(
        'H22-EI4 No se puede establecer un modo de ruta por defecto si no hay usuario registrado',
        () async {
      // GIVEN
      userApp = null;

      //WHEN Y THEN
      expect(
          () => userAppController.setRouteModeDefault(
              userApp, RouteMode.corta),
          throwsA(isA<UserNotAuthenticatedException>()));
    });

  });
}
