// precio_luz_service_acceptance_test.dart

import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/VehicleController.dart';
import 'package:WayFinder/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R3_Itest.mocks.dart';


@GenerateMocks([FirebaseAuth, DbAdapterVehicle, DbAdapterUserApp])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R3: Gestión de vehículos', ()  {

    late MockDbAdapterVehicle mockVehicleAdapter;
    late VehicleController vehicleController;


    late MockDbAdapterUserApp mockUserAppAdapter;
    late UserAppController userAppController;


    setUp(() async {
    mockUserAppAdapter = MockDbAdapterUserApp();
    mockVehicleAdapter = MockDbAdapterVehicle();
    userAppController = UserAppController(mockUserAppAdapter);
    vehicleController = VehicleController(mockVehicleAdapter);
  });
    

 Future<void> _deleteVehicle(String numberPlate) async {
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

      //WHEN

      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      //when(vehicleController.createVehicle(numberPlate, consumption, fuelType, namec))
      //.thenAnswer((_) async => true);

      when(mockVehicleAdapter.createVehicle(any)).thenAnswer((_) async => true);

      bool success = await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec);

      final vehicleMock = Vehicle(fuelType, consumption, numberPlate, namec);
      when(mockVehicleAdapter.getVehicleList()).thenAnswer((_) async => {vehicleMock});
      //when(vehicleController.getVehicleList()).thenAnswer((_) async => {vehicleMock});

      final Set<Vehicle> vehicles = await vehicleController.getVehicleList();

      //THEN
      expect(success, isTrue);


      // Convertir el set a una lista para acceder al primer elemento
      final vehicleList = vehicles.toList();
      
      // Acceder al primer objeto en la lista
      final firstPlace = vehicleList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstPlace.getConsumption(), equals(24.3)); // Verifica consumo
      expect(firstPlace.getFuelType(), equals("Gasolina")); // Verifica combustible
      expect(firstPlace.getNumberPlate(), equals("DKR9087")); // Verifica matricula
      expect(firstPlace.getName(), equals("Coche Quique"));  // Verifica nombre

      // Verificar interacciones con el mock
      verify(mockVehicleAdapter.createVehicle(any)).called(1);
      verify(mockVehicleAdapter.getVehicleList()).called(1);

    });


    test('H9-E3I - Crear vehículo inválido', () async {
      //GIVEN
      String email = "Pruebah9e3@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah9e3";


      //Loguear usuario
      //Hecho en el SetUpAll


      //WHEN
      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Híbrido";

      final vehicleMock = Vehicle(fuelType, consumption, numberPlate, namec);

      // Configura el mock para lanzar una excepción
      when(mockVehicleAdapter.createVehicle(vehicleMock))
          .thenThrow(Exception("NotValidVehicleException: El tipo de combustible no es válido"));
      when(mockVehicleAdapter.getVehicleList())
          .thenAnswer((_) async => <Vehicle>{});

      // WHEN
      Future<void> action() async {
        await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec);
      }

      // THEN
      expect(
        action(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains("NotValidVehicleException: El tipo de combustible no es válido"),
        )),
      );

      final vehicles = await vehicleController.getVehicleList();
      print(vehicles.first.getName());
      expect(vehicles.isEmpty, true);

      // Verificar que no se llamó a `createVehicle` en el mock
      verifyNever(mockVehicleAdapter.createVehicle(any));
      verify(mockVehicleAdapter.getVehicleList()).called(1);
    });


    test('H10-E1V - Listar vehículos válido', () async {
      //GIVEN
      //Loguear usuario
      //Hecho en el setUpAll
      String email = "Pruebah10e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah10e1";


      //Tiene vehículo {nombre: "Coche Quique", consumo: 24.3, matricula: "DKR9087", combustible: "Gasolina"}
      final String namec = "Coche Quique";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      final vehicleMock = Vehicle(fuelType, consumption, numberPlate, namec);

      // Simula la creación exitosa del vehículo
      when(mockVehicleAdapter.createVehicle(any))
      .thenAnswer((_) async => true);

      // Simula que `getVehicleList` devuelve un conjunto con el vehículo creado
      when(mockVehicleAdapter.getVehicleList()).thenAnswer((_) async => {vehicleMock});


      //WHEN

      final success = await vehicleController.createVehicle(numberPlate, consumption, fuelType, namec);
      final vehicleList = await vehicleController.getVehicleList();

      //THEN

      expect(success, isTrue);
      expect(vehicleList.first.consumption, equals(24.3));
      expect(vehicleList.first.name, equals("Coche Quique"));
      expect(vehicleList.first.fuelType, equals("Gasolina"));
      expect(vehicleList.first.numberPlate, equals("DKR9087"));
      
      verify(mockVehicleAdapter.createVehicle(any)).called(1);
      verify(mockVehicleAdapter.getVehicleList()).called(1);
    });


    test('H10-4I - Listar vehículos sin conexion a la BBDD', () async {

      when(mockVehicleAdapter.getVehicleList())
      .thenThrow(NotAuthenticatedUserException());
      //WHEN
      void action() async {
        final Set<Vehicle> vehicles = await vehicleController.getVehicleList();
      }
      //THEN
      expect(
        () async => await vehicleController.getVehicleList(),
        throwsA(isA<NotAuthenticatedUserException>()),
      );


    });


    test('H10-E2V - Listar vehículos BBDD vacía', () async {
       
       //GIVEN

 String email = "Pruebah10e2@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah10e2";
   await userAppController.createUser(email, password, name);
      await userAppController.logInCredenciales(email, password);
      //WHEN

      final vehicleList = await vehicleController.getVehicleList();


      //THEN

      expect(vehicleList, isEmpty);
  await signInAndDeleteUser(email, password);
    });
       



  });
  
  }