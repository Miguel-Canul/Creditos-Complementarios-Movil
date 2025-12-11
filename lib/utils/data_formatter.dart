import 'package:mobile/utils/meses.dart';

class DateFormatter {
  static String formatearHoraAmPm(String hora) {
    // Formato de entrada: "hh:mm"
    if (hora.isEmpty) {
      return '';
    }

    final partes = hora.split(':');
    
    // Validación de formato
    if (partes.length != 2) {
      return hora;
    }

    // Convertir la parte de la hora a entero
    final int hora24 = int.tryParse(partes[0]) ?? -1;
    final String minutos = partes[1];
    
    // Si la hora no es válida (0-23)
    if (hora24 < 0 || hora24 > 23) {
      return hora;
    }

    // Lógica de conversión a 12 horas y determinación de AM/PM
    final String indicador;
    final int hora12;

    if (hora24 == 0) { // 00:xx (Medianoche)
      hora12 = 12;
      indicador = 'a.m.';
    } else if (hora24 == 12) { // 12:xx (Mediodía)
      hora12 = 12;
      indicador = 'p.m.';
    } else if (hora24 > 12) { // 13:xx a 23:xx
      hora12 = hora24 - 12;
      indicador = 'p.m.';
    } else { // 01:xx a 11:xx
      hora12 = hora24;
      indicador = 'a.m.';
    }

    // Formato de salida: "hh:mm a.m./p.m."
    return '$hora12:$minutos $indicador';
  }

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