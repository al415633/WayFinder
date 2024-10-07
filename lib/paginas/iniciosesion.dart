import 'package:flutter/material.dart';

//IMPORT PARA LA BASE DE DATOS
import 'package:spike0/servicios/database_service.dart';
//IMPORT PARA ENCRIPTAR
import 'package:bcrypt/bcrypt.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  _InicioSesionState createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  // Me guardo en los controladores el usuario y contra apara poder luego mandarlos a la BBDD y verificar si esta bien
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    // Libera los controladores cuando ya no se necesiten
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: login(),
    );
  }


  Widget login() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nombre(),
            campoUsuario(),
            contrasena(),
            campoContraena(),
            const SizedBox(height: 15), // separacion para que quede bonito
            botonEntrar()
          ],
        ),
      ),
    );
  }

  Widget nombre() {
    return const Text(
      "Sign in",
      style: TextStyle(color: Colors.black, fontSize: 35.0, fontWeight: FontWeight.bold),
    );
  }

  Widget campoUsuario() { //TextField para escribir el nombre del usurio
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _usuarioController, // Asignar el controlador al campo de usuario
        decoration: const InputDecoration(
          hintText: "User",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget contrasena() {
    return const Text(
      "Contraseña",
      style: TextStyle(color: Colors.black, fontSize: 35.0, fontWeight: FontWeight.bold),
    );
  }

  Widget campoContraena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _passwordController, // Asignar el controlador al campo de contraseña
        obscureText: true, // Ocultar el texto para la contraseña
        decoration: const InputDecoration(
          hintText: "Password",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget botonEntrar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 147, 164, 173), // Cambia el color de fondo del botón
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10), // Ajusta el padding
        textStyle: const TextStyle(fontSize: 18), // Opcional: ajusta el estilo del texto
      ),
      onPressed: () {
        
       _login(); // Llamada a la función de login

      },
      child: const Text(
        "Iniciar sesión",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),
    );
  }



  void _login() async {

    print("Botón presionado");
    DatabaseService db = DatabaseService();

    // Conectar a la base de datos
    await db.connect();
    print("Conexión establecida con la base de datos.");

    // Obtener usuario y contraseña de los controladores
    String usuario = _usuarioController.text;
    String password = _passwordController.text;

    // Mostrar los valores en consola
    print("Usuario: $usuario");
    print("Contraseña: $password");

    // Limpiar los campos de texto, para que quede mas bonitoooo
    _usuarioController.clear();
    _passwordController.clear();

    // Obtener el hash almacenado de la base de datos
    String? hashedPassword = await db.obtenerHash(usuario); // se pone un ? porque puede devolver null


    print("Hash de contraseña obtenido: $hashedPassword");

    // PIDO AL SERVICIO DE BBDD QUE ME DIGA SI LAS CREDENCIALES SON CORRECTAS
    if (hashedPassword != null) {
    // Verificar si la contraseña ingresada coincide con el hash
    bool esCorrecto = BCrypt.checkpw(password, hashedPassword);

    if (esCorrecto) {
      print("Contraseña correcta. Inicio de sesión exitoso.");
    } else {
      print("Contraseña incorrecta.");
      }
    } else {
      print("Usuario no encontrado.");
    }
  }


}
