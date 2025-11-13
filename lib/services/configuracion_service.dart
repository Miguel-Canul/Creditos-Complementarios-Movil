import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

// Clases de configuración
class ConfiguracionEstudiante {
  bool modoOscuro;
  bool vistaCuadricula;
  bool mostrarCompletadas;
  int actividadesPorPagina;
  String tamanoTexto;
  String ordenPredeterminado;

  ConfiguracionEstudiante({
    required this.modoOscuro,
    required this.vistaCuadricula,
    required this.mostrarCompletadas,
    required this.actividadesPorPagina,
    required this.tamanoTexto,
    required this.ordenPredeterminado,
  });

  Map<String, dynamic> toJson() {
    return {
      'modoOscuro': modoOscuro,
      'vistaCuadricula': vistaCuadricula,
      'mostrarCompletadas': mostrarCompletadas,
      'actividadesPorPagina': actividadesPorPagina,
      'tamanoTexto': tamanoTexto,
      'ordenPredeterminado': ordenPredeterminado,
    };
  }

  factory ConfiguracionEstudiante.fromJson(Map<String, dynamic> json) {
    return ConfiguracionEstudiante(
      modoOscuro: json['modoOscuro'] ?? false,
      vistaCuadricula: json['vistaCuadricula'] ?? true,
      mostrarCompletadas: json['mostrarCompletadas'] ?? true,
      actividadesPorPagina: json['actividadesPorPagina'] ?? 10,
      tamanoTexto: json['tamanoTexto'] ?? 'normal',
      ordenPredeterminado: json['ordenPredeterminado'] ?? 'fecha-desc',
    );
  }
}

class ConfiguracionEncargado {
  bool modoOscuro;
  String tamanoTexto;
  String vistaDashboard;
  int registrosPorPagina;
  Map<String, bool> columnasVisibles;

  ConfiguracionEncargado({
    required this.modoOscuro,
    required this.tamanoTexto,
    required this.vistaDashboard,
    required this.registrosPorPagina,
    required this.columnasVisibles,
  });

  Map<String, dynamic> toJson() {
    return {
      'modoOscuro': modoOscuro,
      'tamanoTexto': tamanoTexto,
      'vistaDashboard': vistaDashboard,
      'registrosPorPagina': registrosPorPagina,
      'columnasVisibles': columnasVisibles,
    };
  }

  factory ConfiguracionEncargado.fromJson(Map<String, dynamic> json) {
    return ConfiguracionEncargado(
      modoOscuro: json['modoOscuro'] ?? false,
      tamanoTexto: json['tamanoTexto'] ?? 'normal',
      vistaDashboard: json['vistaDashboard'] ?? 'tabla',
      registrosPorPagina: json['registrosPorPagina'] ?? 20,
      columnasVisibles: Map<String, bool>.from(json['columnasVisibles'] ?? {
        'numeroControl': true,
        'nombreEstudiante': true,
        'carreraEstudiante': true,
        'extraescolarTaller': true,
        'encargado': true,
        'nombreActividad': true,
        'fechaHora': true,
        'estadoAsistencia': true,
        'acciones': true,
      }),
    );
  }
}

class ConfiguracionService extends ChangeNotifier {
  static final ConfiguracionService _instance = ConfiguracionService._internal();
  factory ConfiguracionService() => _instance;
  ConfiguracionService._internal();

  late AuthService _authService;
  String userRole = '';

  // Configuraciones por defecto
  final ConfiguracionEstudiante _configPorDefectoEstudiante = ConfiguracionEstudiante(
    modoOscuro: false,
    vistaCuadricula: true,
    mostrarCompletadas: true,
    actividadesPorPagina: 10,
    tamanoTexto: 'normal',
    ordenPredeterminado: 'fecha-desc',
  );

