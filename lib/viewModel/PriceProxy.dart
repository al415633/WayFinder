import 'dart:async';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/Price.dart';

class PriceProxy implements Price {
  final Price? realPrice;
  double? _cachedPrice;
  DateTime? _lastFetchTime;

  PriceProxy(this.realPrice);

  @override
  Future<double> calculatePrice(Routes route, Vehicle vehiculo) async {
    final currentTime = DateTime.now();

    Duration cacheDuration;
    if (vehiculo.fuelType == 'Eléctrico') {
      cacheDuration = Duration(minutes: 60);
    } else {
      cacheDuration = Duration(days: 1);
    }

    int lastFetchHour = _lastFetchTime?.hour ?? -1; 
    int currentHour = currentTime.hour;

// solo comparo las horas pq si la peticion se ha hecho 11:59 me quiero quedar con el 11 que es cada cuando se actualiza
    if (_cachedPrice != null && _lastFetchTime != null) {
      if (currentHour == lastFetchHour) {
        return _cachedPrice!;
      }
    }

    _cachedPrice = await realPrice!.calculatePrice(route, vehiculo);
    _lastFetchTime = currentTime;

    return _cachedPrice!;
  }
}