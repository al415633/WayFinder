import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/MissingInformationRouteException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/UserAlreadyExistsException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/exceptions/UserNotExistsExcpetion.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreAdapterUserApp implements DbAdapterUserApp {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? _currentUser;

  FirestoreAdapterUserApp({String collectionName = "production"})
      : _collectionName = collectionName {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user; // Actualizar el usuario actual
    });
  }

  @override
  Future<UserApp?> createUser(String email, String password) async {
    var existingUser = await auth.fetchSignInMethodsForEmail(email);
    if (existingUser.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    // Ver si mail en BBDD
    var querySnapshot = await db
        .collection(_collectionName)
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      // Guardar el ususario en la BBDD
      await db.collection(_collectionName).doc(user.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserApp(user.uid, '', email);
    } else {
      throw ConnectionBBDDException();
    }
  }

  @override
  Future<UserApp?> logInCredenciales(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      UserApp usuario = UserApp(user!.uid, user.displayName ?? '', email);
      usuario.setUser = user;
      print(user.email);
      print(user.uid);
      return usuario;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotExistException();
      } else if (e.code == 'wrong-password') {
        throw IncorrectPasswordException();
      }
      rethrow;
    }
  }

  @override
  Future<bool> logOut() async {
    try {
      if (auth.currentUser == null) {
        throw UserNotAuthenticatedException();
      }

      await auth.signOut();
      return true;
    } catch (e) {
      throw UserNotAuthenticatedException();
    }
  }

  Future<void> _deleteSubCollections(String userId) async {
    // Lista de nombres de colecciones asociadas al usuario
    final List<String> subCollectionNames = [
      'LocationList',
      'RouteList',
      'VehicleList'
    ]; // Actualiza con tus nombres de colecciones

    for (String collectionName in subCollectionNames) {
      QuerySnapshot subCollectionSnapshot = await db
          .collection(_collectionName) // Colección principal (usuarios)
          .doc(userId)
          .collection(collectionName)
          .get();

      for (QueryDocumentSnapshot doc in subCollectionSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  @override
  Future<void> deleteAccount() async {
    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      throw UserNotAuthenticatedException();
    }

    try {
      // Eliminar subcolecciones asociadas al usuario
      await _deleteSubCollections(currentUser.uid);

      // Eliminar el documento principal del usuario
      await db.collection(_collectionName).doc(currentUser.uid).delete();

      // Eliminar la cuenta de Firebase Authentication
      await currentUser.delete();
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        throw UserNotAuthenticatedException();
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteAccountForEmail(String email) async {
    var querySnapshot = await db
        .collection(_collectionName)
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw UserNotExistException();
    }

    // Documento del usuario encontrado
    var userDoc = querySnapshot.docs.first;

    // Eliminar subcolecciones asociadas
    await _deleteSubCollections(userDoc.id);

    // Eliminar el documento principal del usuario
    await db.collection(_collectionName).doc(userDoc.id).delete();
  }

  @override
  Future<bool> checkIfUserExists(String email) async {
    try {
      // Verificar si el email ya está registrado en Firebase Authentication
      var methods = await auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return true;
      }

      // Verificar si el email existe en la colección de Firestore
      var querySnapshot = await db
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void setTransportModeDefault(TransportMode transportMode, Vehicle? vehicle) {
    if (_currentUser == null) {
      throw UserNotAuthenticatedException();
    }

    if (transportMode == TransportMode.bicicleta ||
        transportMode == TransportMode.aPie ||
        transportMode == TransportMode.noSeleccionado) {
      db.collection(_collectionName).doc(_currentUser?.uid).update({
        'defaultTransportMode': transportMode.name,
      });
    } else if (transportMode == TransportMode.coche) {
      db.collection(_collectionName).doc(_currentUser?.uid).update({
        'defaultTransportMode': transportMode.name,
        'vehicleDefault': vehicle?.toMap(),
      });
    } else {
      throw MissingInformationRouteException();
    }
  }

  @override
  void setRouteModeDefault(RouteMode routeMode) {
    if (_currentUser == null) {
      throw UserNotAuthenticatedException();
    }

    db.collection(_collectionName).doc(_currentUser?.uid).update({
      'defaultRouteMode': routeMode.name,
    });
  }

  @override
  Future<void> getDefaults(UserApp? userApp) async {
    _currentUser = FirebaseAuth.instance.currentUser;
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw NotAuthenticatedUserException();
    }

    try {
      final querySnapshot =
          await db.collection(_collectionName).doc(_currentUser?.uid).get();

      if (querySnapshot.exists) {
        var data = querySnapshot.data();
        if (data != null) {
          userApp?.defaultTransportMode = TransportMode.values
              .firstWhere((e) => e.name == data['defaultTransportMode']);
          userApp?.defaultTransportMode = data['defaultTransportMode'] != null
              ? TransportMode.values
                  .firstWhere((e) => e.name == data['defaultTransportMode'])
              : TransportMode.noSeleccionado;
          userApp?.defaultRouteMode = RouteMode.values
              .firstWhere((e) => e.name == data['defaultRouteMode']);
          userApp?.defaultRouteMode = data['defaultRouteMode'] != null
              ? RouteMode.values
                  .firstWhere((e) => e.name == data['defaultRouteMode'])
              : RouteMode.noSeleccionado;
          userApp?.vehicledefault = data['vehicleDefault'] != null
              ? Vehicle.fromMap(data['vehicleDefault'])
              : null;
        }
        // Aquí puedes hacer algo con userApp si es necesario
      } else {
        throw UserNotExistException();
      }
    } catch (e) {
      throw ConnectionBBDDException();
    }
  }
}
