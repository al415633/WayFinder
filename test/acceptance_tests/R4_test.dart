// precio_luz_ContUserController_acceptance_test.dart

import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/User.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/Route.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R4: Gestión de Routes', () {

    late DbAdapterRoute adapterRoute;
    late RouteController routeController;

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
    });

    setUp(() async {
      adapterRoute = FirestoreAdapterRoute(collectionName: "testCollection");
      routeController = RouteController(adapterRoute);
      

    });

    test('H13-EV', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

  


      //THEN

      


    });


    test('H13-EI', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      


      //THEN

     

    });


    test('H14', () async {
     
    });


    test('H15', () async {
      
    });


    test('H16', () async {
      
    });
   

    test('H17E1', () async {
      //GIVEN 
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      DbAdapterUser adapter = FirestoreAdapterUser(collectionName: "testCollection");
      UserController userController=UserController(adapter);
      User? user = userController.createUser(email, password);
      user = userController.logIn(user!);


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
      Future<bool> guardado = routeController.saveRoute(route!);

      expect(route.getStart(), equals(ini)); // Verifica el Location inicial
      expect(route.getEnd(), equals(fin)); // Verifica el Location final
      expect(guardado, true);

    });


      test('H17E2', () async {
      //GIVEN 
      adapterRoute = FirestoreAdapterRoute(collectionName: "No conexion") ;
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      DbAdapterUser adapter = FirestoreAdapterUser(collectionName: "No conexion");
      UserController userController=UserController(adapter);
      User? user = userController.createUser(email, password);
      user = userController.logIn(user!);

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
      bool guardado=false;
     void action() {
      route = routeController.createRoute(ini, fin, "a pie", "rápida");
      guardado = routeController.saveRoute(route!) as bool;
     }
      
      expect(action, throwsA(isA<ConnectionBBDDException>()));
      expect(route?.getStart(), isNull); 
      expect(route?.getEnd, isNull); 
      expect(guardado, false);

    });
   
    test('H18-EV', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Location ini = Location(lat1, long1, apodo1);
      Location fin = Location(lat2, long2, apodo2);

      routeController.createRoute(ini, fin, "a pie", "rápida");


      //THEN

      final Set<Route> route = routeController.getRouteList();

      // Convertir el set a una lista para acceder al primer elemento
      final routeList = route.toList();
      
      // Acceder al primer objeto en la lista
      final primeraRoute = routeList[0];

      // Verificar que los valores del primer Location son los esperados
      expect(primeraRoute.getStart(), equals(ini)); // Verifica el Location inicial
      expect(primeraRoute.getEnd, equals(fin)); // Verifica el Location final
      expect(primeraRoute.getDistance(), equals(0)); // Verifica la distancia calculada
      expect(primeraRoute.getPoints(), equals(List<Coordinate>)); // Verifica la lista de puntos
      expect(primeraRoute.getTransportMode(), equals("a pie")); // Verifica el modo de Transporte
      expect(primeraRoute.getRouteMode(), equals("rápida")); // Verifica el modo de Transporte



      
    });


    test('H18-EI', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Location ini = Location(lat1, long1, apodo1);
      Location fin = Location(lat2, long2, apodo2);

      routeController.createRoute(ini, fin, "a pie", "rápida");


      //THEN
     expect(() {
      routeController.getRouteList();
    }, throwsException);

    });
   

    test('H19', () async {
      
    });
   
  });
}
