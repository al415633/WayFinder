import 'package:flutter/material.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Ejemplo de los Estilos', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de ejemplo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Este es un ejemplo de tarjeta (Card)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Botón elevado de ejemplo
            ElevatedButton(
              onPressed: () {},
              child: Text('Botón Elevado'),
            ),
            SizedBox(height: 20),

            // Campo de entrada (Input Field) de ejemplo
            TextField(
              decoration: InputDecoration(
                labelText: 'Introduce algo',
              ),
            ),
            SizedBox(height: 20),

            // Ejemplo de icono
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home),
                SizedBox(width: 10),
                Icon(Icons.settings),
                SizedBox(width: 10),
                Icon(Icons.location_on),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
