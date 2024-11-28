import 'package:WayFinder/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class VehicleController {
  // Propiedades

    late Future<Set<Vehicle>> vehicleList;
    final DbAdapterVehiculo _dbAdapter;

    VehicleController._internal(this._dbAdapter) : vehicleList = _dbAdapter.getVehicleList();
    static VehicleController? _instance;


    factory VehicleController(DbAdapterVehiculo dbAdapter) {


      _instance ??= VehicleController._internal(dbAdapter);
      return _instance!;
    }




    Future<Set<Vehicle>> getVehicleList(){ 
      return vehicleList;
    }

    Future<bool> createVehicle(String numberPlate, double consumption, String fuelType, String name) async{

    if (!validNumberPlate(numberPlate)){
       throw Exception("NotValidVehicleException: El formato de la matrícula no es correcto");
     }


     if (!threeDecimalPlacesMax(consumption)){
       throw Exception("NotValidVehicleException: El formato del consumo no es correcto");
     }


     if(!validateFuelType(fuelType)){
       throw Exception("NotValidVehicleException: El tipo de combustible no es válido");
     }


     Vehicle vehicle = Vehicle(fuelType, consumption, numberPlate, name);

      bool success =  await _dbAdapter.createVehicle(vehicle);
      
     if (success){
      final currentSet = await vehicleList;

      currentSet.add(vehicle);
     }

     return success;
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
    if (numberPlate == null) return false;


    final format1 = RegExp(r'^[A-Z]{3}\d{4}$');
    final format2 = RegExp(r'^[A-Z]{1}\d{4}$');
    final format3 = RegExp(r'^[A-Z]{1,2}\d{4}[A-Z]{2}$');


    return format1.hasMatch(numberPlate) ||
    format2.hasMatch(numberPlate) ||
    format3.hasMatch(numberPlate);

    }

    bool validateFuelType(String? fuelType){
      const validFuelTypes = ['Gasolina', 'Diésel', 'Eléctrico'];


      if (fuelType == null) return false;


      return validFuelTypes.contains(fuelType);
   }   

  
}


bool threeDecimalPlacesMax(double value) {
  // Convierte el número a String
  String valueStr = value.toString();
  // Divide la cadena en parte entera y parte decimal
  List<String> divisions = valueStr.split('.');
  // Si no hay parte decimal, cumple la regla
  if (divisions.length < 2) return true;
  // Verifica que la parte decimal tenga 6 o menos caracteres
  return divisions[1].length <= 3;

}


class FirestoreAdapterVehiculo implements DbAdapterVehiculo {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterVehiculo({String collectionName = "production"}) : _collectionName = collectionName;

  @override
  Future<Set<Vehicle>> getVehicleList() async{
  
    try {
      final querySnapshot = await db
      .collection(_collectionName)
      .doc(_currentUser?.uid)
      .collection("VehicleList")
      .get();

     Set<Vehicle> vehicles = querySnapshot.docs.map((doc) {
      return Vehicle.fromMap(doc.data());
     }) .toSet();

     return vehicles;
    
    } catch (e) {
      throw Exception('No se pudo obtener la lista de vehículos. Verifica la conexión.');
    }
  }

  @override
  Future<bool> createVehicle(Vehicle vehicle) async {
    try {
     await db.collection(_collectionName).add(vehicle.toMap());
     return true;
   } catch (e) {
     print("Error al crear vehículo: $e");
     return false;
   }
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
  Future<Set<Vehicle>> getVehicleList();
  Future<bool> addFav(String numberPlate, String name);
  Future<bool> removeFav(String numberPlate, String name);
}
