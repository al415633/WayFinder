class Vehicle {
  // Propiedades

late String fuelType;
late double consumption;
late String numberPlate;
late String name;
late bool fav;

  // Constructor
  Vehicle(String fuelType, double consumption, String numberPlate, String name) {
    this.fuelType = fuelType;
    this.consumption = consumption;
    this.numberPlate = numberPlate;
    this.name = name;
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

  bool getFav(){
    return fav;
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

Vehicle.fromMap(Map<String, dynamic> mapa) {
  if (mapa['fueltype'] == null) {
    throw Exception("Datos incompletos: tipo de combustible faltante.");
  }

  if (mapa['consumption'] == null) {
    throw Exception("Datos incompletos: consumo faltante.");
  }
  
  numberPlate = mapa['numberplate'] ?? "Sin matricula";
  fav = mapa['fav'] ?? false;
}

}
