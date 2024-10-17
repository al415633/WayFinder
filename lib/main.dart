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

// IMPORT PARA LA BBDD CON FIREBASE
import 'package:firebase_core/firebase_core.dart';

// IMPORT PARA EL THEME UTILIZADO
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Asegúrate de pasar las opciones específicas de Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
      authDomain: "wayfinder-df8eb.firebaseapp.com",
      projectId: "wayfinder-df8eb",
      storageBucket: "wayfinder-df8eb.appspot.com",
      messagingSenderId: "571791500413",
      appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
      measurementId:
          "G-TZLW8P5J8V", // Esto es opcional, depende de si usas Analytics
    ),
  );

  runApp(MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key}); //const significa que es inmutable

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "WayFinder",
      theme: AppTheme.lightTheme, // Aplica el tema definido, se aplica sobre la pagina principal para poder usarlo en las demás!!!
      home: const Inicio(),
      debugShowCheckedModeBanner: false,  // Oculta la dichosa etiqueta que pone "DEBUG"

    ); //Patron de diseño de Googe para crrear apps
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key}); //? significa que acepta nulos

  @override
  _InicioState createState() => _InicioState();
}

//Cuando estas haciendo la parte del front casi todo funciona con comas
//Cuando te pones ha codificar funciones... Cada vez que escribes una linea al final ;

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Spike 0"),
        ),
        body: ListView(
            //Ctrl+ . Y wrap with column y cambiar el nombre por ListView, sino no deja hacer scroll
            children: <Widget>[
              const SizedBox(height: 50),

              SizedBox(
                width: 50,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pagina02(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página ejemplo "),  // El texto del botón
                ),
              ),


              const SizedBox(height: 50),

              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamplePage(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página ejemplo de los estilos"),  // El texto del botón
                ),
              ),

              const SizedBox(height: 50),
              
              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrecioLuz(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página precio luz"),  // El texto del botón
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrecioCarburante(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página precio carburante"),  // El texto del botón
                ),
              ),


              const SizedBox(height: 50),
               
              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListaMunicipiosPage(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página listado de municipios para precios carburante"),  // El texto del botón
                ),
              ),


              const SizedBox(height: 50),
               
              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreciosMunicipioIndicePage(idMunicipio: '1842', nombreMunicipio: 'Castellón de la Plana/Castelló de la Plana') // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página precio carburante buscado por índice"),  // El texto del botón
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InicioSesion(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página inicio de sesión"),  // El texto del botón
                ),
              ),


              const SizedBox(height: 50),

              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroUsuario(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página registro nuevo usuario"),  // El texto del botón
                ),
              ),


              const SizedBox(height: 50),
               
              SizedBox(
                width: 250,  // ancho del botón aquí
                child: ElevatedButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(), // Página a la que navegas
                      ),
                    )
                  },
                  child: Text("Página mapa"),  // El texto del botón
                ),
              ),
        


                  
            ]));
  }
}
