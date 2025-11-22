// screens/estudiante_dashboard/widgets/available_activities_section.dart

import 'package:flutter/material.dart';
import '../../../models/activity_data.dart';
import '../../../utils/constants.dart';

class AvailableActivitiesSection extends StatelessWidget {
  const AvailableActivitiesSection({super.key});

  // Datos de imagen temporal (debería venir de un Controller/Service/Padre)
  final String _imageUrlPlaceholder =
      'https://yt3.googleusercontent.com/K7DvodCSwUravld3sfWgVCF_uhWgmgYh5MLPDvv7htu5xxZbIJr_qXVkZT68mxgZTiAdXpM1GQk=s900-c-k-c0x00ffffff-no-rj';

  @override
  Widget build(BuildContext context) {
    final List<Widget> extraescolaresSubSections = [
      _buildSubsection(
        title: 'Deportivos',
        activities: extraescolaresDeportivasData,
      ),
      const SizedBox(height: 16),
      _buildSubsection(
        title: 'Cívicos y culturales',
        activities: extraescolaresCivicasData,
      ),
    ];
    final List<Widget> talleresSubSections = [
      _buildSubsection(
        title: 'Talleres',
        activities: talleresData,
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScreenTitle(),
            const SizedBox(height: 16),

            // Sección Extraescolares
            _buildSectionCard(subSections: extraescolaresSubSections),

            const SizedBox(height: 16),

            // Sección Talleres
            _buildSectionCard(subSections: talleresSubSections),
          ],
        ),
      ),
    );
  }

    // Subsección con Carrusel - AHORA SOLO ENSAMBLA
  Widget _buildSubsection({
    required String title,
    required List<Map<String, String>> activities,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubsectionTitle(title),
        const SizedBox(height: 12), // Espacio va DENTRO del método
        _buildCarousel(activities),
      ],
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
  Widget _buildCarousel(List<Map<String, String>> activities) {
    return SizedBox(
      height: 120, // Altura para los elementos y sus títulos
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return _buildCarouselItem(activities[index]['title']!);
        },
      ),
    );
  }

    // --- Componente: Tarjeta de Actividad/Taller de Carrusel - AHORA SOLO ENSAMBLA ---
  Widget _buildCarouselItem(String title) {
    return Container(
      width: 100, // Ancho fijo para el carrusel
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          _buildActivityAvatar(),
          const SizedBox(height: 8), // El espacio va DENTRO del item
          _buildActivityTitle(title),
        ],
      ),
    );
  }

      // Método: Construye el Avatar (Imagen o Icono de reemplazo)
  Widget _buildActivityAvatar() {
    return CircleAvatar(
      radius: 35,
      // Usamos Colors.blue.withOpacity(0.1) o similar, pero simulamos tu función 'withValues'
      backgroundColor:
          const Color(Constants.primaryColor).withValues(alpha: .1),
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
    );
  }

  // Método: Construye el título del elemento del carrusel
  Widget _buildActivityTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // --- Nivel Intermedio: Ensamblaje de Componentes ---

      // Método: Construye el Título General de la Pantalla
  Widget _buildScreenTitle() {
    return const Center(
      child: Text(
        'Actividades Disponibles',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(Constants.primaryColor),
        ),
      ),
    );
  }

    // Método: Construye la Tarjeta Contenedora de la Sección - AHORA SOLO ENSAMBLA
  Widget _buildSectionCard({
    required List<Widget> subSections,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subSections, // Lista de subsecciones ya construidas
      ),
    );
  }

}
