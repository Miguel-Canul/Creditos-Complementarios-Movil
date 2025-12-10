import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_inscripcion.dart';
import 'package:mobile/screens/shared_widgets/ActivityInfoItem.dart';

class ActivityInfoCardMine extends StatelessWidget {
  final ActividadInscripcion actividad;

  const ActivityInfoCardMine({super.key, required this.actividad});

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
          ActivityInfoItem(
            icon: Icons.star,
            label: "Créditos",
            value: actividad.cantidadCreditos.toString(),
          ),
          const SizedBox(height: 8),
          ActivityInfoItem(
            icon: Icons.flag,
            label: "Cupo",
            value: "${actividad.cupoMaximo}/${actividad.cupoMaximo}",
          ),
          const SizedBox(height: 8),
          ActivityInfoItem(
            icon: Icons.location_on,
            label: "Ubicación",
            value: actividad.ubicacion,
          ),
          const SizedBox(height: 8),
          ActivityInfoItem(
            icon: Icons.person,
            label: "Encargado",
            value: actividad.encargado,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
