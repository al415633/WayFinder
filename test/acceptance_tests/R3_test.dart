// precio_luz_service_acceptance_test.dart
import 'dart:convert';

import 'package:WayFinder/exceptions/NotValidVehicleException.dart';
import 'package:WayFinder/viewModel/controladorVehiculo.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R2: Gestión de lugares de interés', () {

    late DbAdapterVehiculo adapter;
    late Controladorvehiculo controladorVehiculo;

    

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
      adapter = FirestoreAdapterVehiculo(collectionName: "testCollection");
      controladorVehiculo = Controladorvehiculo(adapter);

    });

    test('H9-EV', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final String name = "Coche Ana";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Gasolina";

      await controladorVehiculo.createVehicle(numberPlate, consumption, fuelType, name);


      //THEN

      final Set<Vehicle> vehicles = controladorVehiculo.getVehicleList();

      // Convertir el set a una lista para acceder al primer elemento
      final vehicleList = vehicles.toList();
      
      // Acceder al primer objeto en la lista
      final firstPlace = vehicleList[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(firstPlace.getConsumption(), equals(24.3)); // Verifica consumo
      expect(firstPlace.getFuelType(), equals("Gasolina")); // Verifica combustible
      expect(firstPlace.getNumberPlate(), equals("DKR9087")); // Verifica matricula
      expect(firstPlace.getName(), equals("Coche Ana"));  // Verifica nombre


    });


    test('H9-EI', () async {
//GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final String name = "Coche Ana";
      final double consumption = 24.3;
      final String numberPlate = "DKR9087";
      final String fuelType = "Híbrido";


      //THEN

      void action() {
        controladorVehiculo.createVehicle(numberPlate, consumption, fuelType, name);
      }


      // THEN
      expect(action, throwsA(isA<Notvalidvehicleexception>()));
    });
      expect(controladorVehiculo.getVehicleList(), isEmpty); // Verifica consumo

      
    });


    test('H10-EV', () async {
      
    });


    test('H10-EV', () async {
       
    });


    test('H7-EI', () async {
      
    });


    test('H8', () async {
     
    });
   


  });
}
