import '../utils/constants.dart';

class AsistenciaDetalle {
  final int id;
  final String numeroControl;
  final String nombreEstudiante;
  final String carreraEstudiante;
  final int actividadId;
  final String nombreActividad;
  final String encargado;
  final DateTime fechaHora;
  final String estadoAsistencia;
  final String? extraescolarTaller;

  AsistenciaDetalle({
    required this.id,
    required this.numeroControl,
    required this.nombreEstudiante,
    required this.carreraEstudiante,
    required this.actividadId,
    required this.nombreActividad,
    required this.encargado,
    required this.fechaHora,
    required this.estadoAsistencia,
    this.extraescolarTaller,
  });

  factory AsistenciaDetalle.fromJson(Map<String, dynamic> json) {
    return AsistenciaDetalle(
      id: json['id'] ?? 0,
      numeroControl: json['numeroControl'] ?? '',
      nombreEstudiante: json['nombreEstudiante'] ?? '',
      carreraEstudiante: json['carreraEstudiante'] ?? '',
      actividadId: json['actividadId'] ?? 0,
      nombreActividad: json['nombreActividad'] ?? '',
      encargado: json['encargado'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora']),
      estadoAsistencia: json['estadoAsistencia'] ?? '',
      extraescolarTaller: json['extraescolarTaller'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroControl': numeroControl,
      'nombreEstudiante': nombreEstudiante,
      'carreraEstudiante': carreraEstudiante,
      'actividadId': actividadId,
      'nombreActividad': nombreActividad,
      'encargado': encargado,
      'fechaHora': fechaHora.toIso8601String(),
      'estadoAsistencia': estadoAsistencia,
      'extraescolarTaller': extraescolarTaller,
    };
  }

  String get extraescolarCalculado {
    if (extraescolarTaller != null && extraescolarTaller!.isNotEmpty) {
      return extraescolarTaller!;
    }

    return 'Sin clasificar';
  }
}