  final ConfiguracionEncargado _configPorDefectoEncargado = ConfiguracionEncargado(
    modoOscuro: false,
    tamanoTexto: 'normal',
    vistaDashboard: 'tabla',
    registrosPorPagina: 20,
    columnasVisibles: {
      'numeroControl': true,
      'nombreEstudiante': true,
      'carreraEstudiante': true,
      'extraescolarTaller': true,
      'encargado': true,
      'nombreActividad': true,
      'fechaHora': true,
      'estadoAsistencia': true,
      'acciones': true,
    },
  );

  // Configuraciones actuales
  late ConfiguracionEstudiante configuracionEstudiante;
  late ConfiguracionEncargado configuracionEncargado;

  // Columnas disponibles
  final List<Map<String, dynamic>> columnasDisponibles = [
    {'key': 'numeroControl', 'label': 'N° de control', 'esencial': true},
    {'key': 'nombreEstudiante', 'label': 'Nombre', 'esencial': true},
    {'key': 'carreraEstudiante', 'label': 'Carrera', 'esencial': false},
    {'key': 'extraescolarTaller', 'label': 'Extraescolar/Taller', 'esencial': false},
    {'key': 'encargado', 'label': 'Encargado', 'esencial': false},
    {'key': 'nombreActividad', 'label': 'Actividad', 'esencial': true},
    {'key': 'fechaHora', 'label': 'Día y hora', 'esencial': true},
    {'key': 'estadoAsistencia', 'label': 'Asistencia', 'esencial': true},
    {'key': 'acciones', 'label': 'Acciones', 'esencial': true},
  ];

  // Inicializar servicio
  Future<void> initialize(AuthService authService) async {
    _authService = authService;
    userRole = _authService.getCurrentUserRole() ?? '';
    
    await cargarConfiguracion();
    aplicarConfiguracionVisual();
  }

  // Cargar configuración desde SharedPreferences
  Future<void> cargarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configKey = 'config_${userRole.toLowerCase()}';
      final configString = prefs.getString(configKey);

