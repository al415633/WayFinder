import 'package:flutter/material.dart';

// lo hacemos STATIC porque queremos una sola instancia, queremos usar la misma cada vez que la mencionemos
// si usamos herramientas de colorScheme nos aseguramos de que no nos dará problemas futuros

  class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Definir los colores generales en el esquema de colores
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue, // Define un primarySwatch basado en azul
      ).copyWith(
        primary: Color(0xFF99D2E5), // Aseguramos de que el azul claro sea el color principal
        secondary: Color(0xFF33373C), // Color secundario
        onPrimary: Colors.white, // Color del texto sobre elementos con fondo primario
        onSecondary: Colors.white, // Color del texto sobre elementos con fondo secundario
      ),

      primaryColor: Color(0xFF99D2E5),
      scaffoldBackgroundColor: Colors.white,

      // Estilos del AppBar 
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF99D2E5),  // Color de fondo de AppBar
        titleTextStyle: TextStyle(
          color: Colors.white,  // Color del texto del título en AppBar
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),

       // Controlar el color de selección de texto
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF99D2E5), // Color del cursor de texto
        selectionColor: Color(0xFF99D2E5).withOpacity(0.5), // Color de selección de texto
        selectionHandleColor: Color(0xFF99D2E5), // Control de selección de texto
      ),

      // Iconos
      iconTheme: IconThemeData(
        color: Color(0xFF33373C),
        size: 24.0,
      ),

      // Tarjetas, he visto que quedan monas, para crear ventanas de notificaciones o algo :)
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color(0xFF99D2E5),
            width: 1.0,
          ),
        ),
      ),

      // Otros estilos como bordes, sombras, etc.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Color(0xFF99D2E5), // Asegúrate de que el azul se aplique aquí
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Color(0xFF99D2E5), // Azul también cuando está enfocado
            width: 2.0,
          ),
        ),
      ),

      // Textos
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          color: Color(0xFF33373C),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
        ),
        labelLarge: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF99D2E5),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
