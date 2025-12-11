import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';

class ActivityScheduleCard extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActivityScheduleCard({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Título Periodo ---
          const Center(
            child: Text(
              "Fecha",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Inicio: ${actividad.fechaInicio}",
            style: const TextStyle(fontSize: 16), // <-- Tamaño aumentado
          ),

          const SizedBox(height: 8),

          if (actividad.fechaFin != null &&
              actividad.fechaFin!.isNotEmpty &&
              actividad.fechaFin!.toLowerCase() != "fin")
            Text(
              "Fin: ${actividad.fechaFin}",
              style: const TextStyle(fontSize: 16), // <-- Tamaño aumentado
            ),

          const SizedBox(height: 20),

          // --- Título Horario ---
          const Center(
            child: Text(
              "Horario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            actividad.horariosFormateados(),
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
