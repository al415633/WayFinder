
import 'dart:ffi';

import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';

import 'package:WayFinder/viewModel/UserService.dart';
import 'package:WayFinder/model/User.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserService Test', () {
    late DbAdapterUser adapter;
    late UserService userService;

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

      userService = UserService(adapter);
    });

   
    test('H1E1 - Guardar Datos Usuario', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      // WHEN
      User? user = userService.createUser(email, password);

      // THEN
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });




    test('H1E2 - Password no cumple reglas de negocio', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "1";

      // WHEN
      void action() {
        userService.createUser(email, password);
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });





    test('H2E2 - Permite Iniciar Sesión', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userService.createUser(email, password);

      // WHEN
      user = userService.logInCredenciales(email, password);

      // THEN
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });





    test('H2E3 - No permite Iniciar Sesión por password inválido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userService.createUser(email, password);

      // WHEN
      void action() {
        userService.logInCredenciales(email, "aaaaaaaaaaaa");
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });



    test('H3E1 - Cerrar sesion valido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userService.createUser(email, password);
      userService.logIn(user!);

      // WHEN
    
      User? cerrado= userService.logOut(user) ;
      

      // THEN
      expect(cerrado, isNotNull);
    });


    test('H3E4 - Cerrar sesion sin conexion a la BBDD', () {
      // GIVEN
       adapter = FirestoreAdapterUser(collectionName: "No conexion");
      userService = UserService(adapter);
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      User? user = userService.createUser(email, password);
      userService.logIn(user!);

      // WHEN
      
      User? cerrado;
      void action() {
      cerrado= userService.logOut(user) ;
      }

      // THEN
      expect(cerrado, isNull);
      expect(action, throwsA(isA<ConnectionBBDDException>()));
    });



  });
}