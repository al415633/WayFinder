import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/model/coordinate.dart';
import 'package:WayFinder/model/location.dart';
import 'package:WayFinder/model/route.dart';
import 'package:WayFinder/model/transportMode.dart';
import 'package:WayFinder/viewModel/LocationController.dart';
import 'package:WayFinder/viewModel/RouteController.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R4_Itest.mocks.dart';


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