class Estudiante {
  final String numeroControl;
  final String nombre;
  final String carrera;

  Estudiante({
    required this.numeroControl,
    required this.nombre,
    required this.carrera,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      numeroControl: json['numeroControl'] ?? '',
      nombre: json['nombre'] ?? '',
      carrera: json['carrera'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroControl': numeroControl,
      'nombre': nombre,
      'carrera': carrera,
    };
  }
}