// screens/estudiante_dashboard/widgets/available_activities_section.dart

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../../../services/api_service.dart';
import '../../../models/Actividad_inscripcion.dart';

// El paquete CarouselSlider es necesario para un carrusel verdaderamente circular.
// Usaremos un ListView.builder con itemCount infinito para simular el desplazamiento circular.

class AvailableActivitiesSection extends StatefulWidget {
  const AvailableActivitiesSection({super.key});

  @override
  State<AvailableActivitiesSection> createState() => _AvailableActivitiesSectionState();
}

class _AvailableActivitiesSectionState extends State<AvailableActivitiesSection> {
  // 1. Inyección de Dependencias (manual)
  final ApiService _servicioApi = ApiService(); 

  // 2. Variables de Estado
  List<ActividadInscripcion> _todasActividades = [];
  bool _estaCargando = true;
  bool _hayError = false;

  // 3. Método para agrupar Actividades por Categoría
  // Retorna un Map donde la clave es la categoría y el valor es la lista de actividades.
  Map<String, List<ActividadInscripcion>> get _actividadesAgrupadas {
    final Map<String, List<ActividadInscripcion>> grupos = {};
    for (var actividad in _todasActividades) {
      if (!grupos.containsKey(actividad.categoria)) {
        grupos[actividad.categoria] = [];
      }
      grupos[actividad.categoria]!.add(actividad);
    }
    return grupos;
  }

  @override
  void initState() {
    super.initState();
    _cargarActividades();
  }

  // 4. Método para Consumir el Servicio
  void _cargarActividades() async {
    try {
      final actividades = await _servicioApi.obtenerActividadesDisponibles();
      setState(() {
        _todasActividades = actividades;
        _estaCargando = false;
        _hayError = false;
      });
    } catch (e) {
      print('Error al cargar actividades: $e');
      setState(() {
        _estaCargando = false;
        _hayError = true;
        _todasActividades = [];
      });
    }
  }

  // 5. El método build ahora usa el estado para mostrar UI
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScreenTitle(),
            const SizedBox(height: 16),
            
            // Lógica de estado de carga/error
            if (_estaCargando) _buildLoadingIndicator(),
            if (_hayError) _buildErrorMessage(),
            if (!_estaCargando && !_hayError) _buildDynamicSections(),
          ],
        ),
      ),
    );
  }

  // Método: Construye las secciones dinámicas
  Widget _buildDynamicSections() {
    final Map<String, List<ActividadInscripcion>> grupos = _actividadesAgrupadas;

    if (grupos.isEmpty) {
      return _buildEmptyState();
    }
    
    // Convertir el mapa de grupos en una lista de Widgets de Sección/Tarjeta
    final List<Widget> secciones = grupos.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildSectionCard(
          title: entry.key,
          activities: entry.value,
        ),
      );
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: secciones,
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

  // Método: Construye la Tarjeta Contenedora de la Sección y Agrupa Subsecciones
  Widget _buildSectionCard({
    required String title,
    required List<ActividadInscripcion> activities,
  }) {
    // La tarjeta ahora es una sección completa con su título y carrusel
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
          _buildSubsectionTitle(title), // Título de la Categoría
          const SizedBox(height: 12),
          _buildCarousel(activities), // Carrusel de Actividades
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
  
  // Método: Construye el Carrusel (ListView.builder 'circular')
  Widget _buildCarousel(List<ActividadInscripcion> activities) {
    // Para simular el scroll infinito (circular) sin packages
    final int baseCount = activities.length;

    return SizedBox(
      height: 120, // Altura para los elementos y sus títulos
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: baseCount,
        itemBuilder: (context, index) {
          // Usar el operador módulo (%) para repetir los datos
          final ActividadInscripcion actividad = activities[index];
          return _buildCarouselItem(context, actividad);
        },
      ),
    );
  }

  // --- Componente: Tarjeta de Actividad/Taller de Carrusel ---
// [MODIFICACIÓN EN _buildCarouselItem]

// --- Componente: Tarjeta de Actividad/Taller de Carrusel ---
Widget _buildCarouselItem(BuildContext context, ActividadInscripcion actividad) {
  return GestureDetector(
    onTap: () {
      // Navegación limpia: Pasar el objeto completo a la siguiente pantalla
      // Necesitas crear el destino (ej: DetalleActividadScreen)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DetalleActividadScreen(actividad: actividad),
      //   ),
      // );
      print('Clic en actividad: ${actividad.nombre}. Objeto completo pasado.');
    },
    child: Container(
      width: 100, // Ancho fijo para el carrusel
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          _buildActivityAvatar(actividad.fotoUrl),
          const SizedBox(height: 8), 
          _buildActivityTitle(actividad.nombre),
        ],
      ),
    ),
  );
}

  // Método: Construye el Avatar (Imagen o Icono de reemplazo)
  Widget _buildActivityAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 35,
      backgroundColor: const Color(Constants.primaryColor).withAlpha(10),
      child: ClipOval(
        child: Image.network(
          imageUrl,
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
  
  // --- Estados de la UI ---
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          '⚠️ Error al cargar las actividades. Inténtalo de nuevo.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(Constants.dangerColor)),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          '🎉 ¡No hay actividades disponibles para inscripción!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(Constants.secondaryColor)),
        ),
      ),
    );
  }
}