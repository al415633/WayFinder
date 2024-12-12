import 'dart:async';
import 'package:WayFinder/model/route.dart';

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

    if (route.vehicle!.fuelType == 'Eléctrico') {
      if (now.difference(tiempoLuz!).inHours < 24) {
  
        
        return luzPrice;
      } else {
        luzPrice = (await route.vehicle!.price?.calculatePrice(route, route.vehicle!))!;
        tiempoLuz = now;

        return luzPrice; 
      }
    }

    final updateInterval = 1;

    if (cacheEntry != null && route.vehicle != null) {
      if (now.difference(lastCalculated!).inHours < updateInterval) {
        return cacheEntry;
      }
    }

    double? valor =
        await route.vehicle!.price?.calculatePrice(route, route.vehicle!);

    _priceCache[secondName] = ValorFecha(valor!, now);

    return valor;
  }
}

class ValorFecha {
  final double precio;
  final DateTime lastCalculated;

  ValorFecha(this.precio, this.lastCalculated);
}
