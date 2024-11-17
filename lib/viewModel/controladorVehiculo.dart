import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:WayFinder/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Controladorvehiculo {
  // Propiedades

    late Set<Vehicle> vehicleList;
    final DbAdapterVehiculo _dbAdapter;

    Controladorvehiculo(this._dbAdapter) : vehicleList = _dbAdapter.getVehicleList();


    Set<Vehicle> getVehicleList(){ 
      return vehicleList;
    }

    Future<bool> createVehicle(String numberPlate, double consumption, String fuelType, String name) async{

      if (!validNumberPlate(numberPlate)){
        throw Exception("NotValidVehicleException: El formato de la matrícula no es correcta");
      }

      if (!threeDecimalPlacesMax(consumption)){
        throw Exception("NotValidVehicleException: El formato del consumo no es correcto");
      }

      if(!validateFuelType(fuelType)){
        throw Exception("NotValidVehicleException: El tipo de combustible no es válido");
      }

      Vehicle vehicle = Vehicle(fuelType, consumption, numberPlate, name);

  
      bool success =  await this._dbAdapter.createVehicle(vehicle);
        
      if (success){
        vehicleList.add(vehicle);
      }


      return success;
    }



    Future<bool> ponerFav(String numberPlate, String name) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada

        bool success = await _dbAdapter.ponerFav(numberPlate, name);

        return success;
    }

    Future<bool> quitarFav(String numberPlate, String name) async{

      // habra que modificar tmb la lista que esta siendo actualmente usada


        bool success = await _dbAdapter.quitarFav(numberPlate, name);

        return success;
    }

    bool validNumberPlate(String? numberPlate) {
      if (numberPlate == null) return false;

      final format1 = RegExp(r'^[A-Z]{3}\d{4}$');
      final format2 = RegExp(r'^[A-Z]{1}\d{4}$');
      final format3 = RegExp(r'^[A-Z]{1,2}\d{4}[A-Z]{2}$');

      return format1.hasMatch(numberPlate) || format2.hasMatch(numberPlate) || format3.hasMatch(numberPlate);
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
  List<String> parts = valueStr.split('.');
  
  // Si no hay parte decimal, cumple la regla
  if (parts.length < 2) return true;
  
  // Verifica que la parte decimal tenga 6 o menos caracteres
  return parts[1].length <= 3;
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
    try {
      await db.collection(_collectionName).add(vehicle.toMap());
      return true;
    } catch (e) {
      print("Error al crear vehículo: $e");
      return false;
    }
  }
  
  @override
  Future<bool> ponerFav(String numberPlate, String name) {
    // TODO: implement ponerFav
    throw UnimplementedError();
  }
  
  @override
  Future<bool> quitarFav(String numberPlate, String name) {
    // TODO: implement quitarFav
    throw UnimplementedError();
  }
}



abstract class DbAdapterVehiculo {
  Future<bool> createVehicle(Vehicle vehicle);
  Set<Vehicle> getVehicleList();
  Future<bool> ponerFav(String numberPlate, String name);
  Future<bool> quitarFav(String numberPlate, String name);
}
