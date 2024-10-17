import 'package:flutter/material.dart';

//IMPORT PARA LA BASE DE DATOS
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spike0/paginas/errorpage.dart';
import 'package:spike0/paginas/exitopage.dart';
import 'package:spike0/paginas/registrarusuario.dart';



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
      appBar: AppBar(
        title: Text('Inicio de sesión'),
      ),
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
        MaterialPageRoute(builder: (context) => RegistroUsuario()),
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
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print("Inicio de sesión exitoso: ${userCredential.user?.email}");
    
    // Limpiar los campos de usuario y contraseña después del inicio de sesión exitoso
    _usuarioController.clear();
    _passwordController.clear();
    
    // Navegar a la página de éxito
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExitoPage()),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      // Si las credenciales son incorrectas, navegar a la página de error
      print('Credenciales incorrectas.');
    }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ErrorPage()), // Cambia a la página de error
      );
    
  }
}




}
