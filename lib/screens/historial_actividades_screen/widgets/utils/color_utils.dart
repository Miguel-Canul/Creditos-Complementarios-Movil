import 'package:flutter/material.dart';

class ColorUtils {
  static Color getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en curso':
        return Colors.orange;
      case 'esperando aprobación':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static Color getDesempenioColor(String? desempenio) {
    if (desempenio == null || desempenio.isEmpty) return Colors.grey;

    switch (desempenio.toLowerCase()) {
      case 'excelente':
        return Colors.green;
      case 'notable':
        return Colors.lightGreen;
      case 'suficiente':
        return Colors.orange;
      case 'insuficiente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
