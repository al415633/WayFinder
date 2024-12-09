import 'dart:async';
import 'package:WayFinder/model/route.dart';

class PriceProxy {

   static PriceProxy? _instance;

  static PriceProxy getInstance() {
    _instance ??= PriceProxy();
    return _instance!;
  }


  static final Map<Routes, ValorFecha> _priceCache = {};

static Future<double> getPrice(Routes route) async {



  final now = DateTime.now();
  final cacheEntry = _priceCache[route]?.precio;
  final lastCalculated = _priceCache[route]?.lastCalculated;


  final isElectric = route.vehicle!.fuelType == 'Eléctrico'; 

  final updateInterval = isElectric ? 1 : 24; 

  
  if (cacheEntry != null && route.vehicle !=null) {
   
    if (now.difference(lastCalculated!).inHours < updateInterval) {
      return cacheEntry;
    }
  }

  double? valor = await route.vehicle!.price?.calculatePrice(route, route.vehicle!);

  _priceCache[route] = ValorFecha(valor!, now);


  return valor;

}
}


class ValorFecha {
  final double precio;
  final DateTime lastCalculated;

  ValorFecha(this.precio, this.lastCalculated);
}