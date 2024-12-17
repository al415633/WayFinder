import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/NotValidVehicleException.dart';
import 'package:WayFinder/model/fuelType.dart';
import 'package:WayFinder/model/vehicle.dart';
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
      await _dbAdapter.addFav(vehicle.numberPlate, vehicle.name);

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
      await _dbAdapter.removeFav(vehicle.numberPlate, vehicle.name);
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

class FirestoreAdapterVehiculo implements DbAdapterVehicle {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterVehiculo({String collectionName = "production"})
      : _collectionName = collectionName {
    _initializeAuthListener();
  }

  // Método para inicializar el listener de autenticación
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
    });
  }

  @override
  Future<Set<Vehicle>> getVehicleList() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("VehicleList")
          .get();

      // Convertir cada documento a una instancia de Location
      Set<Vehicle> vehicles = querySnapshot.docs.map((doc) {
        return Vehicle.fromMap(doc.data());
      }).toSet();
      return vehicles;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> createVehicle(Vehicle vehicle) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("VehicleList")
          .add(vehicle.toMap());
      return true;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> deleteVehicle(Vehicle vehicle) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      // Obtener la colección de vehículo del usuario
      var collectionRef = db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("VehicleList");

      // Buscar el documento por algún atributo único del vehículo, como no lo tiene, revisamos tres para asegurarnos de que sea el correcto
      var querySnapshot = await collectionRef
          .where('numberPlate', isEqualTo: vehicle.getNumberPlate())
          .get();

      // Verificar si se encontró el documento
      if (querySnapshot.docs.isEmpty) {
        throw ConnectionBBDDException();
      }

      // Eliminar el primer documento encontrado
      await querySnapshot.docs.first.reference.delete();

      return true;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> addFav(String numberPlate, String name) async {
    // Obtener la referencia al documento con la matricula y nombre correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("VehicleList")
        .where("numberPlate", isEqualTo: numberPlate)
        .where("name", isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException();
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": true});

    return true;
  }

  @override
  Future<bool> removeFav(String numberPlate, String name) async {
    // Obtener la referencia al documento con la matricula y nombre correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("VehicleList")
        .where("numberPlate", isEqualTo: numberPlate)
        .where("name", isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException();
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": false});

    return true;
  }
}

abstract class DbAdapterVehicle {
  Future<bool> createVehicle(Vehicle vehicle);
  Future<Set<Vehicle>> getVehicleList();
  Future<bool> deleteVehicle(Vehicle vehicle);
  Future<bool> addFav(String numberPlate, String name);
  Future<bool> removeFav(String numberPlate, String name);
}
