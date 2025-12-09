import 'package:mobile/models/actividad_historial.dart';

class HistorialResponse {
  final String alumnoId;
  final int totalInscripciones;
  final double totalCreditosAprobados;
  final Map<String, dynamic> creditosPorCategoria;
  final List<HistorialItem> historial;

  HistorialResponse({
    required this.alumnoId,
    required this.totalInscripciones,
    required this.totalCreditosAprobados,
    required this.creditosPorCategoria,
    required this.historial,
  });

  factory HistorialResponse.fromJson(Map<String, dynamic> json) {
    return HistorialResponse(
      alumnoId: json['alumno_id'] ?? '',
      totalInscripciones: json['total_inscripciones'] ?? 0,
      totalCreditosAprobados:
          (json['total_creditos_aprobados'] ?? 0).toDouble(),
      creditosPorCategoria:
          Map<String, dynamic>.from(json['creditos_por_categoria'] ?? {}),
      historial: (json['historial'] as List? ?? [])
          .map((item) => HistorialItem.fromJson(item))
          .toList(),
    );
  }
}

class HistorialItem {
  final Inscripcion inscripcion;
  final ActividadHistorial actividad;
  final List<Map<String, dynamic>> horarios; // Nuevo campo

  HistorialItem({
    required this.inscripcion,
    required this.actividad,
    required this.horarios, // Agregado como requerido
  });

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    // Procesar horarios
    final List<Map<String, dynamic>> horariosList = [];
    if (json['horarios'] is List) {
      for (var horario in json['horarios']) {
        if (horario is Map<String, dynamic>) {
          horariosList.add(horario);
        }
      }
    }

    return HistorialItem(
      inscripcion: Inscripcion.fromJson(json['inscripcion'] ?? {}),
      actividad: ActividadHistorial.fromHistorialJson(json),
      horarios: horariosList,
    );
  }

  // Método auxiliar para obtener el JSON completo combinado
  Map<String, dynamic> toCombinedJson() {
    return {
      'inscripcion': {
        'Desempeno': inscripcion.desempeno,
        'Estado': inscripcion.estado,
        'SK': inscripcion.sk,
        'Observaciones': inscripcion.observaciones,
        'DesempenoParcial': inscripcion.desempenoParcial,
        'PK': inscripcion.pk,
        'ValorNumerico': inscripcion.valorNumerico,
      },
      'actividad': actividad.toMap(),
      'horarios': horarios,
    };
  }
}

class Inscripcion {
  final int desempeno;
  final int estado;
  final String sk;
  final String observaciones;
  final int desempenoParcial;
  final String pk;
  final double valorNumerico;

  Inscripcion({
    required this.desempeno,
    required this.estado,
    required this.sk,
    required this.observaciones,
    required this.desempenoParcial,
    required this.pk,
    required this.valorNumerico,
  });

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      desempeno: json['Desempeno'] ?? 0,
      estado: json['Estado'] ?? 0,
      sk: json['SK'] ?? '',
      observaciones: json['Observaciones'] ?? '',
      desempenoParcial: json['DesempenoParcial'] ?? 0,
      pk: json['PK'] ?? '',
      valorNumerico: (json['ValorNumerico'] ?? 0).toDouble(),
    );
  }
}
