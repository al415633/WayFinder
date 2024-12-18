import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/NotValidVehicleException.dart';
import 'package:WayFinder/model/fuelType.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterVehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleController {
  // Propiedades
  late Future<Set<Vehicle>> vehicleList;
  final DbAdapterVehicle _dbAdapter;

  VehicleController(this._dbAdapter) {
    vehicleList =
        _dbAdapter.getVehicleList(); // Inicializa con un conjunto vacío
  }

  static VehicleController? _instance;

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  static VehicleController getInstance(DbAdapterVehicle dbAdapter) {
    _instance ??= VehicleController(dbAdapter);
    return _instance!;
  }

  Future<Set<Vehicle>> getVehicleList() async {
    return vehicleList;
  }

  Future<Vehicle> createVehicle(String numberPlate, double consumption,
      FuelType? fuelType, String name) async {
    // Validar matrícula
    if (!validNumberPlate(numberPlate)) {
      throw NotValidVehicleException();
    }

    // Validar consumo
    if (!threeDecimalPlacesMax(consumption)) {
      throw NotValidVehicleException();
    }

    if (fuelType == null) {
      throw NotValidVehicleException();
    }

    // Crear el objeto Vehicle
    Vehicle vehicle = Vehicle(fuelType, consumption, numberPlate, name);

    // Guardar el vehículo en la base de datos
    bool success = await _dbAdapter.createVehicle(vehicle);

    if (!success) {
      throw Exception("Failed to create vehicle");
    } else {
      final currentSet = await vehicleList;
      // Agregar el nuevo Vehicle al Set
      currentSet.add(vehicle);
      vehicleList = Future.value(currentSet);
    }

    // Devolver el vehículo creado
    return vehicle;
  }

  Future<bool> deleteVehicle(Vehicle vehicle) async {
    try {
      bool success = await _dbAdapter.deleteVehicle(vehicle);

      if (success) {
        final currentSet = await vehicleList;
        // Agregar el nuevo vehiculo al Set
        currentSet.remove(vehicle);
        vehicleList = Future.value(currentSet);
      }

      return success;
    } catch (e) {
      throw Exception("Error al crear el vehiculo: $e");
    }
  }

  void addFav(Vehicle vehicle) async {
    try {
      _dbAdapter.addFav(vehicle);
      // Si la operación fue exitosa, actualizar la lista local
      final currentSet = await vehicleList;
      vehicle.addFav(); // Marcar como favorito en la lista local
      vehicleList = Future.value(currentSet);
    } catch (e) {
      throw Exception("Error al añadir a favoritos en el controlador: $e");
    }
  }

  void removeFav(Vehicle vehicle) async {
    try {
      _dbAdapter.removeFav(vehicle);
      final currentSet = await vehicleList;
      vehicle.removeFav(); // Marcar como NO favorito en la lista local
      vehicleList = Future.value(currentSet);
    } catch (e) {
      throw Exception("Error al aliminar de favoritos en el controlador: $e");
    }
  }

  bool validNumberPlate(String? numberPlate) {
    if (numberPlate == null) return false;

    numberPlate = numberPlate.toUpperCase();

    // Formatos existentes
    final format1 = RegExp(r'^[A-Z]{3}\d{4}$'); // Ejemplo: ABC1234
    final format2 = RegExp(r'^[A-Z]{1}\d{4}$'); // Ejemplo: A1234
    final format3 =
        RegExp(r'^[A-Z]{1,2}\d{4}[A-Z]{2}$'); // Ejemplo: A1234BC, AB1234XY

    // Formato para números seguidos de letras (como 1879ABC)
    final format4 = RegExp(r'^\d{4}[A-Z]{3}$'); // Ejemplo: 1879ABC

    // Verifica si alguna de las expresiones regulares coincide
    return format1.hasMatch(numberPlate) ||
        format2.hasMatch(numberPlate) ||
        format3.hasMatch(numberPlate) ||
        format4.hasMatch(numberPlate);
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
}

