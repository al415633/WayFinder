import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/NotValidEmailException.dart';
import 'package:WayFinder/exceptions/UserAlreadyExistsException.dart';
import 'package:WayFinder/main.dart';
import 'package:WayFinder/view/errorPage.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:flutter/material.dart';
//IMPORT PARA LA BASE DE DATOS


class CreateUserView extends StatefulWidget {
  const CreateUserView({super.key});

  @override
  _CreateUserViewState createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> {

  final TextEditingController _userEnter = TextEditingController();
  final TextEditingController _userNameEnter = TextEditingController();
  final TextEditingController _passwordEnter = TextEditingController();
  final TextEditingController _confirmPasswordEnter = TextEditingController();
  
 String _errorMessage = '';
  final Map<String, bool> _passwordValidation = {
    "length": false,
    "uppercase": false,
    "numeric": false,
    "special": false,
  };
  bool _showPasswordValidation = false; //  variable para controlar cuándo mostrar los requisitos

  @override
  void dispose() {
    _userEnter.dispose();
    _userNameEnter.dispose();
    _passwordEnter.dispose();
    _confirmPasswordEnter.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Registro nuevo usuario'),
      ),
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
            const SizedBox(height: 15), // separacion para que quede bonito

            nombreUsuario(),
            campoNombre(),

            contrasena(),
            campoContrasena(),
            if (_showPasswordValidation) validarContrasena(), // Mostrar validación solo si es necesario
            const SizedBox(height: 15), // separacion para que quede bonito

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
    return  Text(
      "Email",
      style: Theme.of(context).textTheme.headlineSmall,  // Aplica el estilo headlineSmall del tema
    );
  }

  Widget campoUsuario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _userEnter,
        decoration: const InputDecoration(
          hintText: "Email",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

 Widget nombreUsuario() {
    return  Text(
      "Nombre de usuario",
      style: Theme.of(context).textTheme.headlineSmall,  // Aplica el estilo headlineSmall del tema
    );
  }

    Widget campoNombre() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _userNameEnter,
        decoration: const InputDecoration(
          hintText: "Nombre de usuario",
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

  Widget campoContrasena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _passwordEnter,
        obscureText: true,
        onChanged: _validatePassword,  // Validar la contraseña en tiempo real
        decoration: const InputDecoration(
          hintText: "Contraseña",
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  // Mensajes de validación de la contraseña
  Widget validarContrasena() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        validacionTexto("Al menos 8 caracteres", _passwordValidation["length"]!),
        validacionTexto("Al menos una mayúscula", _passwordValidation["uppercase"]!),
        validacionTexto("Al menos un número", _passwordValidation["numeric"]!),
        validacionTexto("Al menos un carácter especial", _passwordValidation["special"]!),
      ],
    );
  }

  // Formato para mostrar la validación en verde o rojo, dependiendo de los reuisitos que sí cumple y los que no
  Widget validacionTexto(String texto, bool valido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(
            valido ? Icons.check_circle : Icons.cancel,
            color: valido ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: TextStyle(
              color: valido ? Colors.green : Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget repetirContrasena() {
      return  Text(
        "Por favor confirma la contraseña",
      style: Theme.of(context).textTheme.headlineSmall,  // Aplica el estilo headlineSmall del tema
      );
    }

     Widget confirmarContrasena() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: TextField(
        controller: _confirmPasswordEnter,
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


    // Valida si la contraseña cumple con los requisitos
  bool _validatePassword(String password) {
    setState(() {
      _passwordValidation["length"] = password.length >= 8;
      _passwordValidation["uppercase"] = password.contains(RegExp(r'[A-Z]'));
      _passwordValidation["numeric"] = password.contains(RegExp(r'[0-9]'));
      _passwordValidation["special"] = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });

    // Verificar si todos los requisitos son verdaderos
    return !_passwordValidation.containsValue(false);
}



















 void _register() async {
    String email = _userEnter.text;
    String name = _userNameEnter.text;
    String password = _passwordEnter.text;
    String confirmPassword = _confirmPasswordEnter.text;
     _showPasswordValidation = true;


    // Verificar que las contraseñas coincidan y que la contraseña cumpla con los requisitos
    if (password.trim() != confirmPassword.trim()) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
        _showPasswordValidation = false;
      });
      return;
    }



    if (!_validatePassword(password)) {
      // Si la contraseña no es válida, mostrar los mensajes de validación
      setState(() {
        _showPasswordValidation = true;
      
        _errorMessage = 'La contraseña no cumple con los requisitos.';
      });
   
      return;
    }
   try {
    
    UserAppController? userAppController = UserAppController.getInstance();

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Inicio()),
  );
} on NotValidEmailException {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ErrorPage(message: 'Email no válido')),
  );
} on IncorrectPasswordException {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ErrorPage(message: 'Contraseña no válida')),
  );
} on UserAlreadyExistsException {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ErrorPage(message: 'El usuario ya existe')),
  );
} catch (e) {
  // Manejar cualquier otro error
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ErrorPage(message: 'Error desconocido')),
  );
}
  }



}