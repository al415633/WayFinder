import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/model/Vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class VehicleController {
  // Propiedades

    late Future<Set<Vehicle>> vehicleList;
    final DbAdapterVehiculo _dbAdapter;

    VehicleController._internal(this._dbAdapter) {
      vehicleList = Future.value(<Vehicle>{}); // Inicializa con un conjunto vacío
    }

    static VehicleController? _instance;


  factory VehicleController(DbAdapterVehiculo dbAdapter) {
    _instance ??= VehicleController._internal(dbAdapter);
    return _instance!;
  }




    Future<Set<Vehicle>> getVehicleList(){ 

  
      return _dbAdapter.getVehicleList();
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

      // Formatos existentes
      final format1 = RegExp(r'^[A-Z]{3}\d{4}$');  // Ejemplo: ABC1234
      final format2 = RegExp(r'^[A-Z]{1}\d{4}$');  // Ejemplo: A1234
      final format3 = RegExp(r'^[A-Z]{1,2}\d{4}[A-Z]{2}$');  // Ejemplo: A1234BC, AB1234XY
      
      // Formato para números seguidos de letras (como 1879ABC)
      final format4 = RegExp(r'^\d{4}[A-Z]{3}$');  // Ejemplo: 1879ABC

      // Verifica si alguna de las expresiones regulares coincide
      return format1.hasMatch(numberPlate) ||
            format2.hasMatch(numberPlate) ||
            format3.hasMatch(numberPlate) ||
            format4.hasMatch(numberPlate);
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

  FirestoreAdapterVehiculo({String collectionName = "production"})
      : _collectionName = collectionName;

  @override
  Future<Set<Vehicle>> getVehicleList() async {
    final auth = FirebaseAuth.instance;
    final user =auth.currentUser;
    

    if (auth == null || user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("VehicleList")
          .get();

      return querySnapshot.docs.map((doc) {
        return Vehicle.fromMap(doc.data());
      }).toSet();
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> createVehicle(Vehicle vehicle) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado. No se puede crear el vehículo.');
    }

    try {
      await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("VehicleList")
          .add(vehicle.toMap());
      return true;
    } catch (e) {
      throw Exception('Error al crear el vehículo: $e');
    }
  }

  @override
  Future<bool> addFav(String numberPlate, String name) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeFav(String numberPlate, String name) {
    throw UnimplementedError();
  }
}


abstract class DbAdapterVehiculo {
  Future<bool> createVehicle(Vehicle vehicle);
  Future<Set<Vehicle>> getVehicleList();
  Future<bool> addFav(String numberPlate, String name);
  Future<bool> removeFav(String numberPlate, String name);
}
