enum FuelType {
  gasolina,
  diesel,
  electrico
}

extension FuelTypeExtension on FuelType {
  String get name {
    switch (this) {
      case FuelType.gasolina:
        return 'Gasolina';
      case FuelType.diesel:
        return 'Diésel';
      case FuelType.electrico:
        return 'Eléctrico';
      default:
        return '';
    }
  }
}