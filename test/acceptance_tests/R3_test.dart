// precio_luz_service_acceptance_test.dart

import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R3: Gestión de vehículos', ()  {

    late DbAdapterVehicle vehicleAdapter;
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

      userAppAdapter = FirestoreAdapterUserApp(collectionName: "testCollection");
      userAppController = UserAppController(userAppAdapter);

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

 Future<void> deleteVehicle(String numberPlate) async {
  var collectionRef = FirebaseFirestore.instance.collection('testCollection');
  var querySnapshot = await collectionRef.where('numberPlate', isEqualTo: numberPlate).get();

  for (var doc in querySnapshot.docs) {
    await doc.reference.delete();
  }
  vehicleController.vehicleList = Future.value(<Vehicle>{});
 }

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

    test('H9-E1V - Crear vehiculo', () async {

      //GIVEN

      //Loguear usuario
       String email = "Pruebah9e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah9e1";

      await userAppController.createUser(email, password, name);
      await userAppController.logInCredenciales(email, password);

      vehicleAdapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(vehicleAdapter);
      //WHEN

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec);


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
    
    
    await signInAndDeleteUser(email, password);
    await deleteVehicle(numberPlate);



    });


    test('H9-E3I - Crear vehículo inválido', () async {
      //GIVEN
      String email = "Pruebah9e3@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah9e3";
      await userAppController.createUser(email, password, name);
      await userAppController.logInCredenciales(email, password);

      vehicleAdapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(vehicleAdapter);

      //Loguear usuario
      //Hecho en el SetUpAll


      //WHEN

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Híbrido";


      //THEN

      Set<Vehicle> result = await vehicleController.getVehicleList();





      // THEN
      expect(() async => await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec),
        throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains("NotValidVehicleException: El tipo de combustible no es válido"))),
      );


      expect(result.isEmpty, true); 

      await signInAndDeleteUser(email, password);

    });


    test('H10-E1V - Listar vehículos válido', () async {
      //GIVEN
      //Loguear usuario
      //Hecho en el setUpAll
      String email = "Pruebah10e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah10e1";
      await userAppController.createUser(email, password, name);
      await userAppController.logInCredenciales(email, password);

      vehicleAdapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(vehicleAdapter);

      //Tiene vehículo {nombre: "Coche Quique", consumo: 24.3, matricula: "DKR9087", combustible: "Gasolina"}
      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec);




      //WHEN
      Set<Vehicle> vehicleList = await vehicleController.getVehicleList();

      //THEN

      expect(vehicleList.first.consumption, equals(24.3));
      expect(vehicleList.first.name, equals("Coche Quique"));
      expect(vehicleList.first.fuelType, equals("Gasolina"));
      expect(vehicleList.first.numberPlate, equals("DKR9087"));
      
      await deleteVehicle(numberPlate);
      await signInAndDeleteUser(email, password);


    });


    test('H10-4I - Listar vehículos sin conexion a la BBDD', () async {
    /*
    //WHEN
      void action() async {
       final Set<Vehicle> vehicles = await vehicleController.getVehicleList();
      }
      //THEN
    expect(
        () async => await vehicleController.getVehicleList(),
        throwsA(isA<ConnectionBBDDException>()),
  );

  */


    });


    test('H10-E2V - Listar vehículos BBDD vacía', () async {
       
       //GIVEN

      String email = "Pruebah10e2@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah10e2";
      await userAppController.createUser(email, password, name);
      await userAppController.logInCredenciales(email, password);

      vehicleAdapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      vehicleController = VehicleController(vehicleAdapter);
      //WHEN

      final vehicleList = await vehicleController.getVehicleList();


      //THEN

      expect(vehicleList, isEmpty);
      await signInAndDeleteUser(email, password);
    });
       



  });
  
  }
