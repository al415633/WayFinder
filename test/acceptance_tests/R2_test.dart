// precio_luz_service_acceptance_test.dart
import 'dart:convert';

import 'package:WayFinder/model/controladorLugar.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/model/lugar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('R2: Gestión de lugares de interés', () {

    late DbAdapter adapter;
    late ControladorLugar controladorLugar;

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
      controladorLugar = ControladorLugar(adapter);

    });

    test('H5-EV', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final double lat = 39.98567;
      final double long = -0.04935;
      final String apodo = "prueba 1";

      await controladorLugar.crearLugarPorCoord(lat, long, apodo);


      //THEN

      final Set<Lugar> lugares = await controladorLugar.getListaLugares();

      // Convertir el set a una lista para acceder al primer elemento
      final listaLugares = lugares.toList();
      
      // Acceder al primer objeto en la lista
      final primerLugar = listaLugares[0];

      // Verificar que los valores del primer lugar son los esperados
      expect(primerLugar.getCoordenada(), equals(Coordenada(lat, long))); // Verifica la latitud
      expect(primerLugar.getToponimo(), equals("Castelló de la Plana")); // Verifica la longitud
      expect(primerLugar.getApodo(), equals("prueba 1")); // Verifica el apodo


    });


    test('H5-EI', () async {

      //GIVEN

      //Loguear usuario
      //controladorUsuario.login(usuarioPruebas)


      //WHEN

      final double lat = 91;
      final double long = 181;
      final String apodo = "prueba 2";

      controladorLugar.crearLugarPorCoord(lat, long, apodo);


      //THEN

      expect(() {
      controladorLugar.crearLugarPorCoord(lat, long, apodo);
    }, throwsException);


    });


    test('H6', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });


    test('H7', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });


    test('H8', () async {
      // Llamada real a la API
      //final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      //expect(precioActual, isNotNull);
      //print('El precio actual de la luz es: $precioActual €/MWh');
    });
   


  });
}