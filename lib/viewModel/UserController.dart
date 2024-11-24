
import 'package:WayFinder/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserController{

  // Propiedad privada
  final DbAdapterUser repository;

  // Constructor privado
  UserController._internal(this.repository);


  // Instancia única
  static UserController? _instance;


  factory UserController(DbAdapterUser repository) {
    _instance ??= UserController._internal(repository);
    return _instance!;
  }


 
   @override
  User? createUser(String email, String password)  {
     //REGLAS DE NEGOCIO
     //CONECION AL REPOSITORIO 
    throw UnimplementedError("Method not implemented");
   
   }


   @override
   User? logIn(User user)  {
     //REGLAS DE NEGOCIO
     //CONECION AL REPOSITORIO para ver la conexion a la BBDD
    throw UnimplementedError("Method not implemented");
   
   }


  @override
  User? logInCredenciales(String email, String password)  {
     //REGLAS DE NEGOCIO
     //entrar en el REPOSITORIO 
     //Comporbar que estan ese email, pass en la Bbdd
    throw UnimplementedError("Method not implemented");
   
   }
   
     @override
     User? logOut(User user) {
    // TODO: implement logOut

    //Comporbar que hay acceso a la BBDD
    throw UnimplementedError("Method not implemented");
     }





}

class FirestoreAdapterUser implements DbAdapterUser {
  final  String _collectionName;
  final FirebaseFirestore db= FirebaseFirestore.instance;

  FirestoreAdapterUser({String collectionName="production"}):_collectionName=collectionName;



  @override
  User? createUser(String email, String password)  {
    //Conexion a Firebase que cree el usuario
   throw UnimplementedError("Method not implemented");
  }
  
  @override
  User? logIn(User user)  {
      //Conexion a Firebase que inicie sesion
    throw UnimplementedError("Method not implemented");

  }

  
  @override
  User? logInCredenciales(String email, String password) {
    // TODO: implement logInCredenciales
    throw UnimplementedError("Method not implemented");
  }
  
  @override
  User? logOut(User user) {
    // TODO: implement logOut
    throw UnimplementedError("Method not implemented");
  }



  }



abstract class DbAdapterUser {
  User? createUser(String email, String password);
  User? logIn(User user);

  User? logInCredenciales(String email, String password);
  User? logOut(User user);



}