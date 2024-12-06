import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/Price.dart';
import 'package:intl/intl.dart';


class Electriccarprice implements Price{
 
   @override
  Future<double> calculatePrice(Routes route, Vehicle vehiculo)  async {
    double distance = route.distance;
    double consumption = vehiculo.consumption;

    double pricePerKWh =  convertMWhToKWh(await _fetchElectricityPrice());
    double costPerKm = pricePerKWh * consumption/100 * distance;

    return costPerKm;
  }

double convertMWhToKWh(double pricePerMWh) {
  return pricePerMWh / 1000; 
}

String getFechaHoy() {
  final ahora = DateTime.now();
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(ahora);
}
double truncarA2Decimales(double valor) {
  return (valor * 100).floor() / 100;
}



Future<double> _fetchElectricityPrice() async {
  String fechaHoy = getFechaHoy();

  // Realiza la solicitud HTTP
  final response = await http.get(
    Uri.parse(
      'https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=${fechaHoy}T00:00&end_date=${fechaHoy}T23:59&time_trunc=hour',
    ),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    final precioMercadoSpot = data['included'].firstWhere(
      (item) => item['type'] == "Precio mercado spot",
      orElse: () => null,
    );

    if (precioMercadoSpot != null) {
      List<dynamic> values = precioMercadoSpot['attributes']['values'];

      DateTime now = DateTime.now();
      String horaActual = "${now.toIso8601String().substring(0, 13)}:00"; 

      final precioActual = values.firstWhere(
        (value) => value['datetime'].contains(horaActual),
        orElse: () => null,
      );

      if (precioActual != null) {
        return truncarA2Decimales(precioActual['value']);
      } else {
        throw Exception('No se encontró el precio para la hora actual');
      }
    } else {
      throw Exception('No se encontró el precio para la región específica');
    }
  } else {
    throw Exception('Error al obtener el precio de la electricidad');
  }
}

}
