import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/MissingInformationRouteException.dart';
import 'package:WayFinder/exceptions/NotAuthenticatedUserException.dart';
import 'package:WayFinder/exceptions/UserAlreadyExistsException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/exceptions/UserNotExistsExcpetion.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/routeMode.dart';
import 'package:WayFinder/model/transportMode.dart';
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
      : _collectionName = collectionName{
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

  @override
  void setTransportModeDefault(TransportMode transportMode, Vehicle? vehicle) {

    if (_currentUser == null) {
      throw UserNotAuthenticatedException();
    }

    if (transportMode == TransportMode.bicicleta ||
        transportMode == TransportMode.aPie) {
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
    throw UnimplementedError();
    /*
    if (_currentUser == null) {
      throw UserNotAuthenticatedException();
    }


    db.collection(_collectionName).doc(_currentUser?.uid).update({
      'defaultRouteMode': routeMode.name,

    });

    */

  }
}
