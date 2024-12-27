import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterLocation.dart';
import "package:WayFinder/viewModel/municipios_map.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;

class GasoilGasolina {
  static Future<double> fetchPrice(Routes route, FuelType fuelType) async {
    try {
      //diesel 4
      //gasolina 1
      String valor = "1";
      if (fuelType == FuelType.diesel) {
        valor = "4";
      }

      String toponym = route.getStart.getToponym();

      if (toponym.split(",").length == 1){
        LocationController locationController= LocationController(FirestoreAdapterLocation());
        toponym = await locationController.CoordToToponym(route.getStart.getCoordinate());
      }
      String secondName = "";
      List<String> toponymParts = toponym.split(',');
      if (toponymParts.length > 1) {
        secondName = toponymParts[toponymParts.length - 3].trim();
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
      return -1;
    }
  }
}
