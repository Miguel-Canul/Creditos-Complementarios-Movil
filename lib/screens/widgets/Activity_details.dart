import 'package:flutter/material.dart';
import 'package:mobile/screens/widgets/ActivityDescriptionWidget.dart';
import 'package:mobile/screens/widgets/ActivityHeaderWidget.dart';
import 'package:mobile/screens/widgets/activity_carousel.dart';
import '../../models/actividad_historial.dart';

// Clases y Objetos: Pequeñas, Principio de Responsabilidad Única
// Nombres Significativos: Contenido informativo de la actividad.
class ActivityInfoSection extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActivityInfoSection({
    super.key,
    required this.actividad,
  });

  @override
  Widget build(BuildContext context) {
    // Retorna el contenido principal con su Padding de alineación.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          /// HEADER (foto + nombre + categoría)
          ActivityHeaderWidget(actividad: actividad),

          const SizedBox(height: 20),

          /// DESCRIPCIÓN
          ActivityDescriptionWidget(descripcion: actividad.descripcion),

          const SizedBox(height: 20),

          /// CARRUSEL (Periodo + Horario)
          ActivityCarousel(actividad: actividad),
        ],
      ),
    );
  }
}