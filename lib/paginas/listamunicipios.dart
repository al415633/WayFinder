import 'package:flutter/material.dart';
import '/services/municipios_service.dart';  // Importamos el servicio que creamos para obtener los municipios

class ListaMunicipiosPage extends StatefulWidget {
  @override
  _ListaMunicipiosPageState createState() => _ListaMunicipiosPageState();
}

class _ListaMunicipiosPageState extends State<ListaMunicipiosPage> {
  late Future<List<Municipio>> futureMunicipios;

  @override
  void initState() {
    super.initState();
    futureMunicipios = MunicipioService().fetchMunicipios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Municipios'),
      ),
      body: FutureBuilder<List<Municipio>>(
        future: futureMunicipios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Imprime los municipios y sus IDs en la terminal para verlos y poder hacer Ctrl+F
            snapshot.data!.forEach((municipio) {
              print('Municipio: ${municipio.nombre}, ID: ${municipio.id}');
            });
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final municipio = snapshot.data![index];
                return ListTile(
                  title: Text(municipio.nombre),
                  subtitle: Text('ID: ${municipio.id}'),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron municipios.'));
          }
        },
      ),
    );
  }
}
