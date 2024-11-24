
import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/UserApp.dart';

import 'package:WayFinder/viewModel/UserAppController.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AppUserAppController Test', () {
    late DbAdapterUserApp adapter;
    late UserAppController AppUserAppController;

    setUpAll(() async {
      // Inicializar Firebase
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
    });


    setUp(() {
      adapter = FirestoreAdapterUserApp(collectionName: "testCollection");

      AppUserAppController = UserAppController(adapter);
    });

   
    test('H1-E1V - Guardar Datos Usuario', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      // WHEN
      UserApp? AppUserApp = AppUserAppController.createUser(email, password);

      // THEN
      expect(AppUserApp, isNotNull);
      expect(AppUserApp?.email, equals(email));
    });




    test('H1-E2I - Password no cumple reglas de negocio', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "1";

      // WHEN
      void action() {
        AppUserAppController.createUser(email, password);
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });





    test('H2-E2V - Permite Iniciar Sesión', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? AppUserApp = AppUserAppController.createUser(email, password);

      // WHEN
      AppUserApp = AppUserAppController.logInCredenciales(email, password);

      // THEN
      expect(AppUserApp, isNotNull);
      expect(AppUserApp?.email, equals(email));
    });





    test('H2-E3I - No permite Iniciar Sesión por password inválido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      AppUserAppController.createUser(email, password);

      // WHEN
      void action() {
        AppUserAppController.logInCredenciales(email, "aaaaaaaaaaaa");
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });



    test('H3-E1V - Cerrar sesion valido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? AppUserApp = AppUserAppController.createUser(email, password);
      AppUserAppController.logIn(AppUserApp!);

      // WHEN
    
      UserApp? cerrado= AppUserAppController.logOut(AppUserApp);
      

      // THEN
      expect(cerrado, isNotNull);
    });


    test('H3-E4I - Cerrar sesion sin conexion a la BBDD', () {
      // GIVEN
      adapter = FirestoreAdapterUserApp(collectionName: "No conexion");
      AppUserAppController = UserAppController(adapter);
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      UserApp? AppUserApp = AppUserAppController.createUser(email, password);
      AppUserAppController.logIn(AppUserApp!);

      // WHEN
      
      UserApp? cerrado;
      void action() {
      cerrado= AppUserAppController.logOut(AppUserApp) ;
      }

      // THEN
      expect(cerrado, isNull);
      expect(action, throwsA(isA<ConnectionBBDDException>()));
    });



  });
}
