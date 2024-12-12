// precio_luz_service_acceptance_test.dart

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
            apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
            authDomain: "wayfinder-df8eb.firebaseapp.com",
            projectId: "wayfinder-df8eb",
            storageBucket: "wayfinder-df8eb.appspot.com",
            messagingSenderId: "571791500413",
            appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
            measurementId: "G-TZLW8P5J8V"),
      );

      locationAdapter =
          FirestoreAdapterLocation(collectionName: "testCollectionR2");
      locationAdapter =
          FirestoreAdapterLocation(collectionName: "testCollectionR2");
      locationController = LocationController.getInstance(locationAdapter);

      userAppAdapter =
          FirestoreAdapterUserApp(collectionName: "testCollectionR2");
      userAppAdapter =
          FirestoreAdapterUserApp(collectionName: "testCollectionR2");
      userAppController = UserAppController.getInstance(userAppAdapter);
    });

    Future<void> deleteLocation(String alias) async {
    Future<void> deleteLocation(String alias) async {
      var collectionRef = FirebaseFirestore.instance.collection('location');
      var querySnapshot =
          await collectionRef.where('alias', isEqualTo: alias).get();
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
          FirebaseFirestore.instance.collection('testCollectionR2');
      var querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }
    Future<void> cleanUp() async {
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollectionR2');
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

    test('H5-E1V - Crear lugar por coordenadas', () async {
      //GIVEN

      //Loguear usuario
      String emailh5e1 =
          "Pruebah5e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String emailh5e1 =
          "Pruebah5e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh5e1 = "Aaaaa,.8";
      String nameh5e1 = "Pruebah5e1";
      String nameh5e1 = "Pruebah5e1";
      await userAppController.createUser(emailh5e1, passwordh5e1, nameh5e1);

      await userAppController.logInCredenciales(emailh5e1, passwordh5e1);

      //WHEN

      final double lath5e1 = 39.98567;
      final double longh5e1 = -0.04935;
      final String aliash5e1 = "prueba 1";
      final String topoh5e1 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromCoord(
          lath5e1, longh5e1, aliash5e1);
      await locationController.createLocationFromCoord(
          lath5e1, longh5e1, aliash5e1);

      //THEN

      final Set<Location> location = await locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();


      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh5e1.getCoordinate().getLat - lath5e1) < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh5e1.getCoordinate().getLong - longh5e1) < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(),
          equals(topoh5e1)); // Verifica el topónimo
      expect(
          firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias
      expect((firstLocationh5e1.getCoordinate().getLat - lath5e1) < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh5e1.getCoordinate().getLong - longh5e1) < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(),
          equals(topoh5e1)); // Verifica el topónimo
      expect(
          firstLocationh5e1.getAlias(), equals(aliash5e1)); // Verifica el alias

      await signInAndDeleteUser(emailh5e1, passwordh5e1);

      await deleteLocation(aliash5e1);
    });

    test('H5-E3I - Coordenadas del Lugar incorrectas', () async {
      //GIVEN

      //Loguear usuario
      String emailh5e3 =
          "Pruebah5e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String emailh5e3 =
          "Pruebah5e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh5e3 = "Aaaaa,.8";
      String nameh5e3 = "Pruebah5e3";
      String nameh5e3 = "Pruebah5e3";
      await userAppController.createUser(emailh5e3, passwordh5e3, nameh5e3);

      await userAppController.logInCredenciales(emailh5e3, passwordh5e3);

      //WHEN

      final double lath5e3 = 91;
      final double longh5e3 = 181;
      final String aliash5e3 = "prueba 2";

      //THEN

      expect(
        () async => await locationController.createLocationFromCoord(
            lath5e3, longh5e3, aliash5e3),
        throwsA(isA<Exception>()),
      );
        () async => await locationController.createLocationFromCoord(
            lath5e3, longh5e3, aliash5e3),
        throwsA(isA<Exception>()),
      );

      await signInAndDeleteUser(emailh5e3, passwordh5e3);
      await deleteLocation(aliash5e3);
      await signInAndDeleteUser(emailh5e3, passwordh5e3);
      await deleteLocation(aliash5e3);
    });

    test('H6-E1V - Crear lugar por toponimo', () async {
      //GIVEN
    test('H6-E1V - Crear lugar por toponimo', () async {
      //GIVEN

      //Loguear usuario
      String emailh6e1 =
          "Pruebah6e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e1 = "Aaaaa,.8";
      String nameh6e1 = "Pruebah6e1";
      await userAppController.createUser(emailh6e1, passwordh6e1, nameh6e1);
      await userAppController.logInCredenciales(emailh6e1, passwordh6e1);
      //Loguear usuario
      String emailh6e1 =
          "Pruebah6e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e1 = "Aaaaa,.8";
      String nameh6e1 = "Pruebah6e1";
      await userAppController.createUser(emailh6e1, passwordh6e1, nameh6e1);
      await userAppController.logInCredenciales(emailh6e1, passwordh6e1);

      //WHEN
      //WHEN

      final double lath6e1 = 39.98567;
      final double longh6e1 = -0.04935;
      final String aliash6e1 = "prueba 1";
      final String topoh6e1 = "Caja Rural, Castellón de la Plana, VC, España";
      final double lath6e1 = 39.98567;
      final double longh6e1 = -0.04935;
      final String aliash6e1 = "prueba 1";
      final String topoh6e1 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromTopo(topoh6e1, aliash6e1);
      await locationController.createLocationFromTopo(topoh6e1, aliash6e1);

      //THEN
      //THEN

      final Set<Location> location = await locationController.getLocationList();
      final Set<Location> location = await locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];
      // Convertir el set a una lista para acceder al primer elemento
      final locationListh5e1 = location.toList();

      // Acceder al primer objeto en la lista
      final firstLocationh5e1 = locationListh5e1[0];

      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh5e1.getCoordinate().getLat - lath6e1) < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh5e1.getCoordinate().getLong - longh6e1) < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(),
          equals(topoh6e1)); // Verifica el topónimo
      expect(
          firstLocationh5e1.getAlias(), equals(aliash6e1)); // Verifica el alias
      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh5e1.getCoordinate().getLat - lath6e1) < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh5e1.getCoordinate().getLong - longh6e1) < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh5e1.getToponym(),
          equals(topoh6e1)); // Verifica el topónimo
      expect(
          firstLocationh5e1.getAlias(), equals(aliash6e1)); // Verifica el alias

      await signInAndDeleteUser(emailh6e1, passwordh6e1);
      await deleteLocation(aliash6e1);
    });
      await signInAndDeleteUser(emailh6e1, passwordh6e1);
      await deleteLocation(aliash6e1);
    });

    test('H6-E2I - Topónimo lugar inválido', () async {
      //GIVEN
    test('H6-E2I - Topónimo lugar inválido', () async {
      //GIVEN

      //Loguear usuario
      String emailh6e2 =
          "Pruebah6e2${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e2 = "Aaaaa,.8";
      String nameh6e2 = "Pruebah6e2";
      //Loguear usuario
      String emailh6e2 =
          "Pruebah6e2${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh6e2 = "Aaaaa,.8";
      String nameh6e2 = "Pruebah6e2";

      await userAppController.createUser(emailh6e2, passwordh6e2, nameh6e2);
      await userAppController.logInCredenciales(emailh6e2, passwordh6e2);
      await userAppController.createUser(emailh6e2, passwordh6e2, nameh6e2);
      await userAppController.logInCredenciales(emailh6e2, passwordh6e2);

      //WHEN
      //WHEN

      final String aliash6e2 = "prueba 1";
      final String topoh6e2 = "dfhve5buy";
      final String aliash6e2 = "prueba 1";
      final String topoh6e2 = "dfhve5buy";

      //THEN
      //THEN

      expect(
        () async => await locationController.createLocationFromTopo(
            topoh6e2, aliash6e2),
        throwsA(isA<Exception>()),
      expect(
        () async => await locationController.createLocationFromTopo(
            topoh6e2, aliash6e2),
        throwsA(isA<Exception>()),
      );

      await signInAndDeleteUser(emailh6e2, passwordh6e2);
      await deleteLocation(aliash6e2);
    });
      await signInAndDeleteUser(emailh6e2, passwordh6e2);
      await deleteLocation(aliash6e2);
    });

    test('H7-E1V - Listar lugares', () async {
      //GIVEN
      //GIVEN

      //Loguear usuario

      String emailh7e1 =
          "Pruebah7e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String emailh7e1 =
          "Pruebah7e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh7e1 = "Aaaaa,.8";
      String nameh7e1 = "Pruebah7e1";
      String nameh7e1 = "Pruebah7e1";
      await userAppController.createUser(emailh7e1, passwordh7e1, nameh7e1);
      await userAppController.logInCredenciales(emailh7e1, passwordh7e1);


      //Hecho en el setUpAll

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String alias1h7e1 = "Castellon";
      final String topoh7e1 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromCoord(lat1, long1, alias1h7e1);

      final double lat2 = 39.98567;
      final double long2 = -0.04935;
      final String alias2 = "mi casa";
      final String topo2 = "Caja Rural, Castellón de la Plana, VC, España";

      await locationController.createLocationFromCoord(lat2, long2, alias2);

      //WHEN

      final Set<Location> location = await locationController.getLocationList();

      //THEN

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh7e1 = location.toList();


      // Acceder al primer objeto en la lista
      final firstLocationh7e1 = locationListh7e1[0];
      final secondLocationh7e1 = locationListh7e1[1];

      // Verificar que los valores del primer lugar son los esperados
      expect((firstLocationh7e1.getCoordinate().getLat - lat1).abs() < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh7e1.getCoordinate().getLong - long1).abs() < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh7e1.getToponym(),
          equals(topoh7e1)); // Verifica el toponimo
      expect(firstLocationh7e1.getAlias(),
          equals(alias1h7e1)); // Verifica el alias
      expect((firstLocationh7e1.getCoordinate().getLat - lat1).abs() < 0.001,
          equals(true)); // Verifica la latitud
      expect((firstLocationh7e1.getCoordinate().getLong - long1).abs() < 0.001,
          equals(true)); // Verifica la longitud
      expect(firstLocationh7e1.getToponym(),
          equals(topoh7e1)); // Verifica el toponimo
      expect(firstLocationh7e1.getAlias(),
          equals(alias1h7e1)); // Verifica el alias

      // Verificar que los valores del segundo lugar son los esperados
      expect((secondLocationh7e1.getCoordinate().getLat - lat2).abs() < 0.001,
          equals(true)); // Verifica la latitud
      expect((secondLocationh7e1.getCoordinate().getLong - long2).abs() < 0.001,
          equals(true)); // Verifica la longitud
      expect(secondLocationh7e1.getToponym(),
          equals(topo2)); // Verifica el toponimo
      expect(
          secondLocationh7e1.getAlias(), equals(alias2)); // Verifica el alias
      expect((secondLocationh7e1.getCoordinate().getLat - lat2).abs() < 0.001,
          equals(true)); // Verifica la latitud
      expect((secondLocationh7e1.getCoordinate().getLong - long2).abs() < 0.001,
          equals(true)); // Verifica la longitud
      expect(secondLocationh7e1.getToponym(),
          equals(topo2)); // Verifica el toponimo
      expect(
          secondLocationh7e1.getAlias(), equals(alias2)); // Verifica el alias

      await signInAndDeleteUser(emailh7e1, passwordh7e1);
      await deleteLocation(alias1h7e1);
      await deleteLocation(alias2);
    });

    test('H7-E3I - Listar lugares inválida porque no hay usuario autenticado',
        () async {
      //GIVEN

    test('H7-E3I - Listar lugares inválida porque no hay usuario autenticado',
        () async {
      //GIVEN

      //THEN

      /*
          expect(
        () async => await locationController.getLocationList(),
        throwsA(isA<Exception>()),
        
      );
      */
    });

//Empieza H8
    test('H8-E1V - Eliminar lugar de interés', () async {
      //GIVEN

      //Loguear usuario
      String emailh8e1 =
          "Pruebah8e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh8e1 = "Aaaaa,.8";
      String nameh8e1 = "Pruebah8e1";
      await userAppController.createUser(emailh8e1, passwordh8e1, nameh8e1);

      await userAppController.logInCredenciales(emailh8e1, passwordh8e1);

      locationController = LocationController(
          FirestoreAdapterLocation(collectionName: "testCollection"));

      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      Location location1 = await locationController.createLocationFromCoord(lat1, long1, apodo1);

      await locationController.deleteLocation(location1);

      //THEN

      final Set<Location> location = await locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationListh8e1 = location.toList();

      expect(
          locationListh8e1.length, equals(0)); // Verifica que no hay locations en lista
      //borrado de los tests para que no de problemas luego
      await signInAndDeleteUser(emailh8e1, passwordh8e1);
      await deleteLocation(apodo1);
    });

    test('H8-E3I - Eliminar ruta inválida, usuario no registrado', () async {
      //GIVEN
      //Loguear usuario
      String emailh8e3 =
          "Pruebah8e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh8e3 = "Aaaaa,.8";
      String nameh8e3 = "Pruebah8e3";
      await userAppController.createUser(emailh8e3, passwordh8e3, nameh8e3);

      await userAppController.logInCredenciales(emailh8e3, passwordh8e3);

      locationController = LocationController(FirestoreAdapterLocation(collectionName: "testCollection"));

      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      Location location1 =await locationController.createLocationFromCoord(lat1, long1, apodo1);

      await locationController.deleteLocation(location1);
      
      await signInAndDeleteUser(emailh8e3, passwordh8e3);

      //THEN
      expect(
        () async => await locationController.deleteLocation(location1),
        throwsA(isA<Exception>()),
      );

      await deleteLocation(apodo1);
    });
  });
}
