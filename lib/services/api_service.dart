import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/models/historial_response.dart';
import '../utils/constants.dart';
import '../models/Actividad_inscripcion.dart';

class ApiService {
  static const String baseURL = Constants.baseURL;
  static const Map<String, String> cabeceras = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Manejo centralizado de errores HTTP
  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Error HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  // Obtiene el total de créditos complementarios para un alumno.
  Future<double> obtenerCreditosComplementarios(String idAlumno) async {
    // 1. Construcción de la URL
    final String ruta = '${baseURL}alumnos/$idAlumno/creditos';
    final Uri url = Uri.parse(ruta);

    try {
      // 2. Ejecución de la petición GET
      final http.Response respuesta = await http.get(
        url,
        headers: cabeceras, // Uso de la constante estática
      );

      // 3. Manejo de Errores HTTP
      // Esto lanza una excepción si el estado no es 2xx.
      _handleError(respuesta);

      // 4. Parsing de la Respuesta JSON
      final respuestaJson = json.decode(respuesta.body);

      // 5. Extracción del número
      if (respuestaJson['data'] != null) {
        final Map<String, dynamic> datosCreditos = respuestaJson['data'];
        return datosCreditos['creditosObtenidos'] as double;
      }

      // Si 'data' es nulo o no contiene un número, devolvemos 0
      return 0;
    } catch (e) {
      print('Error al obtener créditos: $e');
      // Relanza la excepción para que el consumidor la maneje.
      rethrow;
    }
  }

  // Obtiene la URL de la constancia de liberación para un alumno.
  Future<String?> obtenerUrlConstanciaLiberacion(String idAlumno) async {
    // 1. Construcción de la URL
    final String ruta = '${baseURL}alumnos/$idAlumno/constancialiberacion';
    final Uri url = Uri.parse(ruta);

    try {
      // 2. Ejecución de la petición GET
      final http.Response respuesta = await http.get(
        url,
        headers: cabeceras,
      );

      // 3. Manejo de códigos de respuesta especiales
      if (respuesta.statusCode == 204) {
        return null;
      }

      // 4. Manejo de Errores HTTP
      _handleError(respuesta);

      // 5. Parsing de la Respuesta JSON (asumiendo 200 OK)
      final respuestaJson = json.decode(respuesta.body);

      // 6. Extracción de la URL
      if (respuestaJson['data'] != null) {
        final Map<String, dynamic> datosConstancia = respuestaJson['data'];

        // El valor extraído de la clave 'constanciaUrl' debe ser casteado a String.
        // Usamos String? por si la clave estuviera ausente.
        return datosConstancia['constanciaUrl'] as String?;
      }

      // Si el JSON es 200 pero 'data' está vacío, devolvemos null.
      return null;
    } catch (e) {
      print('Error al obtener URL de constancia: $e');
      // Relanza la excepción para que el consumidor la maneje.
      rethrow;
    }
  }

  Future<List<ActividadInscripcion>> obtenerActividadesDisponibles() async {
    // 1. Construcción de la URL
    final String ruta = '${baseURL}actividades/inscripcion';
    final Uri url = Uri.parse(ruta);

    try {
      // 2. Ejecución de la petición GET
      final http.Response respuesta = await http.get(
        url,
        headers: cabeceras,
      );

      // 3. Manejo de Errores HTTP (lanza excepción si el estado no es 2xx)
      _handleError(respuesta);

      // 4. Parsing de la Respuesta JSON
      final respuestaJson = json.decode(respuesta.body);

      // 5. Extracción de la lista de datos
      final List<dynamic> datosJson = respuestaJson['data'] ?? [];

      // 6. Conversión de la lista de JSONs a la lista de modelos Dart
      // Utiliza el constructor ActividadInscripcion.fromJson
      return datosJson
          .map((json) =>
              ActividadInscripcion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error al obtener actividades disponibles: $e');
      // Relanza la excepción para que el consumidor la maneje.
      rethrow;
    }
  }

  Future<HistorialResponse> obtenerHistorialActividades(String alumnoId) async {
    final String ruta = '${baseURL}movil/historialact?alumno_id=$alumnoId';
    final Uri url = Uri.parse(ruta);

    try {
      final http.Response respuesta = await http.get(
        url,
        headers: cabeceras,
      );

      _handleError(respuesta);

      final respuestaJson = json.decode(respuesta.body);
      return HistorialResponse.fromJson(respuestaJson);
    } catch (e) {
      print('Error al obtener historial de actividades: $e');
      rethrow;
    }
  }

  Future<bool> inscribirAlumno(String idAlumno, String idActividad) async {
    final String ruta = '${baseURL}alumnos/$idAlumno/inscripciones';
    final Uri url = Uri.parse(ruta);

    final Map<String, dynamic> cuerpo = {
      'idActividad': idActividad,
    };

    try {
      final http.Response respuesta = await http.post(
        url,
        headers: cabeceras,
        body: json.encode(cuerpo),
      );

      // Manejo específico del código 403 (Cupo lleno / Límite de créditos)
      if (respuesta.statusCode == 403) {
        final respuestaJson = json.decode(respuesta.body);
        final mensajeError =
            respuestaJson['message'] ?? 'Error de inscripción: Prohibido.';
        // Evitar efectos secundarios: Lanzar la excepción con el mensaje específico
        throw Exception(mensajeError);
      }

      // Manejo de otros errores HTTP (400, 404, 500, etc.)
      _handleError(respuesta);

      // Si el código es 201 Created (éxito)
      return true;
    } catch (e) {
      print('Error al inscribir alumno: $e');
      rethrow;
    }
  }

  Future<String> crearConstanciaLiberacion(String idAlumno) async {
    final String ruta = '${baseURL}alumnos/$idAlumno/constancialiberacion';
    final Uri url = Uri.parse(ruta);

    try {
      final http.Response respuesta = await http.post(
        url,
        headers: cabeceras,
        body: json.encode({}), // Cuerpo vacío
      );

      // Manejo de Errores HTTP
      _handleError(respuesta);

      // Si el código es 201 Created (éxito)
      final respuestaJson = json.decode(respuesta.body);

      // Ocultar la estructura interna: Extracción segura del URL
      if (respuestaJson['data'] != null) {
        final Map<String, dynamic> datosConstancia = respuestaJson['data'];
        final String? urlConstancia =
            datosConstancia['constanciaUrl'] as String?;
        if (urlConstancia != null) {
          return urlConstancia;
        }
      }

      throw Exception('La respuesta no contiene la URL de la constancia.');
    } catch (e) {
      print('Error al crear constancia de liberación: $e');
      rethrow;
    }
  }
}
