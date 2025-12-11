import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_inscripcion.dart';
import 'package:mobile/utils/data_formatter.dart';

class ActivityScheduleCardMine extends StatelessWidget {
  final ActividadInscripcion actividad;

  const ActivityScheduleCardMine({super.key, required this.actividad});

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
          if (actividad.fechaFin.isNotEmpty)
            Column(
              children: [
                Text(
                  "Desde: ${DateFormatter.formatearFecha(actividad.fechaInicio)}",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Hasta: ${DateFormatter.formatearFecha(actividad.fechaFin)}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          else
            Center(
              child: Text(
                DateFormatter.formatearFecha(actividad.fechaInicio),
                style: const TextStyle(fontSize: 16),
              ),
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
          if (actividad.fechaFin.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bucle for de colección para generar Text por cada horario
                for (final horario in actividad.horarios)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      // Formatea la salida directamente
                      "${horario.dia[0].toUpperCase()}${horario.dia.substring(1).toLowerCase()}: ${DateFormatter.formatearHoraAmPm(horario.horaInicio)} - ${DateFormatter.formatearHoraAmPm(horario.horaFin)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                // Muestra mensaje si la lista está vacía
                if (actividad.horarios.isEmpty)
                  const Text('Horarios no disponibles',
                      style: TextStyle(fontSize: 14)),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bucle for de colección para generar Text por cada horario
                for (final horario in actividad.horarios)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Center(
                      child: Text(
                        // Formatea la salida directamente
                        "${DateFormatter.formatearHoraAmPm(horario.horaInicio)} - ${DateFormatter.formatearHoraAmPm(horario.horaFin)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                // Muestra mensaje si la lista está vacía
                if (actividad.horarios.isEmpty)
                  const Text('Horarios no disponibles',
                      style: TextStyle(fontSize: 14)),
              ],
            )
        ],
      ),
    );
  }
}
