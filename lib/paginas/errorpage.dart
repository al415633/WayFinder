import 'package:flutter/material.dart';
import 'package:spike0/titulos/titulo1.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Error de Credenciales")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Titulo1(
              "Credenciales incorrectas",
      
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  // Guardar registro en una base de datos
                  print("Volver al inicio");
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
    );
  }
}
