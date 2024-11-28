// precio_luz_service_acceptance_test.dart

import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R3: Gestión de vehículos', ()  {

    late DbAdapterVehiculo vehicleAdapter;
    late VehicleController vehicleController;


    late DbAdapterUserApp userAppAdapter;
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

      // Inicializar controladores
      vehicleAdapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(vehicleAdapter);

      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(userAppAdapter);

      // Crear usuario de prueba
      const email = "quique@gmail.com";
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

    tearDown(() async {
      var collectionRef = FirebaseFirestore.instance.collection('testCollection');
      var querySnapshot = await collectionRef.get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    });

    test('H9-E1V - Crear vehiculo', () async {

      //GIVEN

      //Loguear usuario
      //Hecho en el setUpAll

      //WHEN

      final String name = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      await vehicleController.createVehicle(numberPlate, consumption, fuelType, name);


      //THEN

      final Set<Vehicle> vehicles = await vehicleController.getVehicleList();

      // Convertir el set a una lista para acceder al primer elemento
      final vehicleList = vehicles.toList();
      
      // Acceder al primer objeto en la lista
      final firstPlace = vehicleList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstPlace.getConsumption(), equals(24.3)); // Verifica consumo
      expect(firstPlace.getFuelType(), equals("Gasolina")); // Verifica combustible
      expect(firstPlace.getNumberPlate(), equals("DKR9087")); // Verifica matricula
      expect(firstPlace.getName(), equals("Coche Quique"));  // Verifica nombre


    });


    test('H9-E3I - Crear vehículo inválido', () async {
      //GIVEN

      //Loguear usuario
      //Hecho en el SetUpAll


      //WHEN

      final String name = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Híbrido";


      //THEN

      Set<Vehicle> result = await vehicleController.getVehicleList();




      // THEN
      expect(() async => await vehicleController.createVehicle(numberPlate, consumption, fuelType, name),
        throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains("NotValidVehicleException: El tipo de combustible no es válido"))),
      );


      print('Patatatatatatata');
      print(result.first.getName());
      print(result.first.getNumberPlate());
      print(result.first.getFuelType());
      expect(result.isEmpty, true); 

      
    });


    test('H10-E1V - Listar vehículos válido', () async {
      //GIVEN
      //Loguear usuario
      //Hecho en el setUpAll


      //Tiene vehículo {nombre: "Coche Ana", consumo: 24.3, matricula: "DKR9087", combustible: "Gasolina"}
      final String name = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      await vehicleController.createVehicle(numberPlate, consumption, fuelType, name);



      //WHEN
      Set<Vehicle> vehicleList = await vehicleController.getVehicleList();

      //THEN

      expect(vehicleList.first.consumption, equals(24.3));
      expect(vehicleList.first.name, equals("Coche Quique"));
      expect(vehicleList.first.fuelType, equals("Gasolina"));
      expect(vehicleList.first.numberPlate, equals("DKR9087"));
      
    });


    test('H10-E3I - Listar vehículos sin conexion a la BBDD', () async {
       
      // GIVEN
      userAppAdapter = FirestoreAdapterUserApp(collectionName: "No conexion");
      userAppController = UserAppController(userAppAdapter);
      //Loguear usuario
      //Hecho en el setUpAll


    //WHEN
      
      void action() async {

       final Set<Vehicle> vehicles = await vehicleController.getVehicleList();
  
      }

      //THEN
     
    expect(
    () async => await vehicleController.getVehicleList(),
    throwsA(isA<ConnectionBBDDException>()),
  );

    });


    test('H10-E2V - Listar vehículos BBDD vacía', () async {
       
       //GIVEN

      //Usuario {email: "ana@gmail.com", password: "Aaaaa,.8"}
      //No tiene vehiculos
      //Loguear usuario
      //Hecho en el setUpAll


      //WHEN

      final vehicleList = await vehicleController.getVehicleList();


      //THEN

      expect(vehicleList, isEmpty);
    });
   


  });
  
  }
