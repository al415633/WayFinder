import 'package:flutter/material.dart';
import 'package:WayFinder/paginas/listamunicipios.dart';
import 'package:WayFinder/paginas/map_screen.dart';
import 'package:WayFinder/paginas/preciocarburanteIndice.dart';
import 'package:WayFinder/paginas/swatchpage.dart';
import 'paginas/iniciosesion.dart';
import 'paginas/pagina02.dart';
import 'paginas/preciocarburante.dart';
import 'paginas/precioluz.dart';
import 'paginas/registrarusuario.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

// IMPORT PARA LA BASE DE DATOS

//IMPORT DE LA PLANTILLA
import 'themes/app_theme.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar la configuración desde firebase_config.json
  final response = await http.get(Uri.parse('/firebase_config.json'));
  final config = json.decode(response.body);

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config['apiKey'],
      authDomain: config['authDomain'],
      projectId: config['projectId'],
      storageBucket: config['storageBucket'],
      messagingSenderId: config['messagingSenderId'],
      appId: config['appId'],
      measurementId: config['measurementId'],
    ),
  );

  runApp(MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

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
  // creo un metodo para que me establezca un boton y no tenga codigo repetido
  Widget buildButton(String text, Widget nextPage) {
    return Center(
      child: SizedBox(
        width: 550,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => nextPage),
            );
          },
          child: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Spike 0"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50),
          buildButton("Página ejemplo", Pagina02()),
          const SizedBox(height: 50),
          buildButton("Página ejemplo de los estilos", ExamplePage()),
          const SizedBox(height: 50),
          buildButton("Página precio luz", PrecioLuz()),
          const SizedBox(height: 50),
          buildButton("Página precio carburante", PrecioCarburante()),
          const SizedBox(height: 50),
          buildButton("Página listado de municipios para precios carburante", ListaMunicipiosPage()),
          const SizedBox(height: 50),
          buildButton(
            "Página precio carburante buscado por índice",
            PreciosMunicipioIndicePage(
              idMunicipio: '1842',
              nombreMunicipio: 'Castellón de la Plana/Castelló de la Plana',
            ),
          ),
          const SizedBox(height: 50),
          buildButton("Página inicio de sesión", InicioSesion()),
          const SizedBox(height: 50),
          buildButton("Página registro nuevo usuario", RegistroUsuario()),
          const SizedBox(height: 50),
          buildButton("Página mapa", MapScreen()),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
