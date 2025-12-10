import 'package:mobile/utils/meses.dart';

class DateFormatter {
  static String _obtenerNombreMes(int numeroMes) {
    try {
      return Meses.values
          .firstWhere((mes) => mes.valor == numeroMes)
          .nombre;
    } catch (_) {
      return ''; 
    }
  }

  static String formatearFecha(String fecha) {
    if (fecha.isEmpty) {
      return '';
    }
    
    final partes = fecha.split('-');
    
    if (partes.length != 3) {
      return fecha; 
    }

    final String anio = partes[0];
    final String dia = partes[2];
    final int numeroMes = int.tryParse(partes[1]) ?? 0;

    final String nombreMes = _obtenerNombreMes(numeroMes);
    return '$dia/$nombreMes/$anio';
  }
}