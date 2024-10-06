import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrecioLuz extends StatefulWidget {
  const PrecioLuz({super.key});

  @override
  _PrecioLuzState createState() => _PrecioLuzState();
}

class _PrecioLuzState extends State<PrecioLuz> {
  List<Map<String, dynamic>> preciosLuz = []; // Lista para almacenar fecha y precio
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrecioLuz();
  }

  Future<void> fetchPrecioLuz() async {
    try {
      print("Hago la llamada");
      final response = await http.get(
        Uri.parse(
            'https://cors-anywhere.herokuapp.com/https://api.preciodelaluz.org/v1/prices/all?zone=PCB'),
      );

      print("Vuelvo sin excepciones");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Precio Luz"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : preciosLuz.isEmpty
                ? const Text('No hay datos disponibles')
                : ListView.builder(
                    itemCount: preciosLuz.length,
                    itemBuilder: (context, index) {
                      // Accedemos a los datos de fecha y precio
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
                            TextSpan(text: 'Precio Luz: $precio €/MWh\n'),
                            TextSpan(text: 'Hora: $hora\n'),
                            TextSpan(text: 'Mercado: $mercado '),
                          ],
                        ),
                      ),
                  );
                    },
                  ),
      ),
    );
  }
}
