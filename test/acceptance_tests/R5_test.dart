// precio_luz_service_acceptance_test.dart
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R5: Gestión de preferencias', () {

    late DbAdapterLocation adapterLocation;
    late LocationController locationController;


    late DbAdapterUserApp adapterUserApp;
    late UserAppController userAppController;

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

       //GIVEN

      //Loguear usuario
      String email = "isabel@gmail.com";
      String password = "Iaaaa,.8";
      String nameU = "Isa";

      Future<UserApp?> user = userAppController.createUser(email, password, nameU);
      user = userAppController.logInCredenciales(email, password);
    });

    setUp(() async {
      adapterLocation = FirestoreAdapterLocation(collectionName: "testCollection");
      locationController = LocationController(adapterLocation);

      adapterUserApp = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(adapterUserApp);
      

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

    test('H20-E1V - Marcar como favorito un lugar', () async {

      //GIVEN 
      //Hecho en el SetUpAll


      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      await locationController.createLocationFromCoord(lat1, long1, apodo1);
      locationController.addFav("Castelló de la Plana", apodo1);


      //THEN

      final Set<Location> locations = locationController.getLocationList();

      // Convertir el set a una lista para acceder al primer elemento
      final locationList = locations.toList();
      
      // Acceder al primer objeto en la lista
      final primerLugar = locationList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primerLugar.getFav(), equals(true)); // Verifica el Lugar inicial
     
      


    });


    test('H20-E2I - Marcar como favorito un lugar inválido', () async {

      //GIVEN 
      //Hecho en el SetUpAll




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
