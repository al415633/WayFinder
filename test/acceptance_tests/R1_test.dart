// precio_luz_service_acceptance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UserService])
void main() {

  group('Usuarios', () {
    //ate PrecioLuzService precioLuzService;

    setUp(() {
    


    });

  group('UserService Test', () {
    test('H1E1 - Guardar Datos Usuario', () async {
      // Datos de prueba
      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";
      Map<String, dynamic> userData = {
        'email': email,
        'password': password,
      };

      // Instancia de MockUserService
      final userService = MockUserService();

      // Configura el mock para simular el guardado y obtención de datos
      when(userService.saveUserData(userData)).thenAnswer((_) async => true);
      when(userService.getUserData()).thenAnswer((_) async => userData);

      
      await userService.saveUserData(userData);

      //Se llama 1 vez a saveuserData
      verify(userService.saveUserData(userData)).called(1);

      // Obtengo los datos
      final userInfo = await userService.getUserData();

      //Se llama 1 vez a getuserData
      verify(userService.getUserData()).called(1);

    
      expect(userInfo, isNotNull);
      expect(userInfo['email'], equals(email));
      expect(userInfo['password'], equals(password));

    });
  });


    test('H1E2', () async {
    


    });



  });
}
