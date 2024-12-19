import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/NotValidEmailException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';

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



