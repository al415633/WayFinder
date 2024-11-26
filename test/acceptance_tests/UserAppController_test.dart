import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  late FirebaseAuth auth;
  late UserAppController userAppController;
  late UserApp? userApp;

  // Helper para limpiar la colección y eliminar usuario
  Future<void> cleanUp() async {
    var collectionRef = FirebaseFirestore.instance.collection('testCollection');
    var querySnapshot = await collectionRef.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete(); 
    }
  }


  Future<UserApp?> signInAndDeleteUser(String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cleanUp();
    await userCredential.user!.delete();
    return null;
  }

  setUpAll(() async {
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
    final adapter = FirestoreAdapterUserApp(collectionName: "testCollection");
    userAppController = UserAppController(adapter);
  });

  group('UserAppController Test', () {
    test('H1-E1V - Guardar Datos Usuario', () async {
      // GIVEN
      String email = "pruebah1E1@gmail.com";
      String password = "Abbbbaa,.8";
      String name = "PruebaH1E1";

      // WHEN
      UserApp? newUserApp = await userAppController.createUser(email, password, name);

      // THEN
      expect(newUserApp, isNotNull);
      expect(newUserApp?.email, equals(email));

      await signInAndDeleteUser(email, password);
    });

    test('H1-E2I - Password no cumple reglas de negocio', () async {
      // GIVEN
      String email = "Pruebah1e2@gmail.com";
      String password = "1";
      String name = "Pruebah1e2";

      // WHEN
      Future<void> action() async {
        await userAppController.createUser(email, password, name);
      }

      // THEN
      expect(action(), throwsA(isA<IncorrectPasswordException>()));


    });

    test('H2-E2V - Permite Iniciar Sesión', () async {
      // GIVEN (realizado en setUpAll)
      String email = "Pruebah2e2@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah2e2";
      await userAppController.createUser(email, password, name);


      // WHEN
      userApp = await userAppController.logInCredenciales(email, password);

      // THEN
      expect(userApp, isNotNull);
      expect(userApp?.email, equals(email));
      
    
      await signInAndDeleteUser(email, password);


    });

    test('H2-E3I - No permite Iniciar Sesión por password inválido', () async {
      // GIVEN (realizado en setUpAll)
      
      String email = "Pruebah2e3@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah2e3";
      await userAppController.createUser(email, password, name);

      // WHEN
      Future<void> action() async {
        await userAppController.logInCredenciales(email, "aaaaaaaaaa");
      }

      // THEN
      expect(action(), throwsA(isA<IncorrectPasswordException>()));
      
      await signInAndDeleteUser(email, password);

    });

    test('H3-E1V - Cerrar sesion valido', () async {


      // GIVEN

      String email = "Pruebae3e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah3e1";
      await userAppController.createUser(email, password, name);

      // WHEN
      UserApp? closedSession = await userAppController.logOut(userApp!);

      // THEN
      expect(closedSession, isNotNull);

      await signInAndDeleteUser(email, password);

    });

    test('H3-E4I - Cerrar sesion sin conexion a la BBDD', () async {
      // GIVEN
 
      String email = "pruebah3e2@gmail.com";
      String password = "Aaaaacccccc,.8";
      String name = "pruebah3e2";

      await userAppController.createUser(email, password, name);
      //Pero no logeado

      // WHEN
       Future<void> action() async {
          await userAppController.logOut(null); 
        }

 
       expect(() async => await action(), throwsA(isA<UserNotAuthenticatedException>()));


      await signInAndDeleteUser(email, password);

    });
  });
}
