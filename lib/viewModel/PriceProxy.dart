import 'dart:async';
import 'package:WayFinder/model/fuelType.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';

class PriceProxy {
  static PriceProxy? _instance;

  static PriceProxy getInstance() {
    _instance ??= PriceProxy();
    return _instance!;
  }

  static final Map<String, ValorFecha> _priceCache = {}; //CAMBIAR DE RUTA A SITIO DE INICIO
  static double luzPrice = 0;
  static DateTime? tiempoLuz = DateTime(1900, 1, 1);
  
  static Future<double> getPrice(Routes route) async {
    Vehicle coche = route.vehicle!;

    final now = DateTime.now();


      String toponym = route.start.toponym;
      String secondName="";
      List<String> toponymParts = toponym.split(',');
      if (toponymParts.length > 1) {
        String secondName = toponymParts[1].trim();
        if (secondName.contains("/")) {
          secondName = secondName.split("/")[0].trim();
        }
        if (secondName.contains("(")) {
          secondName = secondName.split("\\(")[0].trim();
        }
      }

    final cacheEntry = _priceCache[secondName]?.precio;
    final lastCalculated = _priceCache[secondName]?.lastCalculated;

  //Si el lastCalculated es menor a 24 horas, se coge el precio de la luz/gasolina que ya hay en el mapa
    if (coche.fuelType == FuelType.electrico) {
      if (now.difference(tiempoLuz!).inHours < 24) {
  
        
        return luzPrice;
      } else {
        luzPrice = (await coche.price!.calculatePrice(route, coche));
        tiempoLuz = now;

        return luzPrice; 
      }
    }

    final updateInterval = 1;

    if (cacheEntry != null) {
      if (now.difference(lastCalculated!).inHours < updateInterval) {
        return cacheEntry;
      }
    }
    
  //Si no se ha devuelto con lo de antes(ha pasado el tiempo), se vuelve a calcular
    double valor =
        await coche.price!.calculatePrice(route, coche);

    _priceCache[secondName] = ValorFecha(valor, now);

    return valor;
  }
}

class ValorFecha {
  final double precio;
  final DateTime lastCalculated;

  ValorFecha(this.precio, this.lastCalculated);
}
