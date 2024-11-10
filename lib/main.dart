import 'package:flutter/material.dart';
import 'package:spike0/paginas/listamunicipios.dart';
import 'package:spike0/paginas/map_screen.dart';
import 'package:spike0/paginas/preciocarburanteIndice.dart';
import 'package:spike0/paginas/swatchpage.dart';
import 'paginas/iniciosesion.dart';
import 'paginas/pagina02.dart';
import 'paginas/preciocarburante.dart';
import 'paginas/precioluz.dart';
import 'paginas/registrarusuario.dart';

// IMPORT PARA LA BASE DE DATOS
import 'package:firebase_core/firebase_core.dart';

//IMPORT DE LA PLANTILLA
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
      authDomain: "wayfinder-df8eb.firebaseapp.com",
      projectId: "wayfinder-df8eb",
      storageBucket: "wayfinder-df8eb.appspot.com",
      messagingSenderId: "571791500413",
      appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
      measurementId: "G-TZLW8P5J8V",
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
