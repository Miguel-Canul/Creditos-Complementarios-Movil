import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/actividad_historial.dart';

class ActividadRepository {
  final String baseUrl;

  ActividadRepository({this.baseUrl = 'https://api.ejemplo.com'});

  Future<List<ActividadHistorial>> obtenerHistorialActividades() async {
    await Future.delayed(const Duration(seconds: 2));

    final datosSimulados = [
      {
        'id': '1',
        'nombre': 'Verano Delfín',
        'categoria': 'Extracurricular',
        'periodo': 'Junio - Julio 2024',
        'estado': 'Esperando aprobación',
        'folio': '',
        'desempenio': '',
        'fechaInicio': '2024-06-01',
        'fechaFin': '2024-07-31',
        'foto': 'assets/images/verano_delfin.png',
      },
      {
        'id': '2',
        'nombre': 'Atletismo',
        'categoria': 'Extraescolar',
        'periodo': 'Enero - Diciembre 2024',
        'estado': 'Completado',
        'folio': 'AUVUD2',
        'desempenio': 'Excelente',
        'fechaInicio': '2024-01-01',
        'fechaFin': '2024-12-31',
        'foto': 'assets/images/Atletismo.png',
      },
      {
        'id': '3',
        'nombre': 'Aproximaciones a la salud mental',
        'categoria': 'Taller',
        'periodo': '24/Sep - 30/Sep',
        'estado': 'En curso',
        'folio': 'AUVUD2',
        'desempenio': 'Suficiente',
        'fechaInicio': '2024-09-24',
        'fechaFin': '2024-09-30',
        'foto': 'assets/images/salud_mental.png',
      },
      {
        'id': '4',
        'nombre': 'Inclusión educativa y social',
        'categoria': 'Taller',
        'periodo': '1/Oct - 3/Oct',
        'estado': 'En curso',
        'folio': 'AUVUD2',
        'desempenio': 'Notable',
        'fechaInicio': '2024-10-01',
        'fechaFin': '2024-10-03',
        'foto': 'assets/images/inclusion_educativa.png',
      },
      {
        'id': '5',
        'nombre': 'Programación Avanzada',
        'categoria': 'Taller',
        'periodo': 'Ago - Nov 2024',
        'estado': 'Completado',
        'folio': 'AUVUD3',
        'desempenio': 'Excelente',
        'fechaInicio': '2024-08-01',
        'fechaFin': '2024-11-30',
        'foto': 'assets/images/programacion_avanzada.jpg',
      },
    ];

    return datosSimulados
        .map((json) => ActividadHistorial.fromJson(json))
        .toList();
  }

  // Método para obtener la ruta de la foto de una actividad específica
  Future<String> obtenerFotoActividad(String actividadId) async {
    final actividades = await obtenerHistorialActividades();
    final actividad = actividades.firstWhere(
      (act) => act.id == actividadId,
      orElse: () => ActividadHistorial(
        id: '',
        nombre: '',
        categoria: '',
        periodo: '',
        estado: '',
        folio: '',
        desempenio: '',
        fechaInicio: null,
        fechaFin: null,
        foto: 'assets/images/default_activity.jpg',
      ),
    );
    return actividad.foto;
  }

  // Método para obtener múltiples fotos de actividades
  Future<Map<String, String>> obtenerFotosActividades(
      List<String> actividadesIds) async {
    final actividades = await obtenerHistorialActividades();
    final Map<String, String> fotos = {};

    for (final id in actividadesIds) {
      final actividad = actividades.firstWhere(
        (act) => act.id == id,
        orElse: () => ActividadHistorial(
          id: id,
          nombre: '',
          categoria: '',
          periodo: '',
          estado: '',
          folio: '',
          desempenio: '',
          fechaInicio: null,
          fechaFin: null,
          foto: 'assets/images/default_activity.jpg',
        ),
      );
      fotos[id] = actividad.foto;
    }

    return fotos;
  }

  // Método para filtrar por categoría
  Future<List<ActividadHistorial>> obtenerActividadesPorCategoria(
      String categoria) async {
    final actividades = await obtenerHistorialActividades();
    return actividades
        .where((actividad) => actividad.categoria == categoria)
        .toList();
  }

  // Método para buscar actividades
  Future<List<ActividadHistorial>> buscarActividades(String query) async {
    final actividades = await obtenerHistorialActividades();
    return actividades
        .where((actividad) =>
            actividad.nombre.toLowerCase().contains(query.toLowerCase()) ||
            actividad.categoria.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Método para obtener todas las rutas de fotos disponibles
  Future<List<String>> obtenerTodasLasFotos() async {
    final actividades = await obtenerHistorialActividades();
    return actividades.map((actividad) => actividad.foto).toList();
  }
}
