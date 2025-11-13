class Actividad {
  final int id;
  final String nombre;
  final String tipo;
  final String encargado;

  Actividad({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.encargado,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      encargado: json['encargado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'encargado': encargado,
    };
  }
}