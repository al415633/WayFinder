import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import '../lib/main.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import '../lib/paginas/precioluz.dart';
import 'precio_luz_integration_test.mocks.dart';
import 'precio_luz_service.dart'; // Asegúrate de que la ruta sea correcta


@GenerateMocks([http.Client])
void main() {
  
  // Definimos el grupo de pruebas
  group('PrecioLuz API Integration Test', () {
    late MockClient mockClient;

    // Configuramos el mock antes de cada prueba
    setUp(() {
      mockClient = MockClient();
    });

    // Definimos una prueba
    test('debería obtener el precio actual de la luz correctamente', () async {
      // Simulamos la respuesta de la API
      final mockResponse = jsonEncode({
        'included': [
          {
            'attributes': {
              'values': [
                {'datetime': '2023-10-11T23:00', 'value': 100.5},
                {'datetime': '2023-10-11T24:00', 'value': 102.5}
              ]
            }
          }
        ]
      });

      // Usamos un predicado personalizado para coincidir con el Uri esperado
      when(mockClient.get(any)).thenAnswer(
  (_) async => Future.value(http.Response(mockResponse, 200)),
);

      // Instancia el objeto que vas a probar (PrecioLuz)
      final service = PrecioLuzService();

      final actualPrecioLuz = await service.fetchPrecioActual(mockClient); 

      // Verificamos el valor actualizado
      expect(actualPrecioLuz, '102.5'); // Comparar con un double
    });
  });
}
