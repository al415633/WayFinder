enum TransportMode {
  coche,
  bicicleta,
  aPie,
}

extension TransportModeExtension on TransportMode {
  String get name {
    switch (this) {
      case TransportMode.coche:
        return 'Coche';
      case TransportMode.bicicleta:
        return 'Bicicleta';
      case TransportMode.aPie:
        return 'A pie';
      default:
        return '';
    }
  }
}