import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mobile/models/estudiante.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initCognito();
  }

  // Configuración de Cognito
  late CognitoUserPool _userPool;
  late CognitoUser _cognitoUser;

  // Estado de autenticación
  bool _isAuthenticated = false;
  String? _userToken;
  Map<String, dynamic>? _userInfo;
  String? _userRole;

  // URL para registro en DynamoDB
  static const String _apiGatewayUrl =
      'https://9o73ac05jk.execute-api.us-west-1.amazonaws.com/alumnoregistro';

  /// Getters actualizados
  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get userRole => _userRole;
  String? get userName =>
      _userInfo?['name'] ?? _userInfo?['email']?.split('@')[0];
  String? get userEmail => _userInfo?['email'];

  // NUEVOS GETTERS PARA LOS DATOS DE COGNITO
  String? get userSub =>
      _userInfo?['sub']; // ID único (290939ce-2031-7051-846b-9bd220fa68af)
  String? get userGivenName => _userInfo?['given_name']; // Marco Antonio
  String? get userFamilyName => _userInfo?['family_name']; // González Arias
  String? get userNombreCompleto =>
      '${_userInfo?['given_name'] ?? ''} ${_userInfo?['family_name'] ?? ''}'
          .trim();
  String? get userNumeroControl =>
      _userInfo?['email']?.split('@').first; // l21390301

  // En tu AuthService - agrega este método
  Estudiante? get currentEstudiante {
    if (!_isAuthenticated || _userInfo == null) return null;

    return Estudiante.fromAuthService(this);
  }

  void _initCognito() {
    _userPool = CognitoUserPool(
      'us-west-1_I12eAnPIf',
      '5c05blpm81g74abo84g5kso0c5', // Reemplaza con tu Client ID real
    );
  }

  // Inicializar servicio al arrancar la app
  Future<void> initialize() async {
    await _verificarSesionExistente();
  }

  // Verificar si hay una sesión guardada
  Future<void> _verificarSesionExistente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');

      if (email != null) {
        _cognitoUser = CognitoUser(email, _userPool);

        final session = await _cognitoUser.getSession();
        if (session != null && session.isValid()) {
          _userToken = session.accessToken.jwtToken;
          await _obtenerInformacionUsuario();

          _isAuthenticated = true;
          notifyListeners();
          print('Sesión Cognito existente encontrada para: $email');
        }
      }
    } catch (e) {
      print('Error al verificar sesión existente: $e');
      await logout();
    }
  }

  // En tu AuthService - actualiza el método login
  Future<Map<String, dynamic>> login(
      String email, String password, bool rememberMe) async {
    try {
      print('Intentando login con Cognito para: $email');

      _cognitoUser = CognitoUser(email, _userPool);

      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      final session = await _cognitoUser.authenticateUser(authDetails);

      if (session != null && session.isValid()) {
        _userToken = session.accessToken.jwtToken;
        await _obtenerInformacionUsuario();

        if (rememberMe) {
          await _guardarCredenciales(email, password);
        }

        await _guardarSesion();
        _isAuthenticated = true;
        notifyListeners();

        print('Login con Cognito exitoso para: $email');
        return {'success': true, 'requiresPasswordReset': false};
      }

      return {'success': false, 'requiresPasswordReset': false};
    } on CognitoClientException catch (e) {
      print('Error Cognito en login: ${e.message}');

      // Manejar caso específico de contraseña expirada
      if (e.message?.contains('Temporary password has expired') == true ||
          e.message?.contains('FORCE_CHANGE_PASSWORD') == true) {
        return {
          'success': false,
          'requiresPasswordReset': true,
          'message': 'La contraseña temporal ha expirado. Debes restablecerla.'
        };
      }

      return {
        'success': false,
        'requiresPasswordReset': false,
        'message': _getCognitoErrorMessage(e)
      };
    } catch (e) {
      print('Error inesperado en login: $e');
      return {
        'success': false,
        'requiresPasswordReset': false,
        'message': 'Error inesperado en login: $e'
      };
    }
  }

  // Obtener información del usuario desde Cognito
  Future<void> _obtenerInformacionUsuario() async {
    try {
      final attributes = await _cognitoUser.getUserAttributes();

      // Manejar si attributes viene null
      if (attributes == null || attributes.isEmpty) {
        _userInfo = {
          'email': _cognitoUser.username,
          'name': _cognitoUser.username?.split('@')[0] ?? 'Usuario',
          'email_verified': 'false',
          'custom:role': 'Estudiante',
          'sub': '', // ID único del usuario
          'given_name': '', // Nombre
          'family_name': '', // Apellido
        };
        _userRole = 'Alumno';
        return;
      }

      // Función auxiliar segura
      String? getAttr(String key) {
        final attr = attributes.firstWhere(
          (a) => a.name == key,
          orElse: () => CognitoUserAttribute(name: key, value: null),
        );
        return attr.value;
      }

      // OBTENER TODOS LOS ATRIBUTOS DE COGNITO
      _userInfo = {
        'email': _cognitoUser.username,
        'email_verified': getAttr('email_verified') ?? 'false',
        'name': getAttr('name') ?? '',
        'given_name': getAttr('given_name') ?? '', // Marco Antonio
        'family_name': getAttr('family_name') ?? '', // González Arias
        'sub': getAttr('sub') ?? '', // 290939ce-2031-7051-846b-9bd220fa68af
        'custom:role': getAttr('custom:role') ?? 'Alumno',
      };

      _userRole = _userInfo!['custom:role'] ?? 'Alumno';

      // Debug: ver todos los atributos obtenidos
      print('=== ATRIBUTOS OBTENIDOS DE COGNITO ===');
      print('Sub: ${_userInfo!['sub']}');
      print('Email: ${_userInfo!['email']}');
      print('Nombre completo: ${_userInfo!['name']}');
      print('Given Name: ${_userInfo!['given_name']}');
      print('Family Name: ${_userInfo!['family_name']}');
      print('Rol: $_userRole');
      print('=====================================');
    } catch (e) {
      print('Error al obtener información del usuario: $e');

      // Valores por defecto en caso de error
      _userInfo = {
        'email': _cognitoUser.username,
        'name': _cognitoUser.username?.split('@')[0] ?? 'Usuario',
        'email_verified': 'false',
        'custom:role': 'Estudiante',
        'sub': '',
        'given_name': '',
        'family_name': '',
      };

      _userRole = 'Alumno';
    }
  }

  // MÉTODO DE REGISTRO SIN CAMBIOS (NO envía carrera ni semestre a Cognito)
  Future<Map<String, dynamic>> registro(
      String nombreCompleto, String email, String password) async {
    try {
      print('=== INICIANDO REGISTRO DE ESTUDIANTE ===');

      // 1. Validar formato del email/número de control
      String emailCompleto = email.trim();

      // Si el usuario solo ingresó el número de control (ej: L21390301)
      if (!emailCompleto.contains('@')) {
        // Validar formato de número de control
        if (!RegExp(r'^[Ll]\d{8}$').hasMatch(emailCompleto)) {
          return {
            'success': false,
            'message':
                'Formato incorrecto. Debe ser: L + 8 dígitos (ej: L21390301)'
          };
        }
        // Convertir a mayúsculas y agregar dominio
        emailCompleto = '${emailCompleto.toUpperCase()}@chetumal.tecnm.mx';
      }

      // Si ya incluyó el dominio, validarlo
      else if (!emailCompleto.toLowerCase().endsWith('@chetumal.tecnm.mx')) {
        return {
          'success': false,
          'message':
              'Solo se permiten correos institucionales @chetumal.tecnm.mx'
        };
      }

      print('📧 Email para registro: $emailCompleto');
      print('👤 Nombre completo: $nombreCompleto');

      // 2. Separar nombre y apellido (como se muestra en AWS)
      final partes = nombreCompleto.trim().split(' ');
      String givenName = '';
      String familyName = '';

      if (partes.length >= 2) {
        // Tomar el primer elemento como given_name (nombre)
        givenName = partes.first;
        // El resto como family_name (apellidos)
        familyName = partes.sublist(1).join(' ');
      } else {
        // Si solo ingresó un nombre, ponerlo en given_name
        givenName = nombreCompleto;
        familyName = ''; // Dejar vacío como en tu ejemplo
      }

      // 3. CREAR ATRIBUTOS EXACTAMENTE COMO EN TU AWS CONSOLE
      final attributeList = [
        // Atributos OBLIGATORIOS (como en tu imagen):
        AttributeArg(name: 'email', value: emailCompleto),

        // Atributos OPCIONALES pero importantes:
        AttributeArg(name: 'given_name', value: givenName), // "Marco Antonio"
        AttributeArg(
            name: 'family_name', value: familyName), // "González Arias"
      ];

      print('📋 Atributos a enviar a Cognito:');
      for (var attr in attributeList) {
        print('   • ${attr.name}: ${attr.value}');
      }

      // 4. REGISTRAR EN COGNITO
      print('🔄 Registrando usuario en Cognito...');
      final result = await _userPool.signUp(
        emailCompleto, // username (debe ser el email)
        password, // password
        userAttributes: attributeList,
      );

      print('✅ Resultado del registro:');
      print('   - User Sub: ${result.userSub}'); // Este es el ID único
      print('   - User Confirmed: ${result.userConfirmed}');

      // Verificar si se requiere confirmación
      final requiereConfirmacion = !result.userConfirmed!;

      if (requiereConfirmacion) {
        print('   - Se requiere confirmación por email');
      } else {
        print('   - Usuario confirmado automáticamente');
      }

      // 5. Retornar resultado
      return {
        'success': true,
        'requiresConfirmation': requiereConfirmacion,
        'userSub': result.userSub,
        'email': emailCompleto,
        'message': requiereConfirmacion
            ? 'Registro exitoso. Se ha enviado un código de verificación a tu correo.'
            : '¡Registro exitoso! Tu cuenta ha sido creada.',
      };
    } on CognitoClientException catch (e) {
      print('❌ ERROR Cognito en registro: ${e.code} - ${e.message}');

      String mensajeError;
      switch (e.code) {
        case 'InvalidParameterException':
          mensajeError = _analizarErrorParametrosInvalidos(e.message);
          break;
        case 'UsernameExistsException':
          mensajeError = 'Este correo ya está registrado en el sistema.';
          break;
        case 'InvalidPasswordException':
          mensajeError = '''
La contraseña no cumple los requisitos:
• Mínimo 8 caracteres
• Al menos una letra mayúscula
• Al menos un número
• Al menos un carácter especial''';
          break;
        case 'InvalidEmailAddressException':
          mensajeError = 'El formato del email no es válido.';
          break;
        default:
          mensajeError =
              e.message ?? 'Error en el registro. Intenta nuevamente.';
      }

      return {'success': false, 'message': mensajeError};
    } catch (e) {
      print('❌ ERROR inesperado en registro: $e');
      return {
        'success': false,
        'message':
            'Error inesperado. Verifica tu conexión e intenta nuevamente.'
      };
    }
  }

  // NUEVO MÉTODO: Registrar en DynamoDB a través de API Gateway
  Future<Map<String, dynamic>> registrarEnDynamoDB({
    required String email,
    required String nombre,
    required String apellidos,
    required String carrera,
    required String semestre,
  }) async {
    try {
      print('=== REGISTRANDO EN DYNAMODB A TRAVÉS DE API GATEWAY ===');
      print('📧 Email: $email');
      print('👤 Nombres: $nombre');
      print('👤 Apellidos: $apellidos');
      print('🎓 Carrera: $carrera');
      print('📚 Semestre: $semestre');

      // Extraer número de control del email
      String numeroControl = email.split('@').first.toUpperCase();

      // Convertir semestre a entero
      int semestreInt;
      try {
        semestreInt = int.parse(semestre);
        if (semestreInt < 1) semestreInt = 1;
        if (semestreInt > 12) semestreInt = 12;
      } catch (e) {
        print('⚠️ Error al parsear semestre: $e, usando 1 por defecto');
        semestreInt = 1;
      }

      // Preparar datos para la API
      final Map<String, dynamic> requestData = {
        'email': email,
        'nombre': nombre,
        'apellidos': apellidos,
        'numeroControl': numeroControl,
        'carrera': carrera,
        'semestre': semestreInt,
      };

      print('📤 Enviando datos a API Gateway:');
      print(json.encode(requestData));

      // Llamar a la API Gateway
      final response = await http.post(
        Uri.parse(_apiGatewayUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('📥 Respuesta de API Gateway:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Registro en base de datos completado exitosamente',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message':
              'Error al registrar en base de datos: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ ERROR al registrar en DynamoDB: $e');
      return {
        'success': false,
        'message': 'Error de conexión al registrar en base de datos: $e',
      };
    }
  }

  // Método auxiliar para analizar errores de parámetros inválidos
  String _analizarErrorParametrosInvalidos(String? mensajeError) {
    if (mensajeError == null) {
      return 'Parámetros inválidos. Verifica los datos ingresados.';
    }

    if (mensajeError.contains('email')) {
      return 'El formato del correo electrónico no es válido.';
    }

    if (mensajeError.contains('attribute')) {
      return 'Error en los datos personales. Verifica nombre y apellido.';
    }

    return 'Datos incorrectos. Verifica toda la información ingresada.';
  }

  // Método para confirmar registro
  Future<bool> confirmarRegistro(
      String email, String codigoConfirmacion) async {
    try {
      print('🔐 Confirmando registro para: $email');
      print('🔢 Código: $codigoConfirmacion');

      final user = CognitoUser(email, _userPool);
      final confirmed = await user.confirmRegistration(codigoConfirmacion);

      if (confirmed) {
        print('✅ Confirmación exitosa');
        return true;
      } else {
        print('❌ Confirmación fallida');
        return false;
      }
    } on CognitoClientException catch (e) {
      print('❌ Error en confirmación: ${e.code} - ${e.message}');

      // Manejar errores específicos
      if (e.code == 'CodeMismatchException') {
        print('Código incorrecto');
      } else if (e.code == 'ExpiredCodeException') {
        print('Código expirado');
      } else if (e.code == 'UserNotFoundException') {
        print('Usuario no encontrado');
      }

      return false;
    } catch (e) {
      print('❌ Error inesperado en confirmación: $e');
      return false;
    }
  }

  // Método para reenviar código
  Future<bool> reenviarCodigoConfirmacion(String email) async {
    try {
      print('🔄 Reenviando código de confirmación para: $email');

      final user = CognitoUser(email, _userPool);
      final result = await user.resendConfirmationCode();

      print('✅ Código reenviado exitosamente');
      return true;
    } on CognitoClientException catch (e) {
      print('❌ Error al reenviar código: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error inesperado al reenviar: $e');
      return false;
    }
  }

  // RECUPERAR CONTRASEÑA
  Future<Map<String, dynamic>> solicitarRecuperacionPassword(
      String email) async {
    try {
      final user = CognitoUser(email, _userPool);
      await user.forgotPassword();

      return {
        'success': true,
        'message': 'Código de verificación enviado',
      };
    } on CognitoClientException catch (e) {
      return {'success': false, 'message': _getCognitoErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // CONFIRMAR NUEVA CONTRASEÑA
  Future<bool> confirmarRecuperacionPassword(
      String email, String codigo, String nuevaPassword) async {
    try {
      final user = CognitoUser(email, _userPool);
      await user.confirmPassword(codigo, nuevaPassword);
      return true;
    } catch (e) {
      print('Error al confirmar recuperación: $e');
      return false;
    }
  }

  // CAMBIAR CONTRASEÑA (cuando ya está logueado)
  Future<bool> cambiarPassword(
      String passwordActual, String nuevaPassword) async {
    try {
      await _cognitoUser.changePassword(passwordActual, nuevaPassword);
      return true;
    } catch (e) {
      print('Error al cambiar password: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_isAuthenticated) {
        _cognitoUser.signOut();
      }

      final prefs = await SharedPreferences.getInstance();

      // Limpiar datos de sesión
      await prefs.remove('userToken');
      await prefs.remove('userInfo');
      await prefs.remove('userRole');
      await prefs.remove('userEmail');

      // Reset estado
      _isAuthenticated = false;
      _userToken = null;
      _userInfo = null;
      _userRole = null;

      notifyListeners();

      print('Logout de Cognito exitoso');
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
        await prefs.setString('userEmail', _cognitoUser.username!);

        print('Sesión Cognito guardada exitosamente');
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
        return {'email': email, 'password': password};
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

  // Obtener rol del usuario actual
  String? getCurrentUserRole() {
    return _userRole;
  }

  // Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return _userRole == role;
  }

  // Obtener información actualizada del usuario
  Future<void> refrescarUsuario() async {
    if (!_isAuthenticated) return;

    try {
      await _obtenerInformacionUsuario();
      await _guardarSesion();
      notifyListeners();
    } catch (e) {
      print('Error al refrescar usuario: $e');
    }
  }

  // Validar formato de email institucional
  bool validarEmailInstitucional(String email) {
    return email.endsWith('@chetumal.tecnm.mx') || email.endsWith('@tecnm.mx');
  }

  // Método auxiliar para traducir errores de Cognito
  String _getCognitoErrorMessage(CognitoClientException e) {
    switch (e.code) {
      case 'UsernameExistsException':
        return 'El usuario ya existe';
      case 'UserNotFoundException':
        return 'Usuario no encontrado';
      case 'NotAuthorizedException':
        return 'Credenciales incorrectas';
      case 'InvalidParameterException':
        return 'Parámetros inválidos';
      case 'CodeMismatchException':
        return 'Código de verificación incorrecto';
      case 'ExpiredCodeException':
        return 'Código expirado';
      case 'LimitExceededException':
        return 'Límite de intentos excedido';
      default:
        return e.message ?? 'Error desconocido';
    }
  }

  // Obtener estadísticas de sesión
  Map<String, dynamic> obtenerEstadisticasSesion() {
    return {
      'isAuthenticated': _isAuthenticated,
      'hasToken': _userToken != null,
      'userRole': _userRole,
      'userName': userName,
      'userEmail': userEmail,
      'lastActivity': DateTime.now().toIso8601String(),
    };
  }
}
