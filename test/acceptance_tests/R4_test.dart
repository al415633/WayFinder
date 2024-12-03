// precio_luz_ContUserController_acceptance_test.dart

import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R4: Gestión de Routes', () {

    late DbAdapterRoute adapterRoute;
    late RouteController routeController;

    late DbAdapterLocation adapterLocation;
    late LocationController locationController;

    late DbAdapterUserApp userAppAdapter;
    late UserAppController userAppController;

    late FirebaseAuth auth;
    late UserApp? userApp;

   setUpAll(() async {
      // Inicializar el entorno de pruebas

      // no se si hace falta el test delante
      TestWidgetsFlutterBinding.ensureInitialized();

      // Cargar la configuración desde firebase_config.json

      //google ContUserControllerds
      

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

      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);

      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(userAppAdapter);

      adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

       // Crear usuario de prueba
      const email = "pruebaR4@gmail.com";
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
        var collectionRef = FirebaseFirestore.instance.collection('testCollection');
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


      Future<void> deleteRoute(String name) async {
        var collectionRef = FirebaseFirestore.instance.collection('testCollection');
        var querySnapshot = await collectionRef.where('name', isEqualTo: name).get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
        routeController.routeList = Future.value(<Routes>{});
      }

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


    test('H13-E1V - Crear ruta', () async {

      //GIVEN

      //Loguear usuario
      String emailh13e1 = "Pruebah13e1@gmail.com";
      String passwordh13e1 = "Aaaaa,.8";
      String nameh13e1="Pruebah13e1";
      await userAppController.createUser(emailh13e1, passwordh13e1, nameh13e1);

      userApp = await userAppController.logInCredenciales(emailh13e1, passwordh13e1);

      //WHEN
      
     final double lat1 = 39.98567;
     final double long1 = -0.04935;
     final String apodo1 = "castellon";


     final double lat2 = 39.8890;
     final double long2 = -0.08499;
     final String apodo2 = "burriana";
     Location ini = await locationController.createLocationFromCoord(lat1, long1, apodo1);
     Location fin = await locationController.createLocationFromCoord(lat2, long2, apodo2);

     String name1 = "ruta 1";


     Routes firstRouteh13e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida);
  

      //THEN
     expect(firstRouteh13e1.getStart, equals(ini)); // Verifica el Location inicial
     expect(firstRouteh13e1.getEnd, equals(fin)); // Verifica el Location final

     await signInAndDeleteUser(emailh13e1, passwordh13e1);
     await deleteRoute(name1);




    });


    test('H13-E2I - Crear ruta inválido no hay conexión BBDD', () async {

/*
      //GIVEN
      //Loguear usuario
      String emailh13e2 = "Pruebah13e2@gmail.com";
      String passwordh13e2 = "Aaaaa,.8";
      String nameh13e2="Pruebah13e2";
      await userAppController.createUser(emailh13e2, passwordh13e2, nameh13e2);

      userApp = await userAppController.logInCredenciales(emailh13e2, passwordh13e2);


      //WHEN
      
     final double lat1 = 39.98567;
     final double long1 = -0.04935;
     final String apodo1 = "castellon";


     final double lat2 = 39.8890;
     final double long2 = -0.08499;
     final String apodo2 = "burriana";
     Location ini = Location(lat1, long1, apodo1);
     Location fin = Location(lat2, long2, apodo2);

     String name1 = "ruta 1";


    Routes? firstRouteh13e2;
      void action() async {

     routeController.createRoute(name1, ini, fin, TransportMode.aPie, "rápida");


      final Set<Routes> routes =  await routeController.getRouteList();
      final routeListh13e1 = routes.toList();
      firstRouteh13e2 = routeListh13e1[0];
  
      }

      //THEN
     
     expect(action, throwsA(isA<ConnectionBBDDException>()));
     expect(firstRouteh13e2?.getStart(), equals(isNull)); // Verifica el Location inicial
     expect(firstRouteh13e2?.getEnd(), equals(isNull)); // Verifica el Location final

     await signInAndDeleteUser(emailh13e2, passwordh13e2);
     await _deleteRoute(name1);

     */


    });


    test('H14', () async {
     
    });


    test('H15', () async {
      
    });


    test('H16', () async {
      
    });
   


   
  test('H19-E1V - Eliminar ruta', () async {

    //GIVEN


    //Loguear usuario
    String emailh19e1 = "Pruebah19e1@gmail.com";
    String passwordh19e1 = "Aaaaa,.8";
    String nameh19e1="Pruebah19e1";
    await userAppController.createUser(emailh19e1, passwordh19e1, nameh19e1);

    userApp = await userAppController.logInCredenciales(emailh19e1, passwordh19e1);


    //WHEN
  
   final double lat1 = 39.98567;
   final double long1 = -0.04935;
   final String apodo1 = "castellon";

   final double lat2 = 39.8890;
   final double long2 = -0.08499;
   final String apodo2 = "burriana";
   Location ini = await locationController.createLocationFromCoord(lat1, long1, apodo1);
   Location fin = await locationController.createLocationFromCoord(lat2, long2, apodo2);

   String name1 = "ruta 1";

   Routes firstRouteh19e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida);
   bool success = await routeController.saveRoute(firstRouteh19e1);
   Routes routeResult = await routeController.deleteRoute(firstRouteh19e1);


   //THEN

   final Set<Routes> route = await routeController.getRouteList();

   // Convertir el set a una lista para acceder al primer elemento
   final routeListh19e1 = route.toList();
  
   expect(routeListh19e1.length, equals(0)); // Verifica el Location inicial


   await signInAndDeleteUser(emailh19e1, passwordh19e1);
   await deleteRoute(name1);


  });








  test('H19-E4I - Eliminar ruta inválida, usuario no registrado', () async {




    //GIVEN
    // no registramos usuario


    //WHEN

   final double lat1 = 39.98567;
   final double long1 = -0.04935;
   final String apodo1 = "castellon";

   final double lat2 = 39.8890;
   final double long2 = -0.08499;
   final String apodo2 = "burriana";
   Location ini = await locationController.createLocationFromCoord(lat1, long1, apodo1);
   Location fin = await locationController.createLocationFromCoord(lat2, long2, apodo2);

   String name1 = "ruta 1";

   Routes firstRouteh19e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida);


   //THEN
   expect(
       () async => await routeController.deleteRoute(firstRouteh19e1),
       throwsA(isA<Exception>()),
   );


  });



   
  });
}
