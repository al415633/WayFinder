// precio_luz_service_acceptance_test.dart
import 'dart:convert';

import 'package:WayFinder/model/controladorLugar.dart';
import 'package:WayFinder/model/controladorRuta.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('R4: Gestión de rutas', () {

    late DbAdapter adapter;
    late ControladorRuta controladorRuta;

    setUpAll(() async {
      // Inicializar el entorno de pruebas
      WidgetsFlutterBinding.ensureInitialized();

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
      adapter = FirestoreAdapter(collectionName: "testCollection");
      controladorRuta = ControladorRuta(adapter);

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
   

    test('H17', () async {
      
    });
   
    test('H18', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      


      //THEN
      
    });
   

    test('H19', () async {
      
    });
   
  });
}
