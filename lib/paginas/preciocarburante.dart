import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrecioCarburante extends StatefulWidget {
  const PrecioCarburante({super.key});

  @override
  _PrecioCarburanteState createState() => _PrecioCarburanteState();
}

class _PrecioCarburanteState extends State<PrecioCarburante> {
  List estaciones = [];
  bool isLoading = true; // esto es el indicador para el ícono de carga

  @override
  void initState() {
    super.initState();
    fetchPrecioCarburante("Castellón de la Plana/Castelló de la Plana"); // Tras muchas búsquedas y prints, vemos que la API lo guarda con ese nombre
  }

  Future<void> fetchPrecioCarburante(String municipio) async {
    try {
      print("Hago la llamada a la API...");

      // Llamada a la API
      final response = await http.get(
        Uri.parse(
            'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/'),
      );

      // Verificar si el cuerpo de la respuesta no está vacío
      if (response.body.isNotEmpty) {
        // Si el código de estado es 200 (éxito)
        if (response.statusCode == 200) {
          try {
            // decodificamos JSON
            var datos = jsonDecode(response.body);

            // Verifica si existe el campo "ListaEESSPrecio"
            if (datos.containsKey('ListaEESSPrecio')) {
              // Filtrar por el municipio dado (Ajusta el nombre según lo que devuelva la API)
              List estacionesFiltradas = datos["ListaEESSPrecio"].where((estacion) {
                return estacion["Municipio"] == municipio;
              }).toList();

              // Actualizamos estado
              setState(() {
                estaciones = estacionesFiltradas;
                isLoading = false;
              });
            }
          } catch (e) {
            print("Excepción lanzada: $e");
            setState(() {
              estaciones = [];
              isLoading = false;
            });
          }
        } else {
          print("Error: código de estado inesperado: ${response.statusCode}");
          setState(() {
            estaciones = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Excepción lanzada: $e");
      setState(() {
        estaciones = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Precios de Carburantes'),
      ),
      body: estaciones.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: estaciones.length,
              itemBuilder: (context, index) {
                var estacion = estaciones[index];

                return ListTile(
                  title: Text(estacion["Rótulo"]),
                  subtitle: Text(
                    "Dirección: ${estacion['Dirección']}\n"
                    "Gasolina 95 E5: ${estacion['Precio Gasolina 95 E5'] ?? 'No disponible'} €\n"
                    "Gasolina 95 E10: ${estacion['Precio Gasolina 95 E10'] ?? 'No disponible'} €\n"
                    "Gasolina 95 E5 Premium: ${estacion['Precio Gasolina 95 E5 Premium'] ?? 'No disponible'} €\n"
                    "Gasolina 98 E5: ${estacion['Precio Gasolina 98 E5'] ?? 'No disponible'} €\n"
                    "Gasolina 98 E10: ${estacion['Precio Gasolina 98 E10'] ?? 'No disponible'} €\n"
                    "Gasóleo A: ${estacion['Precio Gasoleo A'] ?? 'No disponible'} €\n"
                    "Gasóleo B: ${estacion['Precio Gasoleo B'] ?? 'No disponible'} €\n"
                    "Gasóleo Premium: ${estacion['Precio Gasoleo Premium'] ?? 'No disponible'} €\n"
                    "Gases licuados del petróleo: ${estacion['Precio Gases licuados del petróleo'] ?? 'No disponible'} €\n"
                    "Gas Natural Comprimido: ${estacion['Precio Gas Natural Comprimido'] ?? 'No disponible'} €\n"
                    "Gas Natural Licuado: ${estacion['Precio Gas Natural Licuado'] ?? 'No disponible'} €",
                  ),
                );
              },
            ),
    );
  }
}
