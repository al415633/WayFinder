// precio_luz_service_acceptance_test.dart

import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/User.dart';
import 'package:WayFinder/viewModel/UserService.dart';
import 'package:WayFinder/viewModel/controladorRuta.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:WayFinder/model/ruta.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R4: Gestión de rutas', () {

    late DbAdapterRuta adapterRuta;
    late ControladorRuta controladorRuta;

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
          measurementId: "G-TZLW8P5J8V"
        ),
      );
    });

    setUp(() async {
      adapterRuta = FirestoreAdapterRuta(collectionName: "testCollection");
      controladorRuta = ControladorRuta(adapterRuta);
      

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
      UserService userService=UserService(adapter);
      User? user = userService.createUser(email, password);
      user = userService.logIn(user!);


    //WHEN 
      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Lugar ini = Lugar(lat1, long1, apodo1);
      Lugar fin = Lugar(lat2, long2, apodo2);

      Ruta? ruta = controladorRuta.crearRuta(ini, fin, "a pie", "rápida");
      Future<bool> guardado = controladorRuta.guardarRuta(ruta!);

      expect(ruta.getInicio(), equals(ini)); // Verifica el Lugar inicial
      expect(ruta.getFin, equals(fin)); // Verifica el Lugar final
      expect(guardado, true);

    });


      test('H17E2', () async {
      //GIVEN 
      adapterRuta = FirestoreAdapterRuta(collectionName: "No conexion") ;
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      DbAdapterUser adapter = FirestoreAdapterUser(collectionName: "No conexion");
      UserService userService=UserService(adapter);
      User? user = userService.createUser(email, password);
      user = userService.logIn(user!);


    //WHEN 
      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Lugar ini = Lugar(lat1, long1, apodo1);
      Lugar fin = Lugar(lat2, long2, apodo2);
    
      Ruta? ruta;
      bool guardado=false;
     void action() {
      ruta = controladorRuta.crearRuta(ini, fin, "a pie", "rápida");
      guardado = controladorRuta.guardarRuta(ruta!) as bool;
     }
      
      expect(action, throwsA(isA<ConnectionBBDDException>()));
      expect(ruta?.getInicio(), isNull); 
      expect(ruta?.getFin, isNull); 
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
      Lugar ini = Lugar(lat1, long1, apodo1);
      Lugar fin = Lugar(lat2, long2, apodo2);

      controladorRuta.crearRuta(ini, fin, "a pie", "rápida");


      //THEN

      final Set<Ruta> rutas = controladorRuta.getListaRutas();

      // Convertir el set a una lista para acceder al primer elemento
      final listaRutas = rutas.toList();
      
      // Acceder al primer objeto en la lista
      final primeraRuta = listaRutas[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primeraRuta.getInicio(), equals(ini)); // Verifica el Lugar inicial
      expect(primeraRuta.getFin, equals(fin)); // Verifica el Lugar final
      expect(primeraRuta.getDistancia(), equals(0)); // Verifica la distancia calculada
      expect(primeraRuta.getPoints(), equals(List<Coordenada>)); // Verifica la lista de puntos
      expect(primeraRuta.getModoTransporte(), equals("a pie")); // Verifica el modo de Transporte
      expect(primeraRuta.getModoRuta(), equals("rápida")); // Verifica el modo de Transporte



      
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
      Lugar ini = Lugar(lat1, long1, apodo1);
      Lugar fin = Lugar(lat2, long2, apodo2);

      controladorRuta.crearRuta(ini, fin, "a pie", "rápida");


      //THEN
     expect(() {
      controladorRuta.getListaRutas();
    }, throwsException);




      
    });
   

    test('H19', () async {
      
    });
   
  });
}
