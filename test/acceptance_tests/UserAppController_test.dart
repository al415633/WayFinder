import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
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

  group('UserAppController Test', () {
    late DbAdapterUserApp adapter;
    late UserAppController userAppController;

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

  


    setUp(() async {
      adapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(adapter);
    });

 

tearDown(() async {


FirebaseAuth.instance.authStateChanges().listen((User? user) async {
  try {
    if (user != null) {
      // Si ya hay un usurio borro documnetos testCollection
      var collectionRef = FirebaseFirestore.instance.collection('testCollection');
      var querySnapshot = await collectionRef.get(); 

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); 
      }

      // Eliminar el usuario
      await user.delete();
      print('Usuario y documentos eliminados con éxito.');

    } else {
      // Si el usuario no está autenticado, intentar iniciar sesión
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "ana@gmail.com",
        password: "Aaaaa,.8", 
      );

      // Eliminar todos los documentos de la colección testCollection
      var collectionRef = FirebaseFirestore.instance.collection('testCollection');
      var querySnapshot = await collectionRef.get(); 

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); // Eliminar cada documento
      }

      // Eliminar el usuario
      await userCredential.user!.delete();
      print('Usuario y documentos eliminados con éxito.');
    }
  } catch (e) {
    print('Error durante la autenticación o eliminación: $e');
  }
});
});

 
  



   
    test('H1-E1V - Guardar Datos Usuario', () async {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      String name = "Ana";

      // WHEN
      UserApp? userApp = await userAppController.createUser(email, password, name);

      // THEN
      expect(userApp, isNotNull);
      expect(userApp?.email, equals(email));
    });




    test('H1-E2I - Password no cumple reglas de negocio', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "1";
      String name = "Ana";
      // WHEN
      Future<void> action() async {
        await userAppController.createUser(email, password, name);
      }
      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });





    test('H2-E2V - Permite Iniciar Sesión', () async {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
       String name = "Ana";

      UserApp? userApp = await userAppController.createUser(email, password, name) ;

      // WHEN
      userApp = userAppController.logInCredenciales(email, password);

      // THEN
      expect(userApp, isNotNull);
      expect(userApp?.email, equals(email));
    });





    test('H2-E3I - No permite Iniciar Sesión por password inválido', () {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
       String name = "Ana";

      userAppController.createUser(email, password, name);

      // WHEN
      void action() {
        userAppController.logInCredenciales(email, "aaaaaaaaaaaa");
      }

      // THEN
      expect(action, throwsA(isA<IncorrectPasswordException>()));
    });



    test('H3-E1V - Cerrar sesion valido', () async {
      // GIVEN
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
       String name = "Ana";

      UserApp? userApp = await userAppController.createUser(email, password, name);
      userAppController.logInCredenciales(email, password);

      // WHEN
    
      UserApp? cerrado= userAppController.logOut(userApp!);
      

      // THEN
      expect(cerrado, isNotNull);
    });


    test('H3-E4I - Cerrar sesion sin conexion a la BBDD', () async {
      // GIVEN
      adapter = FirestoreAdapterUserApp(collectionName: "No conexion");
      userAppController = UserAppController(adapter);
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
       String name = "Ana";

      UserApp? userApp = await userAppController.createUser(email, password, name) ;
      userAppController.logInCredenciales(email, password);

      // WHEN
      
      UserApp? cerrado;
      void action() {
      cerrado= userAppController.logOut(userApp!) ;
      }

      // THEN
      expect(cerrado, isNull);
      expect(action, throwsA(isA<ConnectionBBDDException>()));
    });



  });
}

