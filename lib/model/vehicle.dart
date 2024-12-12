import 'package:WayFinder/model/favItem.dart';
import 'package:WayFinder/viewModel/DieselCarPrice.dart';
import 'package:WayFinder/viewModel/ElectricCarPrice.dart';
import 'package:WayFinder/viewModel/GasolineCarPrice.dart';
import 'package:WayFinder/viewModel/Price.dart';

class Vehicle implements FavItem{
  // Propiedades

late String fuelType;
late double consumption;
late String numberPlate;
late String name;
late bool fav;
Price? price; //para hacer el stategy de si es gasolina, gasoil o electrico


  // Constructor
  Vehicle(String fuelType, double consumption, String numberPlate, String name, {this.fav = false}) {
    this.fuelType = fuelType;
    this.consumption = consumption;
    this.numberPlate = numberPlate;
    this.name = name;
    
    switch (fuelType.toLowerCase()) {
      case 'gasolina':
        price=Gasolinecarprice();
        break;
      case 'eléctrico':
        price=Electriccarprice();
        break;
      case 'diésel':
         price=Dieselcarprice();
        break;
  }
  }
  
void setPriceStrategy(Price priceStrategy) {
    price = priceStrategy;
  }
  @override
  bool getFav() => fav;

  @override
  void addFav() {
    fav = true;
  }
  
  @override
  void removeFav() {
    fav = false;
  }

  String getFuelType(){
    return fuelType;
  }

  double getConsumption(){
    return consumption;
  }

  String getNumberPlate(){
    return numberPlate;
  }

  String getName(){
    return name;
  }

  Map<String, dynamic> toMap() {
    return {
      'fueltype': fuelType,
      'consumption': consumption,
      'numberPlate': numberPlate,
      'name': name,
      'fav' : fav
    };
  }

// Constructor de la clase desde un mapa
  Vehicle.fromMap(Map<String, dynamic> mapa) {
    // Verificar que los campos necesarios no sean nulos
    if (mapa['fueltype'] == null) {
      throw Exception("Datos incompletos: tipo de combustible faltante.");
    }
    if (mapa['consumption'] == null) {
      throw Exception("Datos incompletos: consumo faltante.");
    }

    // Asignación de propiedades con valores del mapa
    fuelType = mapa['fueltype'] ?? "Desconocido"; // Valor por defecto si es nulo
    consumption = mapa['consumption']?.toDouble() ?? 0.0; // Asegúrate de convertir a `double`
    numberPlate = mapa['numberPlate'] ?? "Sin matrícula"; // Valor por defecto si es nulo
    name = mapa['name'] ?? "Sin nombre"; // Valor por defecto si es nulo
    fav = mapa['fav'] ?? false; // Valor por defecto si es nulo
  }

  // Sobrescribe `==` para comparar por matrícula
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Compara la referencia
    if (other is! Vehicle) return false; // Verifica el tipo
    return numberPlate == other.numberPlate; // Compara matrículas
  }

  // Sobrescribe `hashCode` para usar `numberPlate`
  @override
  int get hashCode => numberPlate.hashCode;

}
