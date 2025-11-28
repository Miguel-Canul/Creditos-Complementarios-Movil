// screens/estudiante_dashboard/widgets/category_carousel_section.dart

import 'package:flutter/material.dart';
import '../../../../../models/Actividad_inscripcion.dart';
import 'activity_card.dart'; // Nuevo widget de tarjeta

class CategoryCarouselSection extends StatelessWidget {
  final String titulo;
  final List<ActividadInscripcion> actividades;

  const CategoryCarouselSection({
    super.key,
    required this.titulo,
    required this.actividades,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionTitle(titulo),
          const SizedBox(height: 12),
          _buildCarousel(actividades),
        ],
      ),
    );
  }

  // Método: Construye el encabezado de la sección (ej. 'Deportivos')
  Widget _buildSubsectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // Método: Construye el Carrusel (ListView.builder)
  Widget _buildCarousel(List<ActividadInscripcion> activities) {
    final int baseCount = activities.length;

    return SizedBox(
      height: 120, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: baseCount,
        itemBuilder: (context, index) {
          final ActividadInscripcion actividad = activities[index];
          // Delega la creación del item a ActivityCard
          return ActivityCard(actividad: actividad); 
        },
      ),
    );
  }
}