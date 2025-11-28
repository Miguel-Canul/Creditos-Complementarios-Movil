import 'package:flutter/material.dart';
import '../models/actividad_historial.dart';
import '../models/historial_response.dart';
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

  double _totalCreditos = 0;
  double get totalCreditos => _totalCreditos;

  Map<String, dynamic> _creditosPorCategoria = {};
  Map<String, dynamic> get creditosPorCategoria => _creditosPorCategoria;

  int _totalInscripciones = 0;
  int get totalInscripciones => _totalInscripciones;

  // Cargar actividades desde la API
  Future<void> cargarActividades() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Opción 1: Si solo necesitas las actividades
      _actividades = await _repository.obtenerHistorialActividades();

      // Opción 2: Si necesitas toda la información del historial (créditos, etc.)
      final historialCompleto = await _repository.obtenerHistorialCompleto();

      _actividades =
          historialCompleto.historial.map((item) => item.actividad).toList();
      _totalCreditos = historialCompleto.totalCreditosAprobados;
      _creditosPorCategoria = historialCompleto.creditosPorCategoria;
      _totalInscripciones = historialCompleto.totalInscripciones;

      print('ViewModel: Se cargaron ${_actividades.length} actividades');
      print('ViewModel: Total créditos: $_totalCreditos');
      print('ViewModel: Total inscripciones: $_totalInscripciones');
    } catch (e) {
      _errorMessage = 'Error al cargar el historial: $e';
      print('Error en ViewModel: $e');
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
          .where((actividad) =>
              _formatearCategoria(actividad.categoria) == _filtroCategoria)
          .toList();
    }

    // Aplicar filtro de búsqueda
    if (_searchQuery.isNotEmpty) {
      actividadesFiltradas = actividadesFiltradas
          .where((actividad) =>
              actividad.nombre
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              _formatearCategoria(actividad.categoria)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return actividadesFiltradas;
  }

  // Obtener categorías únicas formateadas
  List<String> get categorias {
    final categorias = _actividades
        .map((a) => _formatearCategoria(a.categoria))
        .toSet()
        .toList();
    categorias.insert(0, 'Todas');
    return categorias;
  }

  // Formatear categoría (remover prefijo "CATEGORIA#")
  String _formatearCategoria(String categoria) {
    if (categoria.contains('#')) {
      return categoria.split('#').last;
    }
    return categoria;
  }

  // Buscar actividades
  void buscarActividades(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Obtener actividades por estado
  List<ActividadHistorial> obtenerActividadesPorEstado(String estado) {
    return _actividades
        .where((actividad) => actividad.estadoTexto == estado)
        .toList();
  }

  // Obtener estadísticas de actividades
  Map<String, int> obtenerEstadisticas() {
    final total = _actividades.length;
    final completadas = _actividades
        .where((actividad) => actividad.estadoTexto == 'Completado')
        .length;
    final enCurso = _actividades
        .where((actividad) => actividad.estadoTexto == 'En curso')
        .length;
    final esperandoAprobacion = _actividades
        .where((actividad) => actividad.estadoTexto == 'Esperando aprobación')
        .length;

    return {
      'total': total,
      'completadas': completadas,
      'enCurso': enCurso,
      'esperandoAprobacion': esperandoAprobacion,
    };
  }

  // Obtener créditos por categoría formateados
  Map<String, double> get creditosPorCategoriaFormateados {
    final Map<String, double> formateados = {};

    _creditosPorCategoria.forEach((key, value) {
      final categoriaFormateada = _formatearCategoria(key);
      formateados[categoriaFormateada] = (value as num).toDouble();
    });

    return formateados;
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

  // Obtener total de actividades filtradas
  int get totalActividadesFiltradas {
    return actividadesFiltradas.length;
  }

  // Verificar si hay datos
  bool get tieneDatos {
    return _actividades.isNotEmpty;
  }

  // Reiniciar estado
  void reiniciar() {
    _actividades = [];
    _totalCreditos = 0;
    _creditosPorCategoria = {};
    _totalInscripciones = 0;
    _errorMessage = '';
    limpiarFiltros();
    notifyListeners();
  }
}
