import 'package:WayFinder/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class VehicleController {
  // Propiedades

    late Set<Vehicle> vehicleList;
    final DbAdapterVehiculo _dbAdapter;

    VehicleController._internal(this._dbAdapter) : vehicleList = _dbAdapter.getVehicleList();
    static VehicleController? _instance;


    factory VehicleController(DbAdapterVehiculo dbAdapter) {


      _instance ??= VehicleController._internal(dbAdapter);
      return _instance!;
    }




    Set<Vehicle> getVehicleList(){ 
      return vehicleList;
    }

    Future<bool> createVehicle(String numberPlate, double consumption, String fuelType, String name) async{

           throw UnimplementedError("Method Not Implemented");

    }



    Future<bool> addFav(String numberPlate, String name) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada

            throw UnimplementedError("Method Not Implemented");

    }

    Future<bool> removeFav(String numberPlate, String name) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada


             throw UnimplementedError("Method Not Implemented");

    }

    bool validNumberPlate(String? numberPlate) {
           throw UnimplementedError("Method Not Implemented");

    }

    bool validateFuelType(String? fuelType){
          throw UnimplementedError("Method Not Implemented");

    }    
}


bool threeDecimalPlacesMax(double value) {
  // Convierte el número a String
       throw UnimplementedError("Method Not Implemented");

}


class FirestoreAdapterVehiculo implements DbAdapterVehiculo {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  FirestoreAdapterVehiculo({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Set<Vehicle> getVehicleList(){
  //TODO: implementarlo usando la base de datos

  throw UnimplementedError("Method not implemented");
  }

  @override
  Future<bool> createVehicle(Vehicle vehicle) async {
          throw UnimplementedError("Method Not Implemented");

  }
  
  @override
  Future<bool> addFav(String numberPlate, String name) {
    // TODO: implement ponerFav
    throw UnimplementedError();
  }
  
  @override
  Future<bool> removeFav(String numberPlate, String name) {
    // TODO: implement quitarFav
    throw UnimplementedError();
  }
}

abstract class DbAdapterVehiculo {
  Future<bool> createVehicle(Vehicle vehicle);
  Set<Vehicle> getVehicleList();
  Future<bool> addFav(String numberPlate, String name);
  Future<bool> removeFav(String numberPlate, String name);
}
