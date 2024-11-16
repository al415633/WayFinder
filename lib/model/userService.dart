
import 'package:WayFinder/model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService implements DbAdapterUser{
  // Propiedad privada
  final DbAdapterUser repository;

  // Constructor
  UserService(this.repository);

 
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


  }



abstract class DbAdapterUser {
  User? createUser(String email, String password);
  User? logIn(User user);

}