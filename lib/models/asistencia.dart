class Asistencia {
  final int id;
  final String numeroControl;
  final int actividadId;
  final DateTime fechaHora;
  final String estadoAsistencia;

  Asistencia({
    required this.id,
    required this.numeroControl,
    required this.actividadId,
    required this.fechaHora,
    required this.estadoAsistencia,
  });

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] ?? 0,
      numeroControl: json['numeroControl'] ?? '',
      actividadId: json['actividadId'] ?? 0,
      fechaHora: DateTime.parse(json['fechaHora']),
      estadoAsistencia: json['estadoAsistencia'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroControl': numeroControl,
      'actividadId': actividadId,
      'fechaHora': fechaHora.toIso8601String(),
      'estadoAsistencia': estadoAsistencia,
    };
  }
}