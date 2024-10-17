import 'dart:convert';
import 'package:http/http.dart' as http;

class Municipio {
  final String id;
  final String nombre;

  Municipio({required this.id, required this.nombre});

  // Método para convertir un JSON en un objeto Municipio
  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['IDMunicipio'] ?? '',
      nombre: json['Municipio'] ?? '',
    );
  }
}

// Servicio para obtener la lista de municipios
class MunicipioService {
  final String baseUrl = 'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios/';

  // Función para obtener la lista de municipios desde la API
  Future<List<Municipio>> fetchMunicipios() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Municipio.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los municipios');
    }
  }
}
