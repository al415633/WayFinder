import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spike0/paginas/errorpage.dart';
import 'package:spike0/paginas/exitopage.dart';

class RegistroUsuario extends StatefulWidget {
  const RegistroUsuario({super.key});

  @override
  _RegistroUsuarioState createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: registro(),
    );
  }

  Widget registro() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nombre(),
            campoUsuario(),
            contrasena(),
            campoContrasena(),
            repetirContrasena(),
            confirmarContrasena(),
            const SizedBox(height: 15),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red), // Mensaje de error
            ),
            botonRegistrar()
          ],
        ),
      ),
    );
  }

  Widget nombre() {
    return const Text(
      "Registrar",
      style: TextStyle(color: Colors.black, fontSize: 35.0, fontWeight: FontWeight.bold),
    );
  }

  Widget campoUsuario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _usuarioController,
        decoration: const InputDecoration(
          hintText: "Email",
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

  Widget campoContrasena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Password",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget repetirContrasena() {
      return const Text(
        "Por favor confirma la contraseña",
        style: TextStyle(color: Colors.black, fontSize: 35.0, fontWeight: FontWeight.bold),
      );
    }

     Widget confirmarContrasena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Password",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget botonRegistrar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 147, 164, 173),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        _register(); // Llamada a la función de registro
      },
      child: const Text(
        "Registrar",
        style: TextStyle(fontSize: 25, color: Colors.white),
      ),
    );
  }

  // Registro de un nuevo usuario con Firebase
  void _register() async {
    String email = _usuarioController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden'; // Actualizar el mensaje de error
      });
      return; // Salir de la función si las contraseñas no coinciden
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("Registro exitoso: ${userCredential.user?.email}");
      
      // Limpiar los campos de usuario y contraseña
      _usuarioController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      
      // Navegar a la página de éxito
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ExitoPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña es demasiado débil.');
      } else if (e.code == 'email-already-in-use') {
        print('Ya existe una cuenta con ese correo electrónico.');
      }
      // Navegar a la página de error
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage()), // Cambia a la página de error
      );
    }
  }
}
