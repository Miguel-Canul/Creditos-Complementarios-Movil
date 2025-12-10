// screens/estudiante_dashboard/widgets/activities_data_controller.dart

import 'package:flutter/material.dart';
import '../../../../../utils/constants.dart';
import '../../../../../services/api_service.dart';
import '../../../../../models/actividad_inscripcion.dart';
import 'category_carousel_section.dart'; // Nuevo widget de carrusel

class ActivitiesDataController extends StatefulWidget {
  const ActivitiesDataController({super.key});

  @override
  State<ActivitiesDataController> createState() => _ActivitiesDataControllerState();
}

class _ActivitiesDataControllerState extends State<ActivitiesDataController> {
  final ApiService _servicioApi = ApiService(); 

  List<ActividadInscripcion> _todasActividades = [];
  bool _estaCargando = true;
  bool _hayError = false;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScreenTitle(),
        const SizedBox(height: 16),
        
        if (_estaCargando) _buildLoadingIndicator(),
        if (_hayError) _buildErrorMessage(),
        if (!_estaCargando && !_hayError) _buildDynamicSections(),
      ],
    );
  }

  // Método: Construye las secciones dinámicas
  Widget _buildDynamicSections() {
    final Map<String, List<ActividadInscripcion>> grupos = _actividadesAgrupadas;

    if (grupos.isEmpty) {
      return _buildEmptyState();
    }
    
    // Mapea los grupos a los widgets CategoryCarouselSection
    final List<Widget> secciones = grupos.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CategoryCarouselSection(
          titulo: entry.key,
          actividades: entry.value,
        ),
      );
    }).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: secciones,
    );
  }

  // --- Widgets de estado (mantienen la responsabilidad de mostrar el estado) ---

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