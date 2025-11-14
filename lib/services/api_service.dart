import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para kIsWeb
import '../models/estudiante.dart';
import '../models/actividad.dart';
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
      throw Exception(
          'Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
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

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      _handleError(response);

      final List<dynamic> jsonList = json.decode(response.body);
      final estudiantes =
          jsonList.map((json) => Estudiante.fromJson(json)).toList();

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

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

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

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      _handleError(response);

      final List<dynamic> jsonList = json.decode(response.body);
      final actividades =
          jsonList.map((json) => Actividad.fromJson(json)).toList();

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

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

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

  // Método para verificar conectividad con la API
  Future<bool> verificarConectividad() async {
    try {
      final url = '$baseUrl/api/Estudiantes';
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error de conectividad: $e');
      return false;
    }
  }
}
