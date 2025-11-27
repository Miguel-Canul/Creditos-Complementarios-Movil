import 'package:flutter/material.dart';
import '../models/actividad_historial.dart';
import '../repositories/actividad_repository.dart';

class ActividadViewModel with ChangeNotifier {
  final ActividadRepository _repository;

  ActividadViewModel(this._repository);

  List<ActividadHistorial> _actividades = [];
  List<ActividadHistorial> get actividades => _actividades;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _filtroCategoria = 'Todas';
  String get filtroCategoria => _filtroCategoria;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Cargar actividades
  Future<void> cargarActividades() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _actividades = await _repository.obtenerHistorialActividades();
    } catch (e) {
      _errorMessage = 'Error al cargar las actividades: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtrar por categoría
  void filtrarPorCategoria(String categoria) {
    _filtroCategoria = categoria;
    notifyListeners();
  }

  // Obtener actividades filtradas
  List<ActividadHistorial> get actividadesFiltradas {
    List<ActividadHistorial> actividadesFiltradas = _actividades;

    // Aplicar filtro de categoría
    if (_filtroCategoria != 'Todas') {
      actividadesFiltradas = actividadesFiltradas
          .where((actividad) => actividad.categoria == _filtroCategoria)
          .toList();
    }

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      actividadesFiltradas = actividadesFiltradas
          .where((actividad) =>
              actividad.nombre
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              actividad.categoria
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return actividadesFiltradas;
  }

  // Obtener categorías únicas
  List<String> get categorias {
    final categorias = _actividades.map((a) => a.categoria).toSet().toList();
    categorias.insert(0, 'Todas');
    return categorias;
  }

  // Buscar actividades
  void buscarActividades(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Obtener foto de una actividad específica
  Future<String> obtenerFotoActividad(String actividadId) async {
    try {
      return await _repository.obtenerFotoActividad(actividadId);
    } catch (e) {
      return 'assets/images/default_activity.jpg';
    }
  }

  // Obtener actividades por estado
  List<ActividadHistorial> obtenerActividadesPorEstado(String estado) {
    return _actividades
        .where((actividad) => actividad.estado == estado)
        .toList();
  }

  // Obtener estadísticas de actividades
  Map<String, int> obtenerEstadisticas() {
    final total = _actividades.length;
    final completadas = _actividades
        .where((actividad) => actividad.estado == 'Completado')
        .length;
    final enCurso = _actividades
        .where((actividad) => actividad.estado == 'En curso')
        .length;
    final esperandoAprobacion = _actividades
        .where((actividad) => actividad.estado == 'Esperando aprobación')
        .length;

    return {
      'total': total,
      'completadas': completadas,
      'enCurso': enCurso,
      'esperandoAprobacion': esperandoAprobacion,
    };
  }

  // Limpiar filtros
  void limpiarFiltros() {
    _filtroCategoria = 'Todas';
    _searchQuery = '';
    notifyListeners();
  }

  // Verificar si hay filtros activos
  bool get hayFiltrosActivos {
    return _filtroCategoria != 'Todas' || _searchQuery.isNotEmpty;
  }
}
