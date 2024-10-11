import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrecioLuz extends StatefulWidget {
  const PrecioLuz({super.key});

  @override
  _PrecioLuzState createState() => _PrecioLuzState();
}

class _PrecioLuzState extends State<PrecioLuz> {
  // Variables de toda la clase
  List<Map<String, dynamic>> preciosLuz = []; // Lista para almacenar fecha y precio
  bool isLoading = true;
  String? precioActualLuz; // Variable para almacenar el precio actual


  @override
  void initState() {
    super.initState();
    fetchPrecioActual();
  
    fetchPrecioLuz();
  }

  // Función para obtener el precio actual de la luz
  Future<void> fetchPrecioActual() async {
    try {
      print("Hago la llamada para el precio actual");

      final response = await http.get(
        Uri.parse('https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=2024-10-11T00:00&end_date=2024-10-11T23:59&time_trunc=hour'),
      );

      print("Vuelvo sin excepciones - Precio Actual");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        final precioActual = decodedData['included'][0]['attributes']['values'].last['value'];

        setState(() {
          // Almacenamos el precio actual
          precioActualLuz = precioActual.toString();
          isLoading = false;
        });
      } else {
        setState(() {
          precioActualLuz = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Ha saltado una excepción al obtener el precio actual: $e");
      setState(() {
        precioActualLuz = null;
        isLoading = false;
      });
    }
  }

  // Función para obtener los precios por hora
  Future<void> fetchPrecioLuz() async {
    try {
      print("Hago la llamada para los precios por hora");

      final response = await http.get(
        Uri.parse('https://apidatos.ree.es/es/datos/mercados/precios-mercados-tiempo-real?start_date=2024-10-11T00:00&end_date=2024-10-11T23:59&time_trunc=hour'),
      );

      print("Vuelvo sin excepciones - Precios por hora");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON
        final decodedData = json.decode(response.body) as Map<String, dynamic>;
        final precios = decodedData['included'][0]['attributes']['values'];

        setState(() {
          // Iteramos sobre la lista para obtener la fecha y el precio
          preciosLuz = precios.map<Map<String, dynamic>>((entry) {
            var fecha = entry['datetime'];
            var precio = entry['value'];
            return {
              'fecha': fecha,
              'precio': precio,
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          preciosLuz = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Ha saltado una excepción: $e");
      setState(() {
        preciosLuz = [];
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Precio Luz"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mostrar el precio actual al principio
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      precioActualLuz != null
                          ? 'El precio actual de la luz es: $precioActualLuz €/MWh'
                          : 'No se pudo obtener el precio actual de la luz',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                 
                  // Mostrar la lista de precios por hora
                  Expanded(
                    child: preciosLuz.isEmpty
                        ? const Text('No hay datos disponibles')
                        : ListView.builder(
                            itemCount: preciosLuz.length,
                            itemBuilder: (context, index) {
                              var precioLuz = preciosLuz[index];
                              var fecha = precioLuz['fecha'];
                              var precio = precioLuz['precio'];

                              return ListTile(
                                title: Text("Fecha: $fecha"),
                                subtitle: Text('Precio Luz: $precio €/MWh'),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
