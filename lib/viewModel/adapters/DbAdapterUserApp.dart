import 'package:WayFinder/model/UserApp.dart';

abstract class DbAdapterUserApp {
  Future<UserApp?> createUser(String email, String password);
  Future<UserApp?> logInCredenciales(String email, String password);
  Future<bool> logOut();
}