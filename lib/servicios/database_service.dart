// lib/services/database_service.dart

import 'package:postgres/postgres.dart';

class DatabaseService {
  late PostgreSQLConnection connection;

  // Inicializa la conexión
  Future<void> connect() async {
    connection = PostgreSQLConnection(
      'localhost', // Dirección del servidor PostgreSQL
      5432,        // Puerto de PostgreSQL
      'al415615_wayfinder', // Nombre de tu base de datos
      username: 'al415615', // Usuario de la base de datos
      password: '30704764V', // Contraseña de la base de datos
    );

    await connection.open();
    print("Conectado a la base de datos");
  }

  // Verificar si el usuario y la contraseña son correctos
  Future<bool> verificarUsuario(String usuario, String contrasena) async {
    List<List<dynamic>> results = await connection.query(
      'SELECT * FROM usuarios WHERE usu = @usu AND contra = @contra',
      substitutionValues: {
        'usu': usuario,
        'contra': contrasena,
      },
    );

    return results.isNotEmpty;
  }



  // Obtener la contraseña hasheada (hash) del usuario
  Future<String?> obtenerHash(String usuario) async {
    try {
      // Ejecutar la consulta SQL para obtener la contraseña hash del usuario
      print("Ejecutando la consulta para obtener el hash...");
      List<List<dynamic>> results = await connection.query(
        'SELECT contra FROM usuarios WHERE usu = @usu',
        substitutionValues: {
          'usu': usuario,
        },
      );

      print("Resultados obtenidos: $results");

      // Si hay resultados, devuelve la contraseña hash, de lo contrario, devuelve null
      if (results.isNotEmpty) {
        print("Hash encontrado para el usuario: ${results[0][0]}");
        return results[0][0] as String; // El hash de la contraseña
      } else {
        print("Usuario no encontrado");
        return null; // Usuario no encontrado
      }
    } catch (e) {
      print("Error al obtener el hash: $e");
      return null;
    }
  }

}






// HE CREADO UNA BASE DE DATOS CON LA SIGUIENTE INFORMACION
//CREATE TABLE usuarios (
  //id SERIAL PRIMARY KEY,
  //usu VARCHAR(50) NOT NULL,
  //contra VARCHAR(255) NOT NULL
//);
