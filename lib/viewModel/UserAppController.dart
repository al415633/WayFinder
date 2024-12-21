import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/NotValidEmailException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/exceptions/UserNotExistsExcpetion.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/enum/routeMode.dart';
import 'package:WayFinder/model/enum/transportMode.dart';
import 'package:WayFinder/model/vehicle.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
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

  Future<UserApp?> getActualUser() async {
    return await repository.getActualUser();
  }

  void setTransportModeDefault(
      UserApp? userApp, TransportMode transportMode, Vehicle? vehicle) {
    if (userApp == null) {
      throw UserNotAuthenticatedException();
    }
    repository.setTransportModeDefault(transportMode, vehicle);
    userApp.setDefaultTransportMode = transportMode;
    userApp.setVehicleDefault = vehicle;
  }

  TransportMode getTransportModeDefault(UserApp? userApp){
    if (userApp == null) {
      throw UserNotAuthenticatedException();
    }
    return userApp.getDefaultTransportMode;
  }

    Vehicle getVehicleDefault(UserApp? userApp){
    if (userApp == null) {
      throw UserNotAuthenticatedException();
    }
    return userApp.getVehicleDefault!;
  }



  void setRouteModeDefault(UserApp? userApp, RouteMode routeMode) {
    if (userApp == null) {
      throw UserNotAuthenticatedException();
    }
    repository.setRouteModeDefault(routeMode);
    userApp.setDefaultRouteMode = routeMode;
  }

  RouteMode getRouteModeDefault(UserApp? userApp){
    if (userApp == null) {
      throw UserNotAuthenticatedException();
    }
    return userApp.getDefaultRouteMode;
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

  Future<void> deleteAccount() async {
    try {
      await repository.deleteAccount();
    } catch (e) {
      if (e is UserNotAuthenticatedException) {
        throw UserNotAuthenticatedException();
      } else {
        rethrow;
      }
    }
  }

  Future<void> deleteAccountForEmail(String email) async {
    if (!(await checkIfUserExists(email))) {
      throw UserNotExistException();
    }
    await repository.deleteAccountForEmail(email);
  }

  Future<bool> checkIfUserExists(String email) async {
    if (!isValidEmail(email)) {
      throw NotValidEmailException();
    }

    try {
      return await repository.checkIfUserExists(email);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> getDefaults(UserApp? userApp) async {
      return await repository.getDefaults(userApp);
    }
}
