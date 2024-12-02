import 'package:WayFinder/APIs/apiConection.dart';
import 'package:WayFinder/view/createUserView.dart';
import 'package:WayFinder/view/errorPage.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';

import 'package:WayFinder/view/map_screen.dart';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

// IMPORT PARA LA BASE DE DATOS

//IMPORT DE LA PLANTILLA
import 'themes/app_theme.dart';

late UserAppController userAppController;
void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar la configuración desde firebase_config.json
  //final response = await http.get(Uri.parse('/firebase_config.json'));
  //final config = json.decode(response.body);
    
  await firebaseConnection();
  await initializeControllers();

  runApp(MiApp(userAppController));
}

Future<void> initializeControllers() async {
  final repository = FirestoreAdapterUserApp(collectionName: "production");
  userAppController = UserAppController.getInstance(repository);
}

class MiApp extends StatelessWidget {
  final UserAppController userAppController;

  const MiApp(this.userAppController, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WayFinder",
      theme: AppTheme.lightTheme,
      home: const Inicio(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  _InicioState createState() => _InicioState();
}


class _InicioState extends State<Inicio> {
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
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
      body: login(),
      //body: MapScreen(),
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
            const SizedBox(height: 15), // separacion para que quede bonito

            contrasena(),
            campoContraena(),
            const SizedBox(height: 15), // separacion para que quede bonito
            
            botonEntrar(),
            const SizedBox(height: 15), // separacion para que quede bonito

            nuevaCuenta(),

          ],
        ),
      ),
    );
  }


   Widget nombre() {
    return Text(
      "Usuario",
      style: Theme.of(context).textTheme.headlineSmall,  // Aplica el estilo headlineSmall del tema
    );
  }

  Widget campoUsuario() { //TextField para escribir el nombre del usurio
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _usuarioController, // Asignar el controlador al campo de usuario
        decoration: const InputDecoration(
          hintText: "Email",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget contrasena() {
    return  Text(
      "Contraseña",
      style: Theme.of(context).textTheme.headlineSmall,  // Aplica el estilo headlineSmall del tema
    );
  }

  Widget campoContraena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _passwordController, // Asignar el controlador al campo de contraseña
        obscureText: true, // Ocultar el texto para la contraseña
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


 Widget nuevaCuenta() {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateUserView()),
      );
    },
    child: const Text("No tienes cuenta?, ¡Clica aquí para hacerte una!"),
  );
}



// Iniciar sesión con Firebase en Flutter Web
void _login() async {
  String email = _usuarioController.text;
  String password = _passwordController.text;

  try {
    
    UserAppController? userAppController = UserAppController.getInstance();

    await userAppController?.logInCredenciales(email, password);
    _usuarioController.clear();
    _passwordController.clear();

     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
  } on Exception {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage(message: 'Ha surgido un error en el inicio de sesión',)), 
      );
    
  }
}




 
}