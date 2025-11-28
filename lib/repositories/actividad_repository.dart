import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/actividad_historial.dart';
import '../models/historial_response.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ActividadRepository {
  final ApiService _apiService;
  final AuthService _authService;

  ActividadRepository({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  Future<List<ActividadHistorial>> obtenerHistorialActividades() async {
    try {
      // Obtener el ID del alumno desde el servicio de autenticación
      final alumnoId = await _obtenerAlumnoId();
      print('Obteniendo historial para alumno ID: $alumnoId');

      // Usar el método que agregamos al ApiService
      final historialResponse =
          await _apiService.obtenerHistorialActividades(alumnoId);

      // Extraer solo las actividades del historial
      final actividades =
          historialResponse.historial.map((item) => item.actividad).toList();

      print('Se obtuvieron ${actividades.length} actividades del historial');
      return actividades;
    } catch (e) {
      print('Error en repositorio al obtener historial: $e');
      rethrow;
    }
  }

  Future<String> _obtenerAlumnoId() async {
    try {
      // Verificar si el usuario está autenticado
      if (!_authService.isAuthenticated) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el sub (ID único) del usuario desde AuthService
      final userSub = _authService.userSub;

      if (userSub == null || userSub.isEmpty) {
        throw Exception('No se pudo obtener el ID del alumno (userSub)');
      }

      print('ID del alumno obtenido desde AuthService: $userSub');
      return userSub;
    } catch (e) {
      print('Error al obtener alumnoId: $e');
      rethrow;
    }
  }

  Future<String> obtenerFotoActividad(String actividadId) async {
    // Esta implementación depende de cómo manejes las fotos
    // Por ahora devolvemos una URL genérica o podrías hacer otra llamada API
    return 'https://via.placeholder.com/300x150?text=Actividad+$actividadId';
  }

  // Método adicional para obtener el historial completo (si lo necesitas)
  Future<HistorialResponse> obtenerHistorialCompleto() async {
    try {
      final alumnoId = await _obtenerAlumnoId();
      return await _apiService.obtenerHistorialActividades(alumnoId);
    } catch (e) {
      print('Error al obtener historial completo: $e');
      rethrow;
    }
  }
}
