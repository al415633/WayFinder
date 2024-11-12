// precio_luz_service_acceptance_test.dart
import 'package:flutter_test/flutter_test.dart';
import './precio_luz_service.dart'; 

void main() {
  group('PrecioLuz API Acceptance Test', () {
    late PrecioLuzService precioLuzService;

    setUp(() {
      precioLuzService = PrecioLuzService(); // Instanciamos el servicio
    });

    test('debería obtener el precio actual de la luz desde la API real', () async {
      // Llamada real a la API
      final precioActual = await precioLuzService.fetchPrecioActual();

      // Verificamos que el precio actual se haya recuperado
      expect(precioActual, isNotNull);
      print('El precio actual de la luz es: $precioActual €/MWh');
    });

    test('debería obtener una lista de precios por hora desde la API real', () async {
      // Llamada real a la API
      final preciosLuz = await precioLuzService.fetchPreciosLuz();

      // Verificamos que se haya recuperado una lista de precios por hora
      expect(preciosLuz.length, greaterThan(0));
      print('Número de precios por hora recuperados: ${preciosLuz.length}');
      print('Primer precio por hora: ${preciosLuz[0]['precio']} €/MWh');
    });
  });
}
