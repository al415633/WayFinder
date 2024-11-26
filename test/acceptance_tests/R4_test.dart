// precio_luz_ContUserController_acceptance_test.dart

import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/Route.dart';
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

    late DbAdapterUserApp userAppAdapter;
    late UserAppController userAppController;

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


      //GIVEN

      //Loguear usuario
      String email = "isabel@gmail.com";
      String password = "Iaaaa,.8";
      String nameU = "Isa";

      Future<UserApp?> user = userAppController.createUser(email, password, nameU);
      user = userAppController.logInCredenciales(email, password);

    });

    setUp(() async {
      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController(adapterRoute);

      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(userAppAdapter);
      

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
                email: "isabel@gmail.com",
                password: "Iaaaa,.8", 
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

    test('H13-E1V - Crear ruta', () async {

      //GIVEN

      //Loguear usuario

      //Hecho en el setUpAll
      


      //WHEN
      
     final double lat1 = 39.98567;
     final double long1 = -0.04935;
     final String apodo1 = "castellon";


     final double lat2 = 39.8890;
     final double long2 = -0.08499;
     final String apodo2 = "burriana";
     Location ini = Location(lat1, long1, apodo1);
     Location fin = Location(lat2, long2, apodo2);


     Route? route = routeController.createRoute(ini, fin, "a pie", "rápida");
  


      //THEN
     expect(route?.getStart(), equals(ini)); // Verifica el Location inicial
     expect(route?.getEnd(), equals(fin)); // Verifica el Location final

      


    });


    test('H13-E2I - Crear ruta inválido no hay conexión BBDD', () async {

      //GIVEN
      //Loguear usuario

      //Hecho en el setUpAll


      //WHEN
      
     final double lat1 = 39.98567;
     final double long1 = -0.04935;
     final String apodo1 = "castellon";


     final double lat2 = 39.8890;
     final double long2 = -0.08499;
     final String apodo2 = "burriana";
     Location ini = Location(lat1, long1, apodo1);
     Location fin = Location(lat2, long2, apodo2);


    Route? route;
      void action() {

     route = routeController.createRoute(ini, fin, "a pie", "rápida");
  
      }

      //THEN
     
    expect(action, throwsA(isA<ConnectionBBDDException>()));
      expect(route?.getStart(), equals(isNull)); // Verifica el Location inicial
     expect(route?.getEnd(), equals(isNull)); // Verifica el Location final

     

    });


    test('H14', () async {
     
    });


    test('H15', () async {
      
    });


    test('H16', () async {
      
    });
   


   

    test('H19', () async {
      
    });
   
  });
}
