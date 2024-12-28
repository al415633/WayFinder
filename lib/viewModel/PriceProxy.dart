import 'dart:async';
import 'package:WayFinder/model/enum/fuelType.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/adapters/FirestoreAdapterLocation.dart';
import 'package:WayFinder/viewModel/municipios_map.dart';

class PriceProxy {
  static PriceProxy? _instance;

  static PriceProxy getInstance() {
    _instance ??= PriceProxy();
    return _instance!;
  }

  static final Map<String, ValorFecha> _priceCache =
      {}; //CAMBIAR DE RUTA A SITIO DE INICIO
  static double luzPrice = 0;
  static DateTime? tiempoLuz = DateTime(1900, 1, 1);

  static Future<double> getPrice(Routes route) async {
    Vehicle coche = route.vehicle!;

    final now = DateTime.now();

    if (coche.fuelType != FuelType.electrico) {
      String toponym = route.getStart.getToponym();
      String secondName = "";
      if (toponym.split(",").length == 1) {
        LocationController locationController =
            LocationController(FirestoreAdapterLocation());
        toponym = await locationController.CoordToToponym(
            route.getStart.getCoordinate());
      }
      String? idMunicipio =
          null; //Revisa con el que estará guardado en el mapa por GasoilGasolina
      List<String> toponymParts = toponym.split(',');
      int position = 0;
      while (idMunicipio == null && position < toponymParts.length) {
        String secondName = obtenerMunicipio(toponymParts, position);
        idMunicipio = municipioMap[secondName];
        position++;
      }

      final cacheEntry = _priceCache[secondName]?.precio;
      final lastCalculated = _priceCache[secondName]?.lastCalculated;

      final updateInterval = 1;

      if (cacheEntry != null) {
        if (now.difference(lastCalculated!).inHours < updateInterval) {
          return cacheEntry;
        }
      }

      //Si no se ha devuelto con lo de antes(ha pasado el tiempo), se vuelve a calcular
      double valor = await coche.price!.calculatePrice(route, coche);

      _priceCache[secondName] = ValorFecha(valor, now);

      return valor;
    }

    //Si el lastCalculated es menor a 24 horas, se coge el precio de la luz que ya hay en el mapa y sino se recalcula
    else {
      //(coche.fuelType == FuelType.electrico)
      if (now.difference(tiempoLuz!).inHours < 24) {
        return luzPrice;
      } else {
        luzPrice = (await coche.price!.calculatePrice(route, coche));
        tiempoLuz = now;

        return luzPrice;
      }
    }
  }

  static String obtenerMunicipio(List<String> toponymParts, int position) {
    String secondName = "";
    if (toponymParts.length > 1) {
      secondName = toponymParts[position].trim();
      if (secondName.contains("/")) {
        secondName = secondName.split("/")[0].trim();
      }
      if (secondName.contains("(")) {
        secondName = secondName.split("\\(")[0].trim();
      }
    }
    return secondName;
  }
}

class ValorFecha {
  final double precio;
  final DateTime lastCalculated;

  ValorFecha(this.precio, this.lastCalculated);
}
