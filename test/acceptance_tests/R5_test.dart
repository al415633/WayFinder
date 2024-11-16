// precio_luz_service_acceptance_test.dart
import 'dart:convert';

import 'package:WayFinder/model/User.dart';
import 'package:WayFinder/viewModel/controladorLugar.dart';
import 'package:WayFinder/viewModel/controladorRuta.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:WayFinder/model/ruta.dart';
import 'package:WayFinder/model/User.dart';
import 'package:WayFinder/viewModel/UserService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R5: Gestión de preferencias', () {

    late DbAdapterLugar adapterLugar;
    late ControladorLugar controladorLugar;


    late DbAdapterUser adapterUser;
    late UserService userService;

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
      adapterLugar = FirestoreAdapterLugar(collectionName: "testCollection");
      controladorLugar = ControladorLugar(adapterLugar);

      adapterUser = FirestoreAdapterUser(collectionName: "testCollection");
      userService = UserService(adapterUser);
      

    });

    test('H20-EV', () async {

      //GIVEN --> aquí habria que mirar si generamos un usuario por defecto y solo logIn
      //creamos cuenta al usuario
      String email = "belen@gmail.com";
      String password = "HolaAAAAA%1";
      User? user =  userService.createUser(email, password);

      //Loguear usuario
      userService.logIn(user!);


      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      await controladorLugar.crearLugarPorCoord(lat1, long1, apodo1);
      controladorLugar.ponerFav("Castelló de la Plana", apodo1);


      //THEN

      final Set<Lugar> lugares = await controladorLugar.getListaLugares();

      // Convertir el set a una lista para acceder al primer elemento
      final listaLugares = lugares.toList();
      
      // Acceder al primer objeto en la lista
      final primerLugar = listaLugares[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primerLugar.getFav(), equals(true)); // Verifica el Lugar inicial
     
      


    });


    test('H20-EI', () async {

          //GIVEN --> aquí habria que mirar si generamos un usuario por defecto y solo logIn
      //creamos cuenta al usuario
      String email = "belen@gmail.com";
      String password = "HolaAAAAA%1";
      User? user =  userService.createUser(email, password);

      //Loguear usuario
      userService.logIn(user!);



      //WHEN

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";


      await controladorLugar.crearLugarPorCoord(lat1, long1, apodo1);

      //THEN
     
     expect(() {
      controladorLugar.ponerFav("Castelló de la Plana", apodo1);
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
