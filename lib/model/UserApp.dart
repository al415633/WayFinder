class UserApp {
  late String id;
  late String name;
  late String email;

  // Constructor
  UserApp(this.id, this.name, this.email);

  // Getters
  String get getId => id;
  String get getName => name;
  String get getEmail => email;

  // Setters
  set setId(String id) => this.id = id;
  set setName(String name) => this.name = name;
  set setEmail(String email) => this.email = email;

  // Método toString
  @override
  String toString() {
    return 'User name: $name, email: $email';
  }
}