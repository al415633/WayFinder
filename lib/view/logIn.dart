import 'package:WayFinder/view/map_screen.dart';
import 'package:flutter/material.dart';

class LogIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

     // Navegar a la página de éxito
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
