import 'package:flutter/material.dart';
import 'package:spike0/paginas/iniciosesion.dart';
import 'package:spike0/paginas/pagina02.dart';
import 'package:spike0/paginas/preciocarburante.dart';
import 'package:spike0/paginas/precioluz.dart';


void main()=>runApp(const MiApp()); //Llama al primer widget

class MiApp extends StatelessWidget{
  const MiApp ({super.key}); //const significa que es inmutable

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
      title: "Titulo",
      home: Inicio(),


    ); //Patron de diseño de Googe para crrear apps

  }



}


class Inicio extends StatefulWidget{
  const Inicio({super.key}); //? significa que acepta nulos

  @override
  _InicioState createState()=>_InicioState();

}


//Cuando estas haciendo la parte del front casi todo funciona con comas
//Cuando te pones ha codificar funciones... Cada vez que escribes una linea al final ;


  class _InicioState extends State<Inicio>{

    @override
    Widget build(BuildContext context){
       return Scaffold( 
        
          appBar: AppBar(
            title: const Text("Titulo AppBar"),
           ),
          
         body: ListView( //Ctrl+ . Y wrap with column y cambiar el nombre por ListView, sino no deja hacer scroll
          children:<Widget> [
             
            ElevatedButton(onPressed:()=>{
              
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context)=>const Pagina02()) //


            )} , child: const Text("Página ejemplo")),
            
            const SizedBox(height: 50), 
            
            ElevatedButton(onPressed:()=>{
              
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context)=>const PrecioLuz()) //


            )} , child: const Text("Página precio luz")),
          
            const SizedBox(height: 50), 
            
            ElevatedButton(onPressed:()=>{
              
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context)=>const PrecioCarburante()) //


            )} , child: const Text("Página precio carburante")),

            const SizedBox(height: 50), 
            
            ElevatedButton(onPressed:()=>{
              
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context)=>const InicioSesion()) //


            )} , child: const Text("Página inicio sesión")),

       ])
       );

    }
  }



