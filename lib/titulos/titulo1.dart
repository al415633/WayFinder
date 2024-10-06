import 'package:flutter/material.dart';

class Titulo1 extends StatelessWidget {
  final String texto;

  const Titulo1(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 24, // Ajusta el tamaño de la fuente según tus preferencias
        fontWeight: FontWeight.bold, // Puedes cambiar el peso de la fuente
        color: Colors.black, // Cambia el color si lo necesitas
      ),
    );
  }
}
