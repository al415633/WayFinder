
import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';

import 'package:WayFinder/viewModel/UserController.dart';
import 'package:WayFinder/model/User.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserController Test', () {
    late DbAdapterUser adapter;
    late UserController userController;

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
      adapter = FirestoreAdapterUser(collectionName: "testCollection");

      userController = UserController(adapter);
    });

   
    test('H1-E1V - Guardar Datos Usuario', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      // WHEN
      User? user = userController.createUser(email, password);

      // THEN
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });




    test('H1-E2I - Password no cumple reglas de negocio', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "1";

      // WHEN
      void action() {
        userController.createUser(email, password);
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });





    test('H2-E2V - Permite Iniciar Sesión', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userController.createUser(email, password);

      // WHEN
      user = userController.logInCredenciales(email, password);

      // THEN
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });





    test('H2-E3I - No permite Iniciar Sesión por password inválido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      userController.createUser(email, password);

      // WHEN
      void action() {
        userController.logInCredenciales(email, "aaaaaaaaaaaa");
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });



    test('H3-E1V - Cerrar sesion valido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userController.createUser(email, password);
      userController.logIn(user!);

      // WHEN
    
      User? cerrado= userController.logOut(user);
      

      // THEN
      expect(cerrado, isNotNull);
    });


    test('H3-E4I - Cerrar sesion sin conexion a la BBDD', () {
      // GIVEN
      adapter = FirestoreAdapterUser(collectionName: "No conexion");
      userController = UserController(adapter);
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userController.createUser(email, password);
      userController.logIn(user!);

      // WHEN
      
      User? cerrado;
      void action() {
      cerrado= userController.logOut(user) ;
      }

      // THEN
      expect(cerrado, isNull);
      expect(action, throwsA(isA<ConnectionBBDDException>()));
    });



  });
}
