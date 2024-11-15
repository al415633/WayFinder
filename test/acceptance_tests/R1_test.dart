import 'package:WayFinder/model/viewModel/UserService.dart';
import 'package:WayFinder/model/User.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('UserService Test', () {
    late DbAdapter adapter;
    late UserService userService;

    

    setUpAll(() async {
      // Inicializar el entorno de pruebas

      // no se si hace falta el test delante
      TestWidgetsFlutterBinding.ensureInitialized();

      // Cargar la configuración desde firebase_config.json

      //google serviceds
      

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyDXulZRRGURCCXX9PDfHJR_DMiYHjz2ahU",
          authDomain: "wayfinder-df8eb.firebaseapp.com",
          projectId: "wayfinder-df8eb",
          storageBucket: "wayfinder-df8eb.appspot.com",
          messagingSenderId: "571791500413",
          appId: "1:571791500413:web:18f7fd23d9a98f2433fd14",
          measurementId: "G-TZLW8P5J8V"
        ),
      );
    });

    setUp(() async {
      adapter = FirestoreAdapter(collectionName: "testCollection");
      userService = UserService(adapter);

    });

    
      test('H1E1 - Guardar Datos Usuario', () {
        
        // WHEN 

      String email = "ana@gmail.com";
      String password = "Aaaaa,.8";

      User? user = userService.createUser(email, password);

      // THEN
      expect(user, isNotNull);
      expect(user?.email, equals(email));
    });

    test('H1E2 -Password no cumple reglas de negocio', () async {
      // WHEN 
      String email = "ana@gmail.com";
      String password = "1";
      User? user = userService.createUser(email, password);

      // THEN
      expect(user, isNull);
     
    });
  });
}
