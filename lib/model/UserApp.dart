import 'package:firebase_auth/firebase_auth.dart';

class UserApp {
  late String id;
  late String name;
  late String email;
  late User? user;

  // Constructor
  UserApp(this.id, this.name, this.email);

  // Getters
  String get getId => id;
  String get getName => name;
  String get getEmail => email;
  User? get getUser => user;


  // Setters
  set setId(String id) => this.id = id;
  set setName(String name) => this.name = name;
  set setEmail(String email) => this.email = email;
  set setUser(User? user) => this.user = user;


  // Método toString
  @override
  String toString() {
    return 'User name: $name, email: $email';
  }
}