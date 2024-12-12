// precio_luz_service_acceptance_test.dart
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R6:Persistencia de los contenidos de la aplicación', () {
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

      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController.getInstance(adapterLocation);

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

    test('H23-E1V', () async {
      //TEST PERSISTENCIA

      //GIVEN
      String email =
          "Pruebah23${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Pruebah23";
      await userAppController.createUser(email, password, name);
      userApp = await userAppController.logInCredenciales(email, password);

      final double lat = 39.98567;
      final double long = -0.04935;
      final String alias = "castellon";

      Location location =
          await locationController.createLocationFromCoord(lat, long, alias);

      await userAppController.logOut();

      //WHEN

      userApp = await userAppController.logInCredenciales(email, password);

      //THEN

      final locationList = await locationController.getLocationList();
      expect(locationList.contains(location), true);
    });
  });
}
