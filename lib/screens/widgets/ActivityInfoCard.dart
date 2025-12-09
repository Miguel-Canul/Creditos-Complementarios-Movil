import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/screens/widgets/ActivityInfoItem.dart';

class ActivityInfoCard extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActivityInfoCard({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Créditos
          ActivityInfoItem(
            icon: Icons.star,
            label: "Créditos",
            value: actividad.cantidadCreditos.toString(),
          ),
          const SizedBox(height: 8),

          // Cupo
          ActivityInfoItem(
            icon: Icons.flag,
            label: "Cupo",
            value: "${actividad.cupoActual}/${actividad.cupoMaximo}",
          ),
          const SizedBox(height: 8),

          // Ubicación
          ActivityInfoItem(
            icon: Icons.location_on,
            label: "Ubicación",
            value: actividad.ubicacion,
          ),
          const SizedBox(height: 8),

          // Encargado
          ActivityInfoItem(
            icon: Icons.person,
            label: "Encargado",
            value: actividad.encargadoNombre ?? "Sin encargado",
          ),
          const SizedBox(height: 12),

          // -------------------------
          // 🔽 DATOS DE INSCRIPCIÓN 🔽
          // -------------------------

          if (actividad.estadoInscripcion != null) ...[
            ActivityInfoItem(
              icon: Icons.info,
              label: "Estado",
              value: actividad.estadoTexto,
            ),
            const SizedBox(height: 8),
          ],

          if ((actividad.desempeno ?? 0) > 0) ...[
            ActivityInfoItem(
              icon: Icons.grade,
              label: "Desempeño final",
              value: actividad.desempenioTexto,
            ),
            const SizedBox(height: 8),
          ],

          if ((actividad.desempenoParcial ?? 0) > 0) ...[
            ActivityInfoItem(
              icon: Icons.timelapse,
              label: "Desempeño parcial",
              value: actividad.desempenioParcialTexto,
            ),
            const SizedBox(height: 8),
          ],

          if (actividad.valorNumerico != null &&
              actividad.valorNumerico! > 0) ...[
            ActivityInfoItem(
              icon: Icons.numbers,
              label: "Calificación",
              value: actividad.valorNumericoFormateado,
            ),
            const SizedBox(height: 8),
          ],

          if ((actividad.observaciones ?? "").isNotEmpty) ...[
            ActivityInfoItem(
              icon: Icons.chat_bubble_outline,
              label: "Observaciones",
              value: actividad.observaciones!,
            ),
          ],
        ],
      ),
    );
  }
}
