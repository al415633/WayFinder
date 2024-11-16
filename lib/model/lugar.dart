import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:WayFinder/model/coordenada.dart';
import 'package:WayFinder/paginas/api_ops.dart';

class Lugar {
  // Propiedades

late Coordenada coordenada;
late String toponimo;
late String apodo;
late bool fav;

  // Constructor
  Lugar(double lat, double long, String apodo) {
    coordenada = Coordenada(lat, long);
    toponimo = traduceCoordATop(coordenada) as String;
    this.apodo = apodo;
    fav = false;
  }

  Lugar.fromTopnimo(String toponimo, String apodo) {
    this.toponimo = toponimo;
    coordenada = traduceTopACoord(toponimo) as Coordenada;
    this.apodo = apodo;
    fav = false;
  }

  // Método para pasar de Coordenadas a toponimo
  Future<String?> traduceCoordATop(Coordenada coord) async{
    String topo = "";

    http.Response? response;
   
    response = await http.get(getToponimoLugar(coord));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'].isNotEmpty) {
        final name = data['features'][0]['properties']['label'];
        return name; // Retorna el nombre del lugar
      } else {
        print('No se encontró ningún lugar para las coordenadas dadas.');
        return null;
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return null;
    }


  return topo;
  }

  Coordenada getCoordenada(){
    return this.coordenada;
  }

  String getToponimo() {
    return this.toponimo;
  }


  String getApodo() {
    return this.apodo;
  }

  bool getFav() {
    return this.fav;
  }

  // Método para pasar de  toponimo a Coordenadas
  //TO DO: Revisar los nulos y que en vez de eso mande excepción 
  Future<Coordenada?> traduceTopACoord(String topo)  async {
    http.Response? response;
   
    response = await http.get(getCoordenadasLugar(topo));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['features'].isNotEmpty) {
        final coords = data['features'][0]['geometry']['coordinates'];
        return Coordenada(coords[1], coords[0]); // latitud y longitud
      } else {
        print('No se encontró ningún resultado para el topónimo dado.');
        return null;
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      return null;
    }
  }



  Map<String, dynamic> toMap() {
    return {
      'coord': coordenada,
      'toponimo': toponimo,
      'apodo': apodo,
    };
  }


    
}
