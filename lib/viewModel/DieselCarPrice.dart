import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/GasoilGasolina.dart';
import 'package:WayFinder/viewModel/Price.dart';

class Dieselcarprice implements Price {
  @override
  Future<double> calculatePrice(Routes route, Vehicle vehiculo) async {
    double distance = route.distance;
    double consumption = vehiculo.consumption;

    double pricePerlitre = await GasoilGasolina.fetchPrice(route, FuelType.diesel);
    if (pricePerlitre == -1) {
      throw Exception('Error en el cálculo del precio del gasoil');
    }

    return pricePerlitre;
  }

 
}
