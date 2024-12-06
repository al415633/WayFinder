import 'dart:convert';

import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/Price.dart';
import "package:WayFinder/viewModel/municipios_map.dart";
import 'package:http/http.dart' as http;

class Gasolinecarprice implements Price {
  @override
  Future<double> calculatePrice(Routes route, Vehicle vehiculo) async {
    double distance = route.distance;
    double consumption = vehiculo.consumption;

    double pricePerlitre = await fetchGasolinePrice(route);
    if (pricePerlitre == -1) {
      throw Exception('Error en el cálculo del precio de la gasolina');
    }

    double totalCost = pricePerlitre * consumption / 100 * distance;
    return totalCost;
  }

  Future<double> fetchGasolinePrice(Routes route) async {
    try {
      String toponym = route.start.toponym;
      List<String> toponymParts = toponym.split(',');
      if (toponymParts.length > 1) {
        String secondName = toponymParts[1].trim();
        String? idMunicipio = municipioMap[secondName];

        final response = await http.get(
          Uri.parse(
              'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestresHist/FiltroMunicipioProducto/05-12-2024/${idMunicipio}/1'),
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
