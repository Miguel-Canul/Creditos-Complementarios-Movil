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

  HistorialItem({
    required this.inscripcion,
    required this.actividad,
  });

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    return HistorialItem(
      inscripcion: Inscripcion.fromJson(json['inscripcion'] ?? {}),
      actividad: ActividadHistorial.fromHistorialJson(json),
    );
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
