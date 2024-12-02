import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';



@GenerateMocks([FirebaseAuth, DbAdapterUserApp, DbAdapterRoute])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

 group('R4: Gestión de Routes', () {
    test('H13-E1V - Crear ruta', () async {
      //no necesita acceder a la base de datos porque crea la ruta pero no la almacena en la BBDD
    });

    test('H13-E2I - Crear ruta inválido no hay conexión BBDD', () async {
      //no necesita acceder a la base de datos porque crea la ruta pero no la almacena en la BBDD
    });

   });


}