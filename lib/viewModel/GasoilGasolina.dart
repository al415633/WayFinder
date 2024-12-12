import 'package:WayFinder/model/route.dart';
import "package:WayFinder/viewModel/municipios_map.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

class GasoilGasolina {
  static Future<double> fetchPrice(Routes route, String tipo) async {
    try {
      //diesel 4
      //gasolina 1
      String valor = "1";
      if (tipo == 'diesel') {
        String valor = "4";
      }

      String toponym = route.start.toponym;
      List<String> toponymParts = toponym.split(',');
      if (toponymParts.length > 1) {
        String secondName = toponymParts[1].trim();
        if (secondName.contains("/")) {
          secondName = secondName.split("/")[0].trim();
        }
        if (secondName.contains("(")) {
          secondName = secondName.split("\\(")[0].trim();
        }
        String? idMunicipio = municipioMap[secondName];

        final response = await http.get(
          Uri.parse(
              'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestresHist/FiltroMunicipioProducto/05-12-2024/$idMunicipio/$valor'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data['ListaEESSPrecio'].isNotEmpty) {
            String precioString = data['ListaEESSPrecio'][0]['PrecioProducto'];
            precioString = precioString.replaceAll(',', '.');
            double precio = double.parse(precioString);
            return precio;
          } else {
            throw Exception('No hay precios disponibles');
          }
        } else {
          throw Exception('Error al cargar los datos: ${response.statusCode}');
        }
      } else {
        throw Exception('Toponym no tiene el formato esperado');
      }
    } catch (e) {
      print('Error: $e');
      return -1;
    }
  }
}