      if (configString != null) {
        final configJson = json.decode(configString);
        
        if (userRole == 'Estudiante') {
          configuracionEstudiante = ConfiguracionEstudiante.fromJson(configJson);
        } else if (userRole == 'Encargado') {
          configuracionEncargado = ConfiguracionEncargado.fromJson(configJson);
        }
        
        print('Configuración cargada para $userRole');
      } else {
        _establecerConfiguracionPorDefecto();
      }
    } catch (e) {
      print('Error al cargar configuración: $e');
      _establecerConfiguracionPorDefecto();
    }
    
    notifyListeners();
  }

  // Establecer configuración por defecto
  void _establecerConfiguracionPorDefecto() {
    if (userRole == 'Estudiante') {
      configuracionEstudiante = ConfiguracionEstudiante.fromJson(_configPorDefectoEstudiante.toJson());
    } else if (userRole == 'Encargado') {
      configuracionEncargado = ConfiguracionEncargado.fromJson(_configPorDefectoEncargado.toJson());
    }
    print('Configuración por defecto establecida para $userRole');
  }

  // Guardar configuración (para columnas que se guardan automáticamente)
  Future<void> guardarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configKey = 'config_${userRole.toLowerCase()}';
      
      String configJson;
      if (userRole == 'Estudiante') {
        configJson = json.encode(configuracionEstudiante.toJson());
      } else if (userRole == 'Encargado') {
        configJson = json.encode(configuracionEncargado.toJson());
      } else {
        return;
      }
      
      await prefs.setString(configKey, configJson);
      print('Configuración guardada para $userRole');
      
      // Emitir evento para otros widgets que escuchen
      notifyListeners();
    } catch (e) {
      print('Error al guardar configuración: $e');
    }
  }

  // Aplicar cambios completos (botón "Aplicar cambios")
  Future<bool> aplicarConfiguracion() async {
    try {
      await guardarConfiguracion();
      aplicarConfiguracionVisual();
      
      print('Configuración aplicada exitosamente');
      return true;
    } catch (e) {
      print('Error al aplicar configuración: $e');
      return false;
    }
  }

  // Aplicar configuración visual inmediatamente
  void aplicarConfiguracionVisual() {
    bool modoOscuro = false;
    String tamanoTexto = 'normal';
    
    if (userRole == 'Estudiante') {
      modoOscuro = configuracionEstudiante.modoOscuro;
      tamanoTexto = configuracionEstudiante.tamanoTexto;
    } else if (userRole == 'Encargado') {
      modoOscuro = configuracionEncargado.modoOscuro;
      tamanoTexto = configuracionEncargado.tamanoTexto;
    }
    
    print('Aplicando configuración visual: modoOscuro=$modoOscuro, tamanoTexto=$tamanoTexto');
    
    notifyListeners();
  }

  // Resetear configuración por defecto
  Future<void> resetearConfiguracion() async {
    try {
      _establecerConfiguracionPorDefecto();
      await aplicarConfiguracion();
      
      print('Configuración restablecida por defecto');
    } catch (e) {
      print('Error al resetear configuración: $e');
    }
  }

  // MÉTODOS ESTÁTICOS PARA ACCESO GLOBAL 
  
  static Future<Map<String, dynamic>?> obtenerConfiguracion(String rol) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configKey = 'config_${rol.toLowerCase()}';
      final configString = prefs.getString(configKey);
      
      if (configString != null) {
        return json.decode(configString);
      }
      return null;
    } catch (e) {
      print('Error al obtener configuración estática: $e');
      return null;
    }
  }

  static Future<List<String>> obtenerColumnasVisibles() async {
    final config = await obtenerConfiguracion('Encargado');
    if (config != null && config['columnasVisibles'] != null) {
      final columnasVisibles = Map<String, bool>.from(config['columnasVisibles']);
      return columnasVisibles.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    }
    
    // Valores por defecto
    return [
      'numeroControl',
      'nombreEstudiante',
      'carreraEstudiante',
      'extraescolarTaller',
      'encargado',
      'nombreActividad',
      'fechaHora',
      'estadoAsistencia',
      'acciones'
    ];
  }

  static Future<int> obtenerRegistrosPorPagina() async {
    final config = await obtenerConfiguracion('Encargado');
    return config?['registrosPorPagina'] ?? 20;
  }

  static Future<int> obtenerActividadesPorPagina() async {
    final config = await obtenerConfiguracion('Estudiante');
    return config?['actividadesPorPagina'] ?? 10;
  }

  static Future<String> obtenerOrdenPredeterminado() async {
    final config = await obtenerConfiguracion('Estudiante');
    return config?['ordenPredeterminado'] ?? 'fecha-desc';
  }

  static Future<bool> obtenerModoOscuro(String rol) async {
    final config = await obtenerConfiguracion(rol);
    return config?['modoOscuro'] ?? false;
  }

  static Future<String> obtenerTamanoTexto(String rol) async {
    final config = await obtenerConfiguracion(rol);
    return config?['tamanoTexto'] ?? 'normal';
  }

  static Future<bool> obtenerVistaCuadricula() async {
    final config = await obtenerConfiguracion('Estudiante');
    return config?['vistaCuadricula'] ?? true;
  }

  static Future<String> obtenerVistaDashboard() async {
    final config = await obtenerConfiguracion('Encargado');
    return config?['vistaDashboard'] ?? 'tabla';
  }

  static Future<bool> obtenerMostrarCompletadas() async {
    final config = await obtenerConfiguracion('Estudiante');
    return config?['mostrarCompletadas'] ?? true;
  }

  // Getters para acceso fácil
  bool get modoOscuroActivo {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.modoOscuro;
    } else if (userRole == 'Encargado') {
      return configuracionEncargado.modoOscuro;
    }
    return false;
  }

  String get tamanoTextoActivo {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.tamanoTexto;
    } else if (userRole == 'Encargado') {
      return configuracionEncargado.tamanoTexto;
    }
    return 'normal';
  }

  int get registrosPorPaginaActivo {
    if (userRole == 'Encargado') {
      return configuracionEncargado.registrosPorPagina;
    }
    return 20;
  }

  int get actividadesPorPaginaActivo {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.actividadesPorPagina;
    }
    return 10;
  }

  String get ordenPredeterminadoActivo {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.ordenPredeterminado;
    }
    return 'fecha-desc';
  }

  bool get vistaCuadriculaActiva {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.vistaCuadricula;
    }
    return true;
  }

  String get vistaDashboardActiva {
    if (userRole == 'Encargado') {
      return configuracionEncargado.vistaDashboard;
    }
    return 'tabla';
  }

  bool get mostrarCompletadasActivo {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.mostrarCompletadas;
    }
    return true;
  }

  List<String> get columnasVisiblesActivas {
    if (userRole == 'Encargado') {
      return configuracionEncargado.columnasVisibles.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    }
    return [];
  }

  // Métodos para actualizar configuraciones específicas
  void setModoOscuro(bool value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.modoOscuro = value;
    } else if (userRole == 'Encargado') {
      configuracionEncargado.modoOscuro = value;
    }
    aplicarConfiguracionVisual();
  }

  void setTamanoTexto(String value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.tamanoTexto = value;
    } else if (userRole == 'Encargado') {
      configuracionEncargado.tamanoTexto = value;
    }
    aplicarConfiguracionVisual();
  }

  void setVistaCuadricula(bool value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.vistaCuadricula = value;
      notifyListeners();
    }
  }

  void setMostrarCompletadas(bool value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.mostrarCompletadas = value;
      notifyListeners();
    }
  }

  void setActividadesPorPagina(int value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.actividadesPorPagina = value;
      notifyListeners();
    }
  }

  void setOrdenPredeterminado(String value) {
    if (userRole == 'Estudiante') {
      configuracionEstudiante.ordenPredeterminado = value;
      notifyListeners();
    }
  }

  void setVistaDashboard(String value) {
    if (userRole == 'Encargado') {
      configuracionEncargado.vistaDashboard = value;
      notifyListeners();
    }
  }

  void setRegistrosPorPagina(int value) {
    if (userRole == 'Encargado') {
      configuracionEncargado.registrosPorPagina = value;
      notifyListeners();
    }
  }

  void setColumnaVisible(String columna, bool visible) {
    if (userRole == 'Encargado') {
      configuracionEncargado.columnasVisibles[columna] = visible;
      guardarConfiguracion(); // Auto-guardar para columnas
    }
  }

  // Método para verificar si una columna debe mostrarse
  bool mostrarColumna(String columna) {
    if (userRole == 'Encargado') {
      return configuracionEncargado.columnasVisibles[columna] ?? true;
    }
    return true;
  }

  // Método para verificar si hay cambios sin guardar
  bool tienecambiosPendientes() {
    return false;
  }

  // Método para exportar configuración (futuro)
  Map<String, dynamic> exportarConfiguracion() {
    if (userRole == 'Estudiante') {
      return configuracionEstudiante.toJson();
    } else if (userRole == 'Encargado') {
      return configuracionEncargado.toJson();
    }
    return {};
  }

  // Método para importar configuración (futuro)
  Future<bool> importarConfiguracion(Map<String, dynamic> config) async {
    try {
      if (userRole == 'Estudiante') {
        configuracionEstudiante = ConfiguracionEstudiante.fromJson(config);
      } else if (userRole == 'Encargado') {
        configuracionEncargado = ConfiguracionEncargado.fromJson(config);
      }
      
      await aplicarConfiguracion();
      return true;
    } catch (e) {
      print('Error al importar configuración: $e');
      return false;
    }
  }
}