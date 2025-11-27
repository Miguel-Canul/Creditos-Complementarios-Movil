class Horario {
  final String dia;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
  });

  // Constructor factory para deserializar el mapa JSON a un objeto Horario.
  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      dia: json['dia'] as String,
      horaInicio: json['horaInicio'] as String,
      horaFin: json['horaFin'] as String,
    );
  }
}