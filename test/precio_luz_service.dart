import 'dart:convert';
import 'package:http/http.dart' as http;

class PrecioLuzService {
  Future<String?> fetchPrecioActual([http.Client? client]) async {
    final String fechaHoy = getFechaHoy();
    final response = await (client ?? http.Client()).get(
      Uri.parse(
        'https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=${fechaHoy}T00:00&end_date=${fechaHoy}T23:59&time_trunc=hour',
      ),
    );
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      final precioActual = decodedData['included'][0]['attributes']['values'].last['value'];
      return precioActual.toString();
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPreciosLuz([http.Client? client]) async {
    final String fechaHoy = getFechaHoy();
    final response = await (client ?? http.Client()).get(
      Uri.parse(
        'https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=${fechaHoy}T00:00&end_date=${fechaHoy}T23:59&time_trunc=hour',
      ),
    );
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body) as Map<String, dynamic>;
      final precios = decodedData['included'][0]['attributes']['values'];
      return precios.map<Map<String, dynamic>>((entry) {
        return {
          'fecha': entry['datetime'],
          'precio': entry['value'],
        };
      }).toList();
    } else {
      return [];
    }
  }

  String getFechaHoy() {
    final ahora = DateTime.now();
    return "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
  }
}
