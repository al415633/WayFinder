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
import 'package:integration_test/integration_test.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('R4: Gestión de rutas', () {

    late DbAdapter adapter;
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

      final double lat1 = 39.98567;
      final double long1 = -0.04935;
      final String apodo1 = "castellon";

      final double lat2 = 39.8890;
      final double long2 = -0.08499;
      final String apodo2 = "burriana";
      Lugar ini = Lugar(lat1, long1, apodo1);
      Lugar fin = Lugar(lat2, long2, apodo2);

      await controladorRuta.crearRuta(lat, long, apodo);


      //THEN

      final Set<Ruta> rutas = await controladorRuta.getListaRutas();

      // Convertir el set a una lista para acceder al primer elemento
      final listaRutas = rutas.toList();
      
      // Acceder al primer objeto en la lista
      final primeraRuta = listaRutas[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primeraRuta.getCoordenada(), equals(Coordenada(lat, long))); // Verifica la latitud
      expect(primerLugar.getToponimo(), equals("Castelló de la Plana")); // Verifica la longitud
      expect(primerLugar.getApodo(), equals("prueba 1")); // Verifica el apodo

      
    });
   

    test('H19', () async {
      
    });
   
  });
}
