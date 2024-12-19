import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/viewModel/adapters/DBAdapterLocation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreAdapterLocation implements DbAdapterLocation {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  User? _currentUser; // Propiedad para almacenar el usuario actual

  FirestoreAdapterLocation({String collectionName = "production"})
      : _collectionName = collectionName {
    // Configurar el listener para authStateChanges
    _initializeAuthListener();
  }

  // Método para inicializar el listener de autenticación
  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
    });
  }

  @override
  Future<Set<Location>> getLocationList() async {
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
          .collection("LocationList")
          .get();

      // Convertir cada documento a una instancia de Location
      Set<Location> locations = querySnapshot.docs.map((doc) {
        return Location.fromMap(doc.data());
      }).toSet();

      return locations;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> createLocationFromCoord(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(user.uid)
          .collection("LocationList")
          .add(location.toMap());
      return true;
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<bool> createLocationFromTopo(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      await db
          .collection(_collectionName)
          .doc(_currentUser?.uid) // Documento del usuario actual
          .collection("LocationList") // Subcolección "LocationList"
          .add(location.toMap());
      return true;
    } catch (e) {
      print("Error al crear el lugar: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteLocation(Location location) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      // Obtener la colección de lugares de interés del usuario
      var collectionRef = db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("LocationList");

      // Buscar el documento por algún atributo único del lugar de interés, como no lo tiene, revisamos tres para asegurarnos de que sea el correcto
      var querySnapshot = await collectionRef
          .where('lat', isEqualTo: location.getCoordinate().lat)
          .where('long', isEqualTo: location.getCoordinate().long)
          .where('toponym', isEqualTo: location.getToponym())
          .where('alias', isEqualTo: location.getAlias())
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
  Future<bool> addFav(Location location) async {
    // Obtener la referencia al documento con el topónimo y alias correspondiente
    final querySnapshot = await db
        .collection(_collectionName)
        .doc(_currentUser?.uid)
        .collection("LocationList")
        .where("toponym", isEqualTo: location.toponym)
        .where("alias", isEqualTo: location.alias)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw ConnectionBBDDException();
    }

    // Actualizar el campo 'fav' a true en el primer documento encontrado
    await querySnapshot.docs.first.reference.update({"fav": true});

    return true;
  }

  @override
  Future<bool> removeFav(Location location) async {
    try {
      // Obtener la referencia al documento con el topónimo y alias correspondiente
      final querySnapshot = await db
          .collection(_collectionName)
          .doc(_currentUser?.uid)
          .collection("LocationList")
          .where("toponym", isEqualTo: location.toponym)
          .where("alias", isEqualTo: location.alias)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw ConnectionBBDDException();
      }

      // Actualizar el campo 'fav' a false en el primer documento encontrado
      await querySnapshot.docs.first.reference.update({"fav": false});

      return true;
    } catch (e) {
      print("Error al eliminar de favoritos: $e");
      return false;
    }
  }
}

