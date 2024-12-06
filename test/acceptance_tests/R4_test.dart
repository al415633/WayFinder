// precio_luz_ContUserController_acceptance_test.dart

import 'package:WayFinder/exceptions/IncorrectCalculationException.dart';
import 'package:WayFinder/exceptions/InvalidCalorieCalculationException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';

import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
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

    late DbAdapterVehicle adapterVehicle;
    late VehicleController vehicleController;
   
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
            measurementId: "G-TZLW8P5J8V"),
      );

      
      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollectionR4");
      userAppController = UserAppController(userAppAdapter);

  

 
    });

       Future<void> deleteVehicle(String numberPlate) async {
  var collectionRef = FirebaseFirestore.instance.collection('testCollectionR4');
  var querySnapshot = await collectionRef.where('numberPlate', isEqualTo: numberPlate).get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
  vehicleController.vehicleList = Future.value(<Vehicle>{});
 }


    tearDownAll(() async {
      // Borrar todos los documentos de testCollection
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollectionR4');
      var querySnapshot = await collectionRef.get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

    });

    Future<void> deleteRoute(String name) async {
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollectionR4');
      var querySnapshot =
          await collectionRef.where('name', isEqualTo: name).get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      routeController.routeList = Future.value(<Routes>{});
    }

    // Helper para limpiar la colección y eliminar usuario
    Future<void> cleanUp() async {
      var collectionRef =
          FirebaseFirestore.instance.collection('testCollectionR4');
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

    test('H13-E1V - Crear ruta', () async {
      //GIVEN

      //Loguear usuario
      String emailh13e1 = "Pruebah13e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";
      String passwordh13e1 = "Aaaaa,.8";
      String nameh13e1 = "Pruebah13e1";
      await userAppController.createUser(emailh13e1, passwordh13e1, nameh13e1);

      userApp = await userAppController.logInCredenciales(emailh13e1, passwordh13e1);


      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);

      adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);
      
      adapterVehicle = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(adapterVehicle);

      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Location ini =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);
      Location fin =
          await locationController.createLocationFromCoord(lat2, long2, apodo2);

      String name1 = "ruta 1";

      Routes firstRouteh13e1 = await routeController.createRoute(
          name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);

      //THEN
      expect(firstRouteh13e1.getStart,
          equals(ini)); // Verifica el Location inicial
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

      test('H14 - E1V Precio de una ruta', () async {
      //GIVEN
      //Loguear usuario
      String email = "Pruebah14e1@gmail.com";
      String password = "Aaaaa,.8";


      userApp = await userAppController.logInCredenciales(email, password);
      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);


      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);


      adapterVehicle =
          FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(adapterVehicle);


      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";


      Location ini =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);
      Location fin =
          await locationController.createLocationFromCoord(lat2, long2, apodo2);


      String name1 = "Ruta h14 e 1";


      Routes ruta = await routeController.createRoute(
          name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);


      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = 'Eléctrico';


      await vehicleController.createVehicle(
          numberPlate, consumption, fuelType, namec);


      Set<Vehicle> vehicleList = await vehicleController.getVehicleList();
      Vehicle? vehiculo = vehicleList.first;

      //WHEN
      double coste = await vehicleController.calculatePrice(ruta, vehiculo);
      expect(coste, isNotNull);
      expect(coste, inExclusiveRange(0.20, 2.3));

      //THEN
      await deleteVehicle(numberPlate);
      await userAppController.logOut();
    });


    test('H14 - E2I Precio de una Ruta calculada incorrectamente', () async {
      // GIVEN
      // Loguear usuario
      String email = "Pruebah14e2@gmail.com";
      String password = "Aaaaa,.8";


      userApp = await userAppController.logInCredenciales(email, password);
      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);


      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);


      adapterVehicle =
          FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(adapterVehicle);


      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";


      Location ini =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);
      Location fin =
          await locationController.createLocationFromCoord(lat2, long2, apodo2);

      Routes? ruta=null;


      String name1 = "Ruta h14 e 1";


      final String numberPlate = "DKR9997";


      // WHEN
      Future<void> action() async {
        final String namec = "Coche Quiqee";
        final double consumption = 24.3;
        final String fuelType = "Gasolina";
        Vehicle vehiculo = Vehicle(fuelType, consumption, numberPlate, namec);


        double coste = await vehicleController.calculatePrice(ruta, vehiculo);
      }


      // THEN
      expect(() async => await action(),
          throwsA(isA<Incorrectcalculationexception>()));
      await deleteVehicle(numberPlate);
      await userAppController.logOut();
    });


    test('H15 - E1V', () async {
      //GIVEN
      //Loguear usuario
      String email = "Pruebah15e1@gmail.com";
      String password = "Aaaaa,.8";


      userApp = await userAppController.logInCredenciales(email, password);


      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);


      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);


      adapterVehicle =
          FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(adapterVehicle);


      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final Coordinate coord1 = Coordinate(lat1, long1);
      final String toponym1 = "Castellón de la Plana";
      final String apodo1 = "castellon";


      Location ini =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);


      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String toponym2 = "Burriana";
      final String apodo2 = "burriana";


      Location fin =
          await locationController.createLocationFromCoord(lat2, long2, apodo2);


      String name1 = "Ruta h15 e1";


      Routes ruta = await routeController.createRoute(
          name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
      double coste = 0;
      //WHEN
      coste = routeController.calculateCostKCal(ruta);


      //THEN
      expect(coste, 645.05); // Verifica el Location inicial
    });


    test('H15 - E3I', () async {
      //GIVEN
      //Loguear usuario
      String email = "Pruebah15e3@gmail.com";
      String password = "Aaaaa,.8";


      userApp = await userAppController.logInCredenciales(email, password);


      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController.getInstance(adapterRoute);


      adapterLocation =
          FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);


      adapterVehicle =
          FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(adapterVehicle);


      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      Location ini =
          await locationController.createLocationFromCoord(lat1, long1, apodo1);


      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";


      Location fin =
          await locationController.createLocationFromCoord(lat2, long2, apodo2);


      String name1 = "Ruta h15 e3";
      Routes? ruta;


      double coste = 0;


      //WHEN
      void action() async {
        coste = routeController.calculateCostKCal(ruta);
      }


      //THEN


      expect(() async => action(),
          throwsA(isA<Invalidcaloriecalculationexception>()));
      //Crear excepcion IncorrectCalculationException
    });



    test('H16', () async {
      
    });
   

  test('H17-E1V - Guardar ruta', () async {

      //GIVEN

      //Loguear usuario
      String emailh17e1 = "Pruebah17e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";      
      String passwordh17e1 = "Aaaaa,.8";
      String nameh17e1="Pruebah17e1";
      await userAppController.createUser(emailh17e1, passwordh17e1, nameh17e1);

      userApp = await userAppController.logInCredenciales(emailh17e1, passwordh17e1);


      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController(adapterRoute);

      adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);
      


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


      Routes firstRouteh17e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
      bool success = await routeController.saveRoute(firstRouteh17e1);


      //THEN


      final Set<Routes> route = await routeController.getRouteList();


      // Convertir el set a una lista para acceder al primer elemento
      final routeListh17e1 = route.toList();
      
      // Acceder al primer objeto en la lista
      final routeh17e1 = routeListh17e1[0];
      expect(success, equals(true)); 
      expect(routeh17e1.getStart, equals(ini)); // Verifica el Location inicial
      expect(routeh17e1.getEnd, equals(fin)); // Verifica el Location final


      await signInAndDeleteUser(emailh17e1, passwordh17e1);
      await deleteRoute(name1);


   });




   test('H17-E3I - Guardar ruta inválido, usuario no registrado', () async {


     //GIVEN

    //Loguear usuario
    String emailh17e3 = "Pruebah17e3${DateTime.now().millisecondsSinceEpoch}@gmail.com";      
    String passwordh17e3 = "Aaaaa,.8";
    String nameh17e3="Pruebah17e3";
    await userAppController.createUser(emailh17e3, passwordh17e3, nameh17e3);

    userApp = await userAppController.logInCredenciales(emailh17e3, passwordh17e3);


    adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
    routeController = RouteController(adapterRoute);

    adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
    locationController = LocationController(adapterLocation);
      



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


    Routes firstRouteh17e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
      
    await signInAndDeleteUser(emailh17e3, passwordh17e3); 

    //THEN

     expect(
       () async => await routeController.saveRoute(firstRouteh17e1),
       throwsA(isA<Exception>()),
      
     );


   });



   test('H18-E1V - Listar rutas', () async {


     //GIVEN


     //Loguear usuario
    String emailh18e1 = "Pruebah18e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";      
    String passwordh18e1 = "Aaaaa,.8";
    String nameh18e1="Pruebah18e1";
    await userAppController.createUser(emailh18e1, passwordh18e1, nameh18e1);

    userApp = await userAppController.logInCredenciales(emailh18e1, passwordh18e1);
      
    adapterRoute = FirestoreAdapterRoute(collectionName: "testCollectionR4");
    routeController = RouteController(adapterRoute);

    adapterLocation = FirestoreAdapterLocation(collectionName: "testCollectionR4");
    locationController = LocationController(adapterLocation);
    
    adapterVehicle = FirestoreAdapterVehiculo(collectionName: "testCollectionR4");
    vehicleController = VehicleController(adapterVehicle);


    final double lat1 = 39.98567;
    final double long1 = -0.04935;
    final String apodo1 = "castellon";


    final double lat2 = 39.8890;
    final double long2 = -0.08499;
    final String apodo2 = "burriana";
    Location ini = await locationController.createLocationFromCoord(lat1, long1, apodo1);
    Location fin = await locationController.createLocationFromCoord(lat2, long2, apodo2);


    String name1 = "ruta 1";

    Routes firstRouteh18e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
    bool success = await routeController.saveRoute(firstRouteh18e1);


    //WHEN


    final Set<Routes> route = await routeController.getRouteList();
  

    //THEN


    // Convertir el set a una lista para acceder al primer elemento
    final locationListh18e1 = route.toList();
      
    // Acceder al primer objeto en la lista
    final firstRoute = locationListh18e1[0];


    expect(firstRoute.getStart, equals(ini)); // Verifica el Location inicial
    expect(firstRoute.getEnd, equals(fin)); // Verifica el Location final


    await signInAndDeleteUser(emailh18e1, passwordh18e1);
    await deleteRoute(name1);


   });



   test('H18-E3I - Listar rutas inválida, usuario no registrado', () async {

    /*


     //GIVEN
     // No registramos usuario    
     
    
    adapterRoute = FirestoreAdapterRoute(collectionName: "testCollectionR4");

     //WHEN
    

     //THEN

      Future<void> action() async {
      //await locationController.getLocationList();
      RouteController(adapterRoute);
      }

      // THEN
      expect(action(), throwsA(isA<Exception>()));

            */


      });




  test('H19-E1V - Eliminar ruta', () async {

  //GIVEN

 //Loguear usuario
    String emailh19e1 = "Pruebah19e1${DateTime.now().millisecondsSinceEpoch}@gmail.com";      
    String passwordh19e1 = "Aaaaa,.8";
    String nameh19e1="Pruebah19e1";
    await userAppController.createUser(emailh19e1, passwordh19e1, nameh19e1);

    userApp = await userAppController.logInCredenciales(emailh19e1, passwordh19e1);


    adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
    routeController = RouteController.getInstance(adapterRoute);

    adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
    locationController = LocationController(adapterLocation);
    
    adapterVehicle = FirestoreAdapterVehiculo(collectionName: "testCollection");
    vehicleController = VehicleController(adapterVehicle);

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

   Routes firstRouteh17e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
   bool success = await routeController.saveRoute(firstRouteh17e1);
   bool success2 = await routeController.deleteRoute(firstRouteh17e1);

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
    //Loguear usuario
    String emailh19e4 = "Pruebah19e4${DateTime.now().millisecondsSinceEpoch}@gmail.com";      
    String passwordh19e4 = "Aaaaa,.8";
    String nameh19e4="Pruebah19e4";
    await userAppController.createUser(emailh19e4, passwordh19e4, nameh19e4);

    userApp = await userAppController.logInCredenciales(emailh19e4, passwordh19e4);


    adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
    routeController = RouteController.getInstance(adapterRoute);

    adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
    locationController = LocationController(adapterLocation);
    
    adapterVehicle = FirestoreAdapterVehiculo(collectionName: "testCollection");
    vehicleController = VehicleController(adapterVehicle);

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

   Routes firstRouteh17e1 = await routeController.createRoute(name1, ini, fin, TransportMode.aPie, RouteMode.rapida, null);
   bool success = await routeController.saveRoute(firstRouteh17e1);
   bool success2 = await routeController.deleteRoute(firstRouteh17e1);

   await signInAndDeleteUser(emailh19e4, passwordh19e4);

   //THEN
   expect(
       () async => await routeController.deleteRoute(firstRouteh17e1),
       throwsA(isA<Exception>()),
   );


  });

  });
   
}
