import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterVehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  void addFav(Vehicle vehicle) async {
    // Obtener la referencia al documento con la matricula y nombre correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("VehicleList")
        .where("numberPlate", isEqualTo: vehicle.numberPlate)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException();
    }
    try{
      // Actualizar el campo 'fav' a true en el primer documento encontrado
      await querySnapshot.docs.first.reference.update({"fav": true});
    }catch(e){ 
      throw Exception("Error al añadir a favoritos en la base de datos: $e");
    }

  }

  @override
  void removeFav(Vehicle vehicle) async {
    // Obtener la referencia al documento con la matricula y nombre correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("VehicleList")
        .where("numberPlate", isEqualTo: vehicle.numberPlate)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException();
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": false});

  }



    @override
  Future<bool> editVehicle(Vehicle vehicle) async {
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
}

