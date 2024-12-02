import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



class VehicleController {
  // Propiedades

    late Future<Set<Vehicle>> vehicleList;
    final DbAdapterVehicle _dbAdapter;

    VehicleController(this._dbAdapter) {
      vehicleList = _dbAdapter.getVehicleList(); // Inicializa con un conjunto vacío
    }

    static VehicleController? _instance;


  static VehicleController getInstance(DbAdapterVehicle dbAdapter) {
    _instance ??= VehicleController(dbAdapter);
    return _instance!;
  }

    Future<Set<Vehicle>> getVehicleList() async{ 
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
      
      if (!success) {
        throw Exception("Failed to create vehicle");
      } else{

        final currentSet = await vehicleList;
        // Agregar el nuevo Location al Set
        currentSet.add(vehicle);
        vehicleList = Future.value(currentSet) ;

      }
      
      return success;
    }



    Future<bool> addFav(String numberPlate, String name) async{

      try {
          bool success = await _dbAdapter.addFav(numberPlate, name);

          if (success) {
            // Si la operación fue exitosa, actualizar la lista local
            final currentSet = await vehicleList;
            for (var vehicle in currentSet) {
              if (vehicle.numberPlate == numberPlate && vehicle.name == name) {
                vehicle.fav = true; // Marcar como favorito en la lista local
                break;
              }
            }
          }

          return success;
        } catch (e) {
          throw Exception("Error al añadir a favoritos en el controlador: $e");
        }

    }

    Future<bool> removeFav(String numberPlate, String name) async{

        try {
          bool success = await _dbAdapter.removeFav(numberPlate, name);

          if (success) {
            // Si la operación fue exitosa, actualizar la lista local
            final currentSet = await vehicleList;
            for (var vehicle in currentSet) {
              if (vehicle.numberPlate == numberPlate && vehicle.name == name) {
                vehicle.fav = false; // Marcar como NO favorito en la lista local
                break;
              }
            }
          }

          return success;
        } catch (e) {
          throw Exception("Error al añadir a favoritos en el controlador: $e");
        }

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


class FirestoreAdapterVehiculo implements DbAdapterVehicle {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User? _currentUser; // Propiedad para almacenar el usuario actual


  FirestoreAdapterVehiculo({String collectionName = "production"})
      : _collectionName = collectionName{
        _initializeAuthListener();
      }
  
  // Método para inicializar el listener de autenticación
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
      if (user != null) {
        print('Usuario autenticado: ${user.uid}');
      } else {
        print('No hay usuario autenticado.');
      }
    });
  }

  @override
  Future<Set<Vehicle>> getVehicleList() async {
    final auth = FirebaseAuth.instance;
    final user =auth.currentUser;
    

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
  throw ConnectionBBDDException();  }
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
      throw Exception("No se encontró la ubicación con matrícula '$numberPlate' y nombre '$name'.");
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": true});

    return true;
  }

  @override
  Future<bool> removeFav(String numberPlate, String name) async{
    // Obtener la referencia al documento con la matricula y nombre correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("VehicleList")
        .where("numberPlate", isEqualTo: numberPlate)
        .where("name", isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("No se encontró la ubicación con matrícula '$numberPlate' y nombre '$name'.");
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": false});

    return true;
  }
}


abstract class DbAdapterVehicle {
  Future<bool> createVehicle(Vehicle vehicle);
  Future<Set<Vehicle>> getVehicleList();
  Future<bool> addFav(String numberPlate, String name);
  Future<bool> removeFav(String numberPlate, String name);
}
