import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreciosMunicipioIndicePage extends StatefulWidget {
  final String idMunicipio;
  final String nombreMunicipio;

  PreciosMunicipioIndicePage({required this.idMunicipio, required this.nombreMunicipio});

  @override
  _PreciosMunicipioIndicePageState createState() => _PreciosMunicipioIndicePageState();
}

class _PreciosMunicipioIndicePageState extends State<PreciosMunicipioIndicePage> {
  late Future<List<EstacionCarburante>> futurePrecios;

  @override
  void initState() {
    super.initState();
    futurePrecios = fetchPreciosCarburante(widget.idMunicipio);
  }

  Future<List<EstacionCarburante>> fetchPreciosCarburante(String idMunicipio) async {
    final url =
        'https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroMunicipio/$idMunicipio';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> estacionesList = jsonResponse['ListaEESSPrecio'];
      return estacionesList.map((json) => EstacionCarburante.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los precios de carburantes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Precios en ${widget.nombreMunicipio}'),
      ),
      body: FutureBuilder<List<EstacionCarburante>>(
        future: futurePrecios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final estacion = snapshot.data![index];
                return ListTile(
                  title: Text(estacion.nombreEstacion),
                  subtitle: Text(
                    "Gasolina 95 E5: ${estacion.precioGasolina95E5 ?? 'No disponible'} €\n"
                    "Gasolina 98: ${estacion.precioGasolina98 ?? 'No disponible'} €\n"
                    "Gasóleo A: ${estacion.precioGasoleoA ?? 'No disponible'} €",
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron estaciones de servicio.'));
          }
        },
      ),
    );
  }
}

class EstacionCarburante {
  final String nombreEstacion;
  final String? precioGasolina95E5;
  final String? precioGasolina98;
  final String? precioGasoleoA;

  EstacionCarburante({
    required this.nombreEstacion,
    this.precioGasolina95E5,
    this.precioGasolina98,
    this.precioGasoleoA,
  });

  factory EstacionCarburante.fromJson(Map<String, dynamic> json) {
    return EstacionCarburante(
      nombreEstacion: json['Rótulo'] ?? 'Desconocido',
      precioGasolina95E5: json['Precio Gasolina 95 E5'],
      precioGasolina98: json['Precio Gasolina 98 E5'],
      precioGasoleoA: json['Precio Gasoleo A'],
    );
  }
}
