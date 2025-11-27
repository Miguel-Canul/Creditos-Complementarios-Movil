import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Estado de autenticación
  bool _isAuthenticated = false;
  String? _userToken;
  Map<String, dynamic>? _userInfo;
  String? _userRole;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get userRole => _userRole;
  String? get userName =>
      _userInfo?['nombreCompleto'] ?? _userInfo?['username'];
  String? get userEmail => _userInfo?['email'];

  // URL base para autenticación (igual que Angular)
  String get baseUrl {
    return Constants.baseURL;
  }

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_userToken != null) 'Authorization': 'Bearer $_userToken',
      };

  // Inicializar servicio al arrancar la app
  Future<void> initialize() async {
    await _verificarSesionExistente();
  }

  // Verificar si hay una sesión guardada
  Future<void> _verificarSesionExistente() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('userToken');
      final userInfoString = prefs.getString('userInfo');
      final role = prefs.getString('userRole');

      if (token != null && userInfoString != null && role != null) {
        _userToken = token;
        _userInfo = json.decode(userInfoString);
        _userRole = role;
        _isAuthenticated = true;

        print('Sesión existente encontrada para: ${_userInfo?['email']}');
        notifyListeners();
      }
    } catch (e) {
      print('Error al verificar sesión existente: $e');
      await logout();
    }
  }

  // LOGIN PRINCIPAL
  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      print('Intentando login para: $email');

      final loginData = {
        'email': email.trim(),
        'password': password,
      };

      // Llamada real al endpoint de login
      final url = '$baseUrl/api/Auth/login';
      print('🌐 POST: $url');
      print('📤 Body: ${json.encode(loginData)}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(loginData),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extraer información del usuario desde la respuesta
        _userToken = responseData['token'];
        _userInfo = {
          'email': responseData['email'] ?? email,
          'nombreCompleto':
              responseData['nombreCompleto'] ?? responseData['name'],
          'username':
              responseData['username'] ?? responseData['email']?.split('@')[0],
          'role': responseData['role'] ?? 'Estudiante',
          'id': responseData['id'],
          'numeroControl': responseData['numeroControl'], // Para estudiantes
        };
        _userRole = responseData['role'] ?? 'Estudiante';

        // Guardar credenciales si el usuario lo solicita
        if (rememberMe) {
          await _guardarCredenciales(email, password);
        }

        await _guardarSesion();

        _isAuthenticated = true;
        notifyListeners();

        print('Login exitoso para: $email');
        return true;
      } else if (response.statusCode == 401) {
        print('Credenciales inválidas');
        return false;
      } else {
        print('Error del servidor: ${response.statusCode}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en login: $e');

      return false;
    }
  }

  // REGISTRO
  Future<bool> registro(
      String nombreCompleto, String email, String password) async {
    try {
      print('Intentando registro para: $email');

      final registroData = {
        'nombreCompleto': nombreCompleto.trim(),
        'email': email.trim(),
        'password': password,
        'confirmPassword': password,
      };

      final url = '$baseUrl/api/Auth/register';
      print('🌐 POST: $url');
      print('📤 Body: ${json.encode(registroData)}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(registroData),
          )
          .timeout(const Duration(seconds: 15));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Registro exitoso para: $email');
        return true;
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        print(
            'Error de validación: ${errorData['message'] ?? 'Datos inválidos'}');
        return false;
      } else if (response.statusCode == 409) {
        print('Usuario ya existe');
        return false;
      } else {
        print('Error del servidor: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  // VERIFICAR EMAIL (activación de cuenta)
  Future<bool> verificarEmail(String token) async {
    try {
      print('Verificando email con token');

      final url =
          '$baseUrl/api/Auth/verify-email?token=${Uri.encodeComponent(token)}';
      print('🌐 GET: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Email verificado exitosamente');
        return true;
      } else {
        print('Error al verificar email: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en verificación de email: $e');
      return false;
    }
  }

  // REFRESH TOKEN
  Future<bool> refreshToken() async {
    try {
      if (_userToken == null) return false;

      print('Refrescando token');

      final url = '$baseUrl/api/Auth/refresh-token';
      print('🌐 POST: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _userToken = responseData['token'];

        await _guardarSesion();
        notifyListeners();

        print('Token refrescado exitosamente');
        return true;
      } else {
        print('Error al refrescar token, cerrando sesión');
        await logout();
        return false;
      }
    } catch (e) {
      print('Error en refresh token: $e');
      await logout();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Intentar logout en el servidor
      if (_userToken != null) {
        try {
          final url = '$baseUrl/api/Auth/logout';
          await http
              .post(
                Uri.parse(url),
                headers: headers,
              )
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          print('Error al hacer logout en servidor: $e');
        }
      }

      final prefs = await SharedPreferences.getInstance();

      // Limpiar datos de sesión
      await prefs.remove('userToken');
      await prefs.remove('userInfo');
      await prefs.remove('userRole');

      // Reset estado
      _isAuthenticated = false;
      _userToken = null;
      _userInfo = null;
      _userRole = null;

      notifyListeners();

      print('Logout exitoso');
    } catch (e) {
      print('Error en logout: $e');
    }
  }

  // Guardar sesión actual
  Future<void> _guardarSesion() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_userToken != null && _userInfo != null && _userRole != null) {
        await prefs.setString('userToken', _userToken!);
        await prefs.setString('userInfo', json.encode(_userInfo!));
        await prefs.setString('userRole', _userRole!);

        print('Sesión guardada exitosamente');
      }
    } catch (e) {
      print('Error al guardar sesión: $e');
    }
  }

  // Guardar credenciales para recordar usuario
  Future<void> _guardarCredenciales(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);

      print('Credenciales guardadas para recordar');
    } catch (e) {
      print('Error al guardar credenciales: $e');
    }
  }

  // Obtener credenciales guardadas
  Future<Map<String, String>?> obtenerCredencialesGuardadas() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');

      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }

      return null;
    } catch (e) {
      print('Error al obtener credenciales guardadas: $e');
      return null;
    }
  }

  // Limpiar credenciales guardadas
  Future<void> limpiarCredencialesGuardadas() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('saved_email');
      await prefs.remove('saved_password');

      print('Credenciales guardadas eliminadas');
    } catch (e) {
      print('Error al limpiar credenciales: $e');
    }
  }

  // Verificar si el token sigue siendo válido
  Future<bool> verificarToken() async {
    if (_userToken == null) return false;

    try {
      final url = '$baseUrl/api/Auth/validate-token';
      print('🌐 GET: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      print('📥 Token validation status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refresh
        return await refreshToken();
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      print('Error al verificar token: $e');
      // En caso de error de red, asumir que el token es válido temporalmente
      return true;
    }
  }

  // Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      if (!_isAuthenticated) return null;

      final url = '$baseUrl/api/Auth/profile';
      print('🌐 GET: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print('📥 Profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);

        // Actualizar información local
        _userInfo = {
          ..._userInfo!,
          ...profileData,
        };

        await _guardarSesion();
        notifyListeners();

        return profileData;
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      }

      return null;
    } catch (e) {
      print('Error al obtener perfil: $e');
      return null;
    }
  }

  // Obtener rol del usuario actual (igual que Angular)
  String? getCurrentUserRole() {
    return _userRole;
  }

  // Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return _userRole == role;
  }

  // Obtener número de control (solo para estudiantes)
  String? get numeroControl {
      return _userInfo!['numeroControl'];
  }

  // Refrescar información del usuario
  Future<void> refrescarUsuario() async {
    if (!_isAuthenticated || _userToken == null) return;

    try {
      await obtenerPerfil();
    } catch (e) {
      print('Error al refrescar usuario: $e');
    }
  }

  // Verificar conectividad con el servidor de autenticación
  Future<bool> verificarConectividad() async {
    try {
      final url = '$baseUrl/api/Auth/health';
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Error de conectividad auth: $e');
      return false;
    }
  }

  // Método para cerrar todas las sesiones del usuario
  Future<bool> cerrarTodasLasSesiones() async {
    try {
      if (!_isAuthenticated) return false;

      final url = '$baseUrl/api/Auth/logout-all';
      print('🌐 POST: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await logout(); // Cerrar sesión local también
        return true;
      }

      return false;
    } catch (e) {
      print('Error al cerrar todas las sesiones: $e');
      return false;
    }
  }

  // Validar formato de email institucional
  bool validarEmailInstitucional(String email) {
    return email.endsWith('@chetumal.tecnm.mx') || email.endsWith('@tecnm.mx');
  }

  // Obtener información del servidor de autenticación
  Future<Map<String, dynamic>?> obtenerInfoServidor() async {
    try {
      final url = '$baseUrl/api/Auth/server-info';
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      return null;
    } catch (e) {
      print('Error al obtener info del servidor: $e');
      return null;
    }
  }

  // Obtener estadísticas de sesión
  Map<String, dynamic> obtenerEstadisticasSesion() {
    return {
      'isAuthenticated': _isAuthenticated,
      'hasToken': _userToken != null,
      'userRole': _userRole,
      'userName': userName,
      'loginTime': _userInfo?['loginTime'],
      'lastActivity': DateTime.now().toIso8601String(),
    };
  }

  // Método para logging de eventos de autenticación
  void _logAuthEvent(String event, Map<String, dynamic>? data) {
    print('Auth Event: $event');
    if (data != null) {
      print('Data: ${json.encode(data)}');
    }
  }
}
