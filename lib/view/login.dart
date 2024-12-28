import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/view/createUserView.dart';
import 'package:flutter/material.dart';
import 'package:WayFinder/view/errorPage.dart';
import 'package:WayFinder/view/map_screen.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/mapa.PNG',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho de la pantalla
              constraints: BoxConstraints(
                maxWidth: 700, // Ancho máximo
                maxHeight: 700, // Alto máximo
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: login(),
            ),
          ),
        ],
      ),
    );
  }

  Widget login() {
    return SingleChildScrollView( // Permite desplazamiento si el contenido es demasiado grande
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          nombre(),
          campoUsuario(),
          const SizedBox(height: 15),
          contrasena(),
          campoContraena(),
          const SizedBox(height: 15),
          botonEntrar(),
          const SizedBox(height: 15),
          nuevaCuenta(),
        ],
      ),
    );
  }

  Widget nombre() {
    return Text(
      "Usuario",
      style: Theme.of(context).textTheme.headlineSmall,
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
    return Text(
      "Contraseña",
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget campoContraena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Contraseña",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget botonEntrar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 147, 164, 173),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        textStyle: const TextStyle(fontSize: 18),
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

  Widget nuevaCuenta() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CreateUserView()),
        );
      },
      child: const Text("¿No tienes cuenta?, ¡Clica aquí para hacerte una!"),
    );
  }

  // Iniciar sesión con Firebase en Flutter Web
  void _login() async {
    String email = _usuarioController.text;
    String password = _passwordController.text;

    try {
      UserAppController? userAppController = UserAppController.getInstance();
      UserApp? userApp = await userAppController.logInCredenciales(email, password);
      _usuarioController.clear();
      _passwordController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MapScreen(userApp: userApp)),
      );
    } on Exception {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(message: 'Ha surgido un error en el inicio de sesión')),
      );
    }
  }
}