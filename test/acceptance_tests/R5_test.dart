// precio_luz_service_acceptance_test.dart
import 'package:WayFinder/model/User.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/UserController.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R5: Gestión de preferencias', () {

    late DbAdapterLocation adapterLocation;
    late LocationController locationController;


    late DbAdapterUser adapterUser;
    late UserController userController;

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
      adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      adapterUser = FirestoreAdapterUser(collectionName: "testCollection");
      userController = UserController(adapterUser);
      

    });

    test('H20-EV', () async {

      //GIVEN --> aquí habria que mirar si generamos un usuario por defecto y solo logIn
      //creamos cuenta al usuario
      String email = "belen@gmail.com";
      String password = "HolaAAAAA%1";
      User? user =  userController.createUser(email, password);

      //Loguear usuario
      userController.logIn(user!);


      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      await locationController.createLocationFromCoord(lat1, long1, apodo1);
      locationController.addFav("Castelló de la Plana", apodo1);


      //THEN

      final Set<Location> locations = await locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationList = locations.toList();
      
      // Acceder al primer objeto en la lista
      final primerLugar = locationList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primerLugar.getFav(), equals(true)); // Verifica el Lugar inicial
     
      


    });


    test('H20-EI', () async {

          //GIVEN --> aquí habria que mirar si generamos un usuario por defecto y solo logIn
      //creamos cuenta al usuario
      String email = "belen@gmail.com";
      String password = "HolaAAAAA%1";
      User? user =  userController.createUser(email, password);

      //Loguear usuario
      userController.logIn(user!);



      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      await locationController.createLocationFromCoord(lat1, long1, apodo1);

      //THEN
     
     expect(() {
      locationController.addFav("Castelló de la Plana", apodo1);
    }, throwsException);


     

    });


    test('H21-EV', () async {
     
    });


    test('H21-EI', () async {
      
    });


    test('H22-EV', () async {
      
    });
   

    test('H22-EI', () async {
      
    });
   
    
   
  });
}
