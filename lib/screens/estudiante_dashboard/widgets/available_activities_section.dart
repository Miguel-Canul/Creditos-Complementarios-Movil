// screens/estudiante_dashboard/widgets/available_activities_section.dart

import 'package:flutter/material.dart';
import '../../../models/activity_data.dart';
import '../../../utils/constants.dart';

class AvailableActivitiesSection extends StatelessWidget {
  const AvailableActivitiesSection({super.key});

  // Datos de imagen temporal (debería venir de un Controller/Service/Padre)
  final String _imageUrlPlaceholder = 'https://yt3.googleusercontent.com/K7DvodCSwUravld3sfWgVCF_uhWgmgYh5MLPDvv7htu5xxZbIJr_qXVkZT68mxgZTiAdXpM1GQk=s900-c-k-c0x00ffffff-no-rj';

  // --- Componente: Tarjeta de Actividad/Taller de Carrusel ---
  Widget _buildCarouselItem(String title) {
    return Container(
      width: 100, // Ancho fijo para el carrusel
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(Constants.primaryColor).withValues(alpha: 0.1),
            child: ClipOval(
              child: Image.network(
                _imageUrlPlaceholder,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.star, // Icono de reemplazo si la imagen falla
                    size: 30,
                    color: Color(Constants.primaryColor),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  // Tarjeta contenedora para Extraescolares y Talleres
  Widget _buildSectionCard({
    required String title,
    required List<Widget> subSections,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subSections,
      ),
    );
  }
  
  // Subsección con Carrusel
  Widget _buildSubsection({
    required String title,
    required List<Map<String, String>> activities,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Altura para los elementos y sus títulos
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(activities[index]['title']!);
            },
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Actividades Disponibles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(Constants.primaryColor), // Título centrado y en negritas
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sección Extraescolares
            _buildSectionCard(
              title: 'Extraescolares',
              subSections: [
                // Deportivas
                _buildSubsection(
                    title: 'Deportivos', activities: extraescolaresDeportivasData),
                const SizedBox(height: 16),
                // Cívicas y culturales
                _buildSubsection(
                    title: 'Cívicos y culturales', activities: extraescolaresCivicasData),
              ],
            ),

            const SizedBox(height: 16),

            // Sección Talleres
            _buildSectionCard(
              title: 'Talleres',
              subSections: [
                _buildSubsection(title: 'Talleres', activities: talleresData),
              ],
            ),
          ],
        ),
      ),
    );
  }
}