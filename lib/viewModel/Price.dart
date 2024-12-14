import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/vehicle.dart';


abstract class Price{  
   Future<double> calculatePrice(Routes route, Vehicle vehiculo);
}
