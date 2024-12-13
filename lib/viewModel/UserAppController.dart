import 'package:WayFinder/exceptions/ConnectionBBDDException.dart';
import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/NotValidEmailException.dart';
import 'package:WayFinder/exceptions/UserAlreadyExistsException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/exceptions/UserNotExistsExcpetion.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAppController {
  // Propiedad privada
  final DbAdapterUserApp repository;

  // Constructor privado
  UserAppController(this.repository);

  // Instancia única
  static UserAppController? _instance;

  static UserAppController getInstance([DbAdapterUserApp? repository]) {
    if (repository != null) {
      _instance ??= UserAppController(repository);
    }
    return _instance!;
  }

  bool isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9]+@(gmail|outlook|hotmail|yahoo)\.(com|es)$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final hasLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumeric = password.contains(RegExp(r'[0-9]'));
    final hasSpecial =
        password.contains(RegExp(r'[.,@$&*=\[¡#%^&()!,.?¿":{}|<>]'));

    return hasLength && hasUppercase && hasNumeric && hasSpecial;
  }

  Future<UserApp?> createUser(
      String email, String password, String name) async {
    //REGLAS DE NEGOCIO
    if (!isValidEmail(email)) {
      throw NotValidEmailException();
    }

    if (!isValidPassword(password)) {
      throw IncorrectPasswordException();
    }

    //CONECION AL REPOSITORIO

    UserApp? user = await repository.createUser(email, password);
    user?.setName = name;
    return user;
  }

  Future<UserApp?> logInCredenciales(String email, String password) async {
    if (!isValidEmail(email)) {
      throw NotValidEmailException();
    }

    if (!isValidPassword(password)) {
      throw IncorrectPasswordException();
    }
    return await repository.logInCredenciales(email, password);
  }

  Future<bool> logOut() async {
    return repository.logOut();
  }
}

class FirestoreAdapterUserApp implements DbAdapterUserApp {
  final String _collectionName;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirestoreAdapterUserApp({String collectionName = "production"})
      : _collectionName = collectionName;

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
      UserApp usuario=UserApp(user!.uid, user.displayName??'', email);
      usuario.setUser=user;
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
}

abstract class DbAdapterUserApp {
  Future<UserApp?> createUser(String email, String password);
  Future<UserApp?> logInCredenciales(String email, String password);
  Future<bool> logOut();
}
