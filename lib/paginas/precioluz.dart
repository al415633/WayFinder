import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrecioLuz extends StatefulWidget {
  const PrecioLuz({super.key});

  @override
  _PrecioLuzState createState() => _PrecioLuzState();
}

class _PrecioLuzState extends State<PrecioLuz> {
  //Variables de toda la clase
  List<Map<String, dynamic>> preciosLuz = []; // Lista para almacenar fecha y precio
  bool isLoading = true;
  String? precioActualLuz; // Variable para almacenar el precio actual
  String? precioMedioLuz; // Variable para almacenar el precio medio del dia

  @override
//Orden de ejecución de los metodos (como el main)
  void initState() {
    super.initState();
    fetchPrecioActual();
    fetchPrecioMedio();
    fetchPrecioLuz();
  }

  // Función para obtener el precio actual de la luz
  Future<void> fetchPrecioActual() async {
    try {
      print("Hago la llamada para el precio actual");

      final response = await http.get(
        Uri.parse(
            'https://cors-anywhere.herokuapp.com/https://api.preciodelaluz.org/v1/prices/now?zone=PCB'),
      );

      print("Vuelvo sin excepciones - Precio Actual");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          // Almacenamos el precio actual
          precioActualLuz = decodedData['price'].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          precioActualLuz = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Ha saltado una excepcion al obtener el precio actual: $e");
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
        Uri.parse(
            'https://cors-anywhere.herokuapp.com/https://api.preciodelaluz.org/v1/prices/all?zone=PCB'),
      );

      print("Vuelvo sin excepciones - Precios por hora");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        // Decodificamos la respuesta JSON
        final decodedData = json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          // Iteramos sobre el mapa para obtener la fecha y el precio
          preciosLuz = decodedData.entries.map((entry) {
            var fecha = entry.value['date'];
            var precio = entry.value['price'];
            var hora = entry.value['hour'];
            var mercado = entry.value['market'];
            return {
              'fecha': fecha,
              'precio': precio,
              'hora': hora,
              'mercado': mercado,
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
      print("Ha saltado una excepcion: $e");
      setState(() {
        preciosLuz = [];
        isLoading = false;
      });
    }
  }

  // Función para obtener el precio MEDIO DURANTE EL DIA de la luz
  Future<void> fetchPrecioMedio() async {
    try {
      print("Hago la llamada para el precio medio");

      final response = await http.get(
        Uri.parse(
            'https://cors-anywhere.herokuapp.com/https://api.preciodelaluz.org/v1/prices/avg?zone=PCB'),
      );

      print("Vuelvo sin excepciones - Precio Medio");
      print("Código de estado: ${response.statusCode}");
      print("Cuerpo de la respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body) as Map<String, dynamic>;

        setState(() {
          // Almacenamos el precio medio
          precioMedioLuz = decodedData['price'].toString();
          isLoading = false;
        });
      } else {
        setState(() {
          precioMedioLuz = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Ha saltado una excepcion al obtener el precio medio: $e");
      setState(() {
        precioMedioLuz = null;
        isLoading = false;
      });
    }
  }








///LO QUE SE VE EN PANTALLA
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
                  ),Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      precioMedioLuz != null
                          ? 'El precio medio de la luz es: $precioMedioLuz €/MWh'
                          : 'No se pudo obtener el precio medio de la luz',
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
                              var hora = precioLuz["hora"];
                              var mercado = precioLuz["mercado"];

                              return ListTile(
                                title: Text("Fecha: $fecha"),
                                subtitle: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Precio Luz: $precio €/MWh\n'),
                                      TextSpan(text: 'Hora: $hora\n'),
                                      TextSpan(text: 'Mercado: $mercado '),
                                    ],
                                  ),
                                ),
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
