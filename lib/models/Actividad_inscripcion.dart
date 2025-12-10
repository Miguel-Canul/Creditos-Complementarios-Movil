import 'package:mobile/models/Horario.dart';

class ActividadInscripcion {
  final String id;
  final String nombre;
  final String descripcion;
  final String fotoUrl;
  final double cantidadCreditos; // Es un float/double en la API
  final String categoria;
  final String periodo;
  final String encargado;
  final int cupoActual;
  final int cupoMaximo;
  final String ubicacion;
  final List<Horario> horarios; // Lista de horarios usando el modelo anterior

  ActividadInscripcion({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fotoUrl,
    required this.cantidadCreditos,
    required this.categoria,
    required this.periodo,
    required this.encargado,
    required this.cupoActual,
    required this.cupoMaximo,
    required this.ubicacion,
    required this.horarios,
  });

  // Constructor factory para deserializar el mapa JSON a un objeto ActividadInscripcion.
  factory ActividadInscripcion.fromJson(Map<String, dynamic> json) {
    // Mapeo de la lista de mapas de horarios a una lista de objetos Horario.
    final List<dynamic> horariosJson = json['horarios'] as List<dynamic>;
    final List<Horario> horarios = horariosJson.map((h) => Horario.fromJson(h as Map<String, dynamic>)).toList();
    
    return ActividadInscripcion(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      fotoUrl: json['fotoUrl'] as String,
      cantidadCreditos: (json['cantidadCreditos'] as num).toDouble(), // Asegurar double
      categoria: json['categoria'] as String,
      periodo: json['periodo'] as String,
      encargado: json['encargado'] as String,
      cupoActual: json['cupoActual'] as int,
      cupoMaximo: json['cupoMaximo'] as int,
      ubicacion: json['ubicacion'] as String,
      horarios: horarios,
    );
  }
}