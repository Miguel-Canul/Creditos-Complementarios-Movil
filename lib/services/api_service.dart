import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para kIsWeb
import '../models/estudiante.dart';
import '../models/actividad.dart';
import '../models/asistencia.dart';
import '../models/asistencia_detalle.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // URL base que se ajusta según la plataforma
  String get baseUrl {
    if (kIsWeb) {
      // Para Flutter Web usar localhost directo
      return 'http://localhost:5273';
    } else {
      // Para móviles usar las URLs de constants
      return Constants.apiUrlAndroid; // Para Android Emulator
    }
  }
  
  // Headers comunes para todas las peticiones
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Manejo centralizado de errores HTTP
  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
      print('Response body: ${response.body}');
      throw Exception('Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Método para hacer logs de las peticiones
  void _logRequest(String method, String url, {Map<String, dynamic>? body}) {
    print('🌐 $method: $url');
    if (body != null) {
      print('📤 Body: ${json.encode(body)}');
    }
  }

  // SERVICIOS PARA ESTUDIANTES
  Future<List<Estudiante>> getEstudiantes() async {
    try {
      final url = '$baseUrl/api/Estudiantes';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      final List<dynamic> jsonList = json.decode(response.body);
      final estudiantes = jsonList.map((json) => Estudiante.fromJson(json)).toList();
      
      print('Estudiantes obtenidos: ${estudiantes.length}');
      return estudiantes;
    } catch (e) {
      print('Error al obtener estudiantes: $e');
      return [];
    }
  }

  Future<Estudiante?> getEstudiante(String numeroControl) async {
    try {
      final url = '$baseUrl/api/Estudiantes/$numeroControl';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 404) {
        print('Estudiante no encontrado: $numeroControl');
        return null;
      }
      
      _handleError(response);
      
      final estudiante = Estudiante.fromJson(json.decode(response.body));
      print('Estudiante obtenido: ${estudiante.nombre}');
      return estudiante;
    } catch (e) {
      print('Error al obtener estudiante: $e');
      return null;
    }
  }

  // SERVICIOS PARA ACTIVIDADES
  Future<List<Actividad>> getActividades() async {
    try {
      final url = '$baseUrl/api/Actividades';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      final List<dynamic> jsonList = json.decode(response.body);
      final actividades = jsonList.map((json) => Actividad.fromJson(json)).toList();
      
      print('Actividades obtenidas: ${actividades.length}');
      return actividades;
    } catch (e) {
      print('Error al obtener actividades: $e');
      return [];
    }
  }

  Future<Actividad?> getActividad(int id) async {
    try {
      final url = '$baseUrl/api/Actividades/$id';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 404) {
        print('Actividad no encontrada: $id');
        return null;
      }
      
      _handleError(response);
      
      final actividad = Actividad.fromJson(json.decode(response.body));
      print('Actividad obtenida: ${actividad.nombre}');
      return actividad;
    } catch (e) {
      print('Error al obtener actividad: $e');
      return null;
    }
  }

  // SERVICIOS PARA ASISTENCIAS
  Future<List<AsistenciaDetalle>> getAsistencias() async {
    try {
      final url = '$baseUrl/api/Asistencias';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 15));
      
      _handleError(response);
      
      final List<dynamic> jsonList = json.decode(response.body);
      final asistencias = jsonList.map((json) => AsistenciaDetalle.fromJson(json)).toList();
      
      print('Asistencias obtenidas: ${asistencias.length}');
      return asistencias;
    } catch (e) {
      print('Error al obtener asistencias: $e');
      return [];
    }
  }

  Future<AsistenciaDetalle?> getAsistencia(int id) async {
    try {
      final url = '$baseUrl/api/Asistencias/$id';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 404) {
        print('Asistencia no encontrada: $id');
        return null;
      }
      
      _handleError(response);
      
      final asistencia = AsistenciaDetalle.fromJson(json.decode(response.body));
      print('Asistencia obtenida: ${asistencia.nombreEstudiante}');
      return asistencia;
    } catch (e) {
      print('Error al obtener asistencia: $e');
      return null;
    }
  }

  Future<List<AsistenciaDetalle>> getAsistenciasPorEstudiante(String numeroControl) async {
    try {
      final url = '$baseUrl/api/Asistencias/Estudiante/$numeroControl';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      final List<dynamic> jsonList = json.decode(response.body);
      final asistencias = jsonList.map((json) => AsistenciaDetalle.fromJson(json)).toList();
      
      print('Asistencias por estudiante obtenidas: ${asistencias.length}');
      return asistencias;
    } catch (e) {
      print('Error al obtener asistencias por estudiante: $e');
      return [];
    }
  }

  Future<List<AsistenciaDetalle>> getAsistenciasPorActividad(int actividadId) async {
    try {
      final url = '$baseUrl/api/Asistencias/Actividad/$actividadId';
      _logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      final List<dynamic> jsonList = json.decode(response.body);
      final asistencias = jsonList.map((json) => AsistenciaDetalle.fromJson(json)).toList();
      
      print('Asistencias por actividad obtenidas: ${asistencias.length}');
      return asistencias;
    } catch (e) {
      print('Error al obtener asistencias por actividad: $e');
      return [];
    }
  }

  Future<bool> crearAsistencia(Map<String, dynamic> asistenciaData) async {
    try {
      final url = '$baseUrl/api/Asistencias';
      _logRequest('POST', url, body: asistenciaData);
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(asistenciaData),
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      print('Asistencia creada exitosamente');
      return true;
    } catch (e) {
      print('Error al crear asistencia: $e');
      return false;
    }
  }

  Future<bool> actualizarAsistencia(int id, Map<String, dynamic> asistenciaData) async {
    try {
      asistenciaData['id'] = id;
      
      final url = '$baseUrl/api/Asistencias/$id';
      _logRequest('PUT', url, body: asistenciaData);
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(asistenciaData),
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      print('Asistencia actualizada exitosamente');
      return true;
    } catch (e) {
      print('Error al actualizar asistencia: $e');
      return false;
    }
  }

  Future<bool> eliminarAsistencia(int id) async {
    try {
      final url = '$baseUrl/api/Asistencias/$id';
      _logRequest('DELETE', url);
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 10));
      
      _handleError(response);
      
      print('Asistencia eliminada exitosamente');
      return true;
    } catch (e) {
      print('Error al eliminar asistencia: $e');
      return false;
    }
  }

  // MÉTODOS DE FILTRADO (procesamiento del lado cliente)
  List<AsistenciaDetalle> filtrarAsistencias(List<AsistenciaDetalle> asistencias, String searchTerm) {
    if (searchTerm.isEmpty) return asistencias;
    
    final termino = searchTerm.toLowerCase();
    return asistencias.where((asistencia) {
      return asistencia.numeroControl.toLowerCase().contains(termino) ||
             asistencia.nombreEstudiante.toLowerCase().contains(termino) ||
             asistencia.carreraEstudiante.toLowerCase().contains(termino) ||
             asistencia.nombreActividad.toLowerCase().contains(termino) ||
             asistencia.encargado.toLowerCase().contains(termino);
    }).toList();
  }

  List<AsistenciaDetalle> filtrarPorFecha(List<AsistenciaDetalle> asistencias, DateTime? fecha) {
    if (fecha == null) return asistencias;
    
    return asistencias.where((asistencia) {
      final fechaAsistencia = DateTime(
        asistencia.fechaHora.year,
        asistencia.fechaHora.month,
        asistencia.fechaHora.day,
      );
      final fechaFiltro = DateTime(fecha.year, fecha.month, fecha.day);
      
      return fechaAsistencia.isAtSameMomentAs(fechaFiltro);
    }).toList();
  }

  List<AsistenciaDetalle> filtrarPorMesAnio(List<AsistenciaDetalle> asistencias, int? mes, int? anio) {
    List<AsistenciaDetalle> resultado = List.from(asistencias);
    
    if (anio != null) {
      resultado = resultado.where((asistencia) => asistencia.fechaHora.year == anio).toList();
    }
    
    if (mes != null) {
      resultado = resultado.where((asistencia) => asistencia.fechaHora.month == mes).toList();
    }
    
    return resultado;
  }

  // Método para verificar conectividad con la API
  Future<bool> verificarConectividad() async {
    try {
      final url = '$baseUrl/api/Estudiantes';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error de conectividad: $e');
      return false;
    }
  }
}