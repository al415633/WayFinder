import 'package:flutter/material.dart';
import 'package:WayFinder/titulos/titulo1.dart';

class Pagina02 extends StatelessWidget {
  const Pagina02({super.key}); // const significa que es inmutable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Términos y condiciones"),
      ),
      body: SingleChildScrollView(
        // Permite el desplazamiento
        child: Padding(
          // Ctrl + . en Column para poner márgenes
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ocupa solo el espacio necesario
            children: <Widget>[
              const Titulo1("Tienes que aceptar los términos y condiciones"),
              const SizedBox(height: 10), // Espacio entre el título y el texto
              const Text(
                "Tienes que aceptar los términos y condiciones",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              const Text("Tienes que aceptar los términos y condiciones"),
              ElevatedButton(
                onPressed: () {
                  // Guardar registro en una base de datos
                  print("Vuelvo");
                  Navigator.pop(context); // Regresar a la pantalla anterior
                  //NAVIGATOR = TIENE UN HISTORIAL DE RUTAS QUE SE HAN VISITADO
                  //Navigator.push(context, route): Agrega una nueva ruta a la pila. Se utiliza para navegar a una nueva pantalla.
                  //Navigator.pop(context): Elimina la ruta superior de la pila, volviendo a la pantalla anterior.
                  //CONTEXT=El context se utiliza con el Navigator para saber en qué parte de la pila de rutas te encuentras.
                },
                child: const Row( // Usamos un Row para tener múltiples hijos en el botón
                  mainAxisAlignment: MainAxisAlignment.center, // Centra los hijos
                  children: [
                    Text("Acepto todo"), 
                    SizedBox(width: 8), // Espacio entre el texto y el ícono
                    Icon(Icons.arrow_back_ios),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



