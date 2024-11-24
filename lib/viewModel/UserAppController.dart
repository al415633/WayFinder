
import 'package:WayFinder/model/UserApp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserAppController{

  // Propiedad privada
  final DbAdapterUserApp repository;

  // Constructor privado
  UserAppController._internal(this.repository);


  // Instancia única
  static UserAppController? _instance;


  factory UserAppController(DbAdapterUserApp repository) {
    _instance ??= UserAppController._internal(repository);
    return _instance!;
  }


 
   @override
  UserApp? createUser(String email, String password)  {



    bool isValidEmail(String email) {
      final emailRegex = RegExp(
          r'^[a-zA-Z0-9]+@[gmail|outlook|hotmail|yahoo]+\.(com|es)$');
      return emailRegex.hasMatch(email);
    }
    bool isValidPassword(String password) {
      final passwordRegex = RegExp(
          r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[.,@$&*=]).{8,}$');
      return passwordRegex.hasMatch(password);
    }


     //REGLAS DE NEGOCIO
    if (isValidEmail(email)) {
      throw Exception("NotValidEmailException");
    }

   
    if (isValidPassword(password)) {
      throw Exception("IncorrectPasswordException");
    }

     //CONECION AL REPOSITORIO 
     repository.createAppUserApp(email, password);
   
   }


   @override
   UserApp? logIn(UserApp AppUserApp)  {
     //REGLAS DE NEGOCIO
     //CONECION AL REPOSITORIO para ver la conexion a la BBDD
    throw UnimplementedError("Method not implemented");
   
   }


  @override
  UserApp? logInCredenciales(String email, String password)  {
     //REGLAS DE NEGOCIO
     //entrar en el REPOSITORIO 
     //Comporbar que estan ese email, pass en la Bbdd
    throw UnimplementedError("Method not implemented");
   
   }
   
     @override
     UserApp? logOut(UserApp AppUserApp) {
    // TODO: implement logOut

    //Comporbar que hay acceso a la BBDD
    throw UnimplementedError("Method not implemented");
     }





}

class FirestoreAdapterUserApp implements DbAdapterUserApp {
  final  String _collectionName;
  final FirebaseFirestore db= FirebaseFirestore.instance;

  FirestoreAdapterUserApp({String collectionName="production"}):_collectionName=collectionName;



  @override
  Future<UserApp?> createUser(String email, String password)  async {
    //Conexion a Firebase que cree el usuario
   try {
      // Verificar si el usuario ya existe en Firebase Auth
      var existingAppUserApp = await auth.fetchSignInMethodsForEmail(email);
      if (existingAppUserApp.isNotEmpty) {
        // Si el usuario ya existe, lanzar un error
        throw Exception('El usuario ya existe');
      }


      // Crear el usuario en Firebase Authentication
      UserCredential UserCredential = await auth.createAppUserAppWithEmailAndPassword(
        email: email,
        password: password,
      );
     
      // Obtener el usuario recién creado
      UserApp? AppUserApp = UserAppCredential.AppUserApp;
     
      // Si es necesario, también puedes guardar más información en Firestore
      if (AppUserApp != null) {
        await db.collection(_collectionName).doc(AppUserApp.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
     
      // Retornar el usuario creado
      return AppUserApp;
    } catch (e) {
      // Manejo de errores
      print('Error al crear el usuario: $e');
      return null;
    }

  }
  
  @override
  UserApp? logIn(UserApp AppUserApp)  {
      //Conexion a Firebase que inicie sesion
    throw UnimplementedError("Method not implemented");

  }

  
  @override
  UserApp? logInCredenciales(String email, String password) {
    // TODO: implement logInCredenciales
    throw UnimplementedError("Method not implemented");
  }
  
  @override
  UserApp? logOut(UserApp AppUserApp) {
    // TODO: implement logOut
    throw UnimplementedError("Method not implemented");
  }



  }



abstract class DbAdapterUserApp {
  Future<UserApp?> createUser(String email, String password);
  UserApp? logIn(UserApp AppUserApp);

  UserApp? logInCredenciales(String email, String password);
  UserApp? logOut(UserApp AppUserApp);



}