class ActividadHistorial {
  final String id;
  final String nombre;
  final String categoria;
  final String periodo;
  final String estado;
  final String? folio;
  final String? desempenio;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String foto;

  ActividadHistorial({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.periodo,
    required this.estado,
    this.folio,
    this.desempenio,
    this.fechaInicio,
    this.fechaFin,
    required this.foto, // Agregado al constructor requerido
  });

  factory ActividadHistorial.fromJson(Map<String, dynamic> json) {
    return ActividadHistorial(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      periodo: json['periodo'] ?? '',
      estado: json['estado'] ?? '',
      folio: json['folio'],
      desempenio: json['desempenio'],
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin:
          json['fechaFin'] != null ? DateTime.parse(json['fechaFin']) : null,
      foto: json['foto'] ??
          'assets/images/default_activity.jpg', // Valor por defecto
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'periodo': periodo,
      'estado': estado,
      'folio': folio,
      'desempenio': desempenio,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'foto': foto,
    };
  }
}
