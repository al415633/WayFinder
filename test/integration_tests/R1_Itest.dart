import 'package:WayFinder/exceptions/IncorrectPasswordException.dart';
import 'package:WayFinder/exceptions/UserNotAuthenticatedException.dart';
import 'package:WayFinder/exceptions/UserNotExistsExcpetion.dart';
import 'package:WayFinder/model/UserApp.dart';
import 'package:WayFinder/viewModel/UserAppController.dart';
import 'package:WayFinder/viewModel/adapters/DbAdapterUserApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'R1_Itest.mocks.dart';


@GenerateMocks([FirebaseAuth, DbAdapterUserApp])
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  late MockFirebaseAuth mockAuth;
  late MockDbAdapterUserApp mockDbAdapterUserApp;
  late UserAppController userAppController;
  late UserApp? userApp;

  Future<void> cleanUp() async {
    var collectionRef = FirebaseFirestore.instance.collection('testCollection');
    var querySnapshot = await collectionRef.get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete(); 
    }
  }


  Future<UserApp?> signInAndDeleteUser(String email, String password) async {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cleanUp();
    await userCredential.user!.delete();
    return null;
  }

  setUp(() async {
    mockAuth = MockFirebaseAuth();
    mockDbAdapterUserApp = MockDbAdapterUserApp();
    userAppController = UserAppController(mockDbAdapterUserApp);
  });

  group('UserAppController Test', () {

    test('H1-E1V - Guardar Datos Usuario', () async {
      // GIVEN
      String email = "pruebah1E1@gmail.com";
      String password = "Abbbbaa,.8";
      String name = "PruebaH1E1";

      when(mockDbAdapterUserApp.createUser(email, password))
      .thenAnswer((_) async => UserApp("id", name, email));
      // WHEN
      UserApp? newUserApp = await userAppController.createUser(email, password, name);

      // THEN
      expect(newUserApp, isNotNull);
      expect(newUserApp?.email, equals(email));

      //await signInAndDeleteUser(email, password);
    });


    test('H1-E2I - Password no cumple reglas de negocio', () async {
      // GIVEN
      String email = "Pruebah1e2@gmail.com";
      String password = "1";
      String name = "Pruebah1e2";

      when(mockDbAdapterUserApp.createUser(email, password)).thenThrow(IncorrectPasswordException());

      // WHEN
      Future<void> action() async {
        await userAppController.createUser(email, password, name);
      }

      // THEN
      expect(action(), throwsA(isA<IncorrectPasswordException>()));
      verifyNever(mockDbAdapterUserApp.createUser(email, password));

    });

    test('H2-E2V - Permite Iniciar Sesión', () async {
      // GIVEN (realizado en setUpAll)
      String email = "Pruebah2e2@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah2e2";

      when(mockDbAdapterUserApp.logInCredenciales(email, password))
      .thenAnswer((_) async => UserApp("id", name, email));


      // WHEN
      userApp = await userAppController.logInCredenciales(email, password);

      // THEN
      expect(userApp, isNotNull);
      expect(userApp?.email, equals(email));
      verify(mockDbAdapterUserApp.logInCredenciales(email, password)).called(1);
      

    });

    test('H2-E3I - No permite Iniciar Sesión por password inválido', () async {
      // GIVEN (realizado en setUpAll)
      
      String email = "Pruebah2e3@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah2e3";
      String wrongPassword = "aaaaaaaaaa";

      when(mockDbAdapterUserApp.logInCredenciales(email, password))
      .thenAnswer((_) async => UserApp("id", name, email));

      when(mockDbAdapterUserApp.logInCredenciales(email, wrongPassword)).thenThrow(IncorrectPasswordException());
      // WHEN
      Future<void> action() async {
        await userAppController.logInCredenciales(email, "aaaaaaaaaa");
      }

      // THEN
      expect(action(), throwsA(isA<IncorrectPasswordException>()));
      verifyNever(mockDbAdapterUserApp.logInCredenciales(email, password));
      
    });

    test('H3-E1V - Cerrar sesion valido', () async {


      // GIVEN

      String email = "Pruebae3e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah3e1";


      when(mockDbAdapterUserApp.logOut()).thenAnswer((_) async => true);
      when(mockDbAdapterUserApp.logInCredenciales(email, password))
      .thenAnswer((_) async => UserApp("id", name, email));

      userApp = await userAppController.logInCredenciales(email, password);


      // WHEN
      bool closedSession = await userAppController.logOut();

      // THEN
      expect(userApp, isNotNull);
      expect(closedSession, isTrue);
      verify(mockDbAdapterUserApp.logInCredenciales(email, password)).called(1);
      verify(mockDbAdapterUserApp.logOut()).called(1);

    });

    test('H3-E4I - Cerrar sesion sin estar conectado', () async {
      // GIVEN
 
      String email = "pruebah3e4@gmail.com";
      String password = "Aaaaacccccc,.8";
      String name = "pruebah3e2";

      when(mockDbAdapterUserApp.logOut()).thenThrow(UserNotAuthenticatedException());

      //Pero no logeado

      // WHEN
       Future<void> action() async {
          await userAppController.logOut(); 
        }

 
       expect(() async => await action(), throwsA(isA<UserNotAuthenticatedException>()));
       verify(mockDbAdapterUserApp.logOut()).called(1);
       verifyNever(mockDbAdapterUserApp.logInCredenciales(email, password));



    });

    test('H4-E1V - Eliminar cuenta de usuario', () async {


      // GIVEN

      String email = "Pruebae4e1@gmail.com";
      String password = "Aaaaa,.8";
      String name="Pruebah4e1";


      when(mockDbAdapterUserApp.deleteAccount()).thenAnswer((_) async => {});
      when(mockDbAdapterUserApp.checkIfUserExists(email)).thenAnswer((_) async => false);
      when(mockDbAdapterUserApp.logInCredenciales(email, password))
      .thenAnswer((_) async => UserApp("id", name, email));

      userApp = await userAppController.logInCredenciales(email, password);


      // WHEN
      await userAppController.deleteAccount();

      // THEN
      bool userExists = await userAppController.checkIfUserExists(email);
      expect(userExists, isFalse);

    });

    test('H4-E3I - Eliminar cuenta de usuario no registrada', () async {
      // GIVEN
 
      String email = "pruebah4e3@gmail.com";
      String password = "Aaaaacccccc,.8";
      String name = "pruebah4e3";

      when(mockDbAdapterUserApp.deleteAccountForEmail(email)).thenThrow(UserNotExistException());

      when(mockDbAdapterUserApp.checkIfUserExists(email)).thenAnswer((_) async => false);

      //Pero no logeado

      // WHEN
       Future<void> action() async {
          await userAppController.deleteAccountForEmail(email); 
        }

      // THEN
       expect(() async => await action(), throwsA(isA<Exception>()));


    });


  });
}
