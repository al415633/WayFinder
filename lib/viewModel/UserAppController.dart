
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
     repository.createUser(email, password);
   
   }


   @override
   UserApp? logIn(UserApp UserApp)  {
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
     UserApp? logOut(UserApp UserApp) {
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
      throw UnimplementedError("Method not implemented");

  }
  
  @override
  UserApp? logIn(UserApp UserApp)  {
      //Conexion a Firebase que inicie sesion
    throw UnimplementedError("Method not implemented");

  }

  
  @override
  UserApp? logInCredenciales(String email, String password) {
    // TODO: implement logInCredenciales
    throw UnimplementedError("Method not implemented");
  }
  
  @override
  UserApp? logOut(UserApp UserApp) {
    // TODO: implement logOut
    throw UnimplementedError("Method not implemented");
  }



  }



abstract class DbAdapterUserApp {
  Future<UserApp?> createUser(String email, String password);
  UserApp? logIn(UserApp UserApp);

  UserApp? logInCredenciales(String email, String password);
  UserApp? logOut(UserApp UserApp);



}