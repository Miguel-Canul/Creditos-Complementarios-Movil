import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/configuracion_service.dart';
import '../utils/constants.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  _ConfiguracionScreenState createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String userRole = '';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _obtenerRolUsuario();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _obtenerRolUsuario() {
    final authService = context.read<AuthService>();
    setState(() {
      userRole = authService.getCurrentUserRole() ?? '';
    });
    print('Rol del usuario en configuración: $userRole');
  }

  void _onConfiguracionChange() {
    setState(() {
      _hasChanges = true;
    });
  }

  void _aplicarCambios() async {
    final configService = context.read<ConfiguracionService>();
    final success = await configService.aplicarConfiguracion();

    if (success) {
      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración aplicada correctamente'),
          backgroundColor: Color(Constants.successColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al aplicar la configuración'),
          backgroundColor: Color(Constants.dangerColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetearConfiguracion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text(
            '¿Estás seguro de que deseas restablecer la configuración por defecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(Constants.dangerColor),
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final configService = context.read<ConfiguracionService>();
      await configService.resetearConfiguracion();

      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración restablecida por defecto'),
          backgroundColor: Color(Constants.successColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(Constants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header con información del usuario
            _buildUserHeader(),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Configuración por rol
                    if (userRole == 'Estudiante')
                      _buildConfiguracionEstudiante(),
                    if (userRole == 'Encargado') _buildConfiguracionEncargado(),
                    if (userRole == 'Administrador')
                      _buildConfiguracionAdministrador(),

                    const SizedBox(height: 24),

                    // Información adicional
                    _buildInformacionAdicional(),

                    const SizedBox(
                        height: 100), // Espacio para el botón flotante
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Botones de acción como FAB
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_hasChanges)
            FloatingActionButton.extended(
              onPressed: _aplicarCambios,
              backgroundColor: const Color(Constants.primaryColor),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.check),
              label: const Text('Aplicar cambios'),
              heroTag: "aplicar",
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _resetearConfiguracion,
            backgroundColor: const Color(Constants.dangerColor),
            foregroundColor: Colors.white,
            heroTag: "reset",
            child: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(Constants.primaryColor),
            const Color(Constants.primaryColor).withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Consumer<AuthService>(
          builder: (context, authService, child) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      userRole == 'Estudiante'
                          ? 'assets/images/estudiante-avatar.png'
                          : userRole == 'Encargado'
                              ? 'assets/images/encargado-avatar.png'
                              : 'assets/images/admin-avatar.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person,
                            size: 30, color: Color(Constants.primaryColor));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authService.userName ?? 'Usuario',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          authService.userRole ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfiguracionEstudiante() {
    return Consumer<ConfiguracionService>(
      builder: (context, configService, child) {
        return Column(
          children: [
            // Preferencias de Visualización
            _buildSeccionConfiguracion(
              titulo: 'Visualización',
              icono: Icons.visibility,
              children: [
                _buildToggleItem(
                  'Modo Oscuro',
                  'Cambia entre tema claro y oscuro',
                  configService.configuracionEstudiante.modoOscuro,
                  (value) {
                    configService.configuracionEstudiante.modoOscuro = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
                _buildToggleItem(
                  'Vista en Cuadrícula',
                  'Mostrar actividades en formato de cuadrícula',
                  configService.configuracionEstudiante.vistaCuadricula,
                  (value) {
                    configService.configuracionEstudiante.vistaCuadricula =
                        value;
                    _onConfiguracionChange();
                  },
                ),
                _buildToggleItem(
                  'Mostrar Completadas',
                  'Incluir actividades ya completadas',
                  configService.configuracionEstudiante.mostrarCompletadas,
                  (value) {
                    configService.configuracionEstudiante.mostrarCompletadas =
                        value;
                    _onConfiguracionChange();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Accesibilidad
            _buildSeccionConfiguracion(
              titulo: 'Accesibilidad',
              icono: Icons.accessibility,
              children: [
                _buildSelectItem(
                  'Tamaño del Texto',
                  'Ajusta el tamaño de letra en la aplicación',
                  configService.configuracionEstudiante.tamanoTexto,
                  ['pequeño', 'normal', 'grande', 'extra-grande'],
                  (value) {
                    configService.configuracionEstudiante.tamanoTexto = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Configuraciones de Lista
            _buildSeccionConfiguracion(
              titulo: 'Lista de Actividades',
              icono: Icons.list,
              children: [
                _buildSelectItem(
                  'Actividades por página',
                  'Cantidad de actividades mostradas por página',
                  configService.configuracionEstudiante.actividadesPorPagina
                      .toString(),
                  ['5', '10', '15', '20', '25'],
                  (value) {
                    configService.configuracionEstudiante.actividadesPorPagina =
                        int.parse(value);
                    _onConfiguracionChange();
                  },
                ),
                _buildSelectItem(
                  'Orden Predeterminado',
                  'Cómo se ordenan las actividades por defecto',
                  configService.configuracionEstudiante.ordenPredeterminado,
                  [
                    'fecha-desc',
                    'fecha-asc',
                    'nombre-asc',
                    'nombre-desc',
                    'tipo-asc',
                    'estado-asc',
                    'encargado-asc'
                  ],
                  (value) {
                    configService.configuracionEstudiante.ordenPredeterminado =
                        value;
                    _onConfiguracionChange();
                  },
                  displayNames: [
                    'Fecha (más reciente primero)',
                    'Fecha (más antigua primero)',
                    'Nombre (A-Z)',
                    'Nombre (Z-A)',
                    'Tipo de actividad (A-Z)',
                    'Estado',
                    'Encargado (A-Z)'
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfiguracionEncargado() {
    return Consumer<ConfiguracionService>(
      builder: (context, configService, child) {
        return Column(
          children: [
            // General
            _buildSeccionConfiguracion(
              titulo: 'General',
              icono: Icons.settings,
              children: [
                _buildToggleItem(
                  'Modo Oscuro',
                  'Cambia entre tema claro y oscuro',
                  configService.configuracionEncargado.modoOscuro,
                  (value) {
                    configService.configuracionEncargado.modoOscuro = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
                _buildSelectItem(
                  'Tamaño de Texto',
                  'Ajusta el tamaño de letra en la aplicación',
                  configService.configuracionEncargado.tamanoTexto,
                  ['pequeño', 'normal', 'grande', 'extra-grande'],
                  (value) {
                    configService.configuracionEncargado.tamanoTexto = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dashboard
            _buildSeccionConfiguracion(
              titulo: 'Dashboard',
              icono: Icons.dashboard,
              children: [
                _buildVistaSelector(
                  'Vista de Dashboard',
                  'Cómo se muestran los datos en el dashboard',
                  configService.configuracionEncargado.vistaDashboard,
                  (value) {
                    configService.configuracionEncargado.vistaDashboard = value;
                    _onConfiguracionChange();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Configuración de Tabla
            _buildSeccionConfiguracion(
              titulo: 'Lista de Asistencias',
              icono: Icons.table_chart,
              children: [
                _buildSelectItem(
                  'Registros por página',
                  'Cantidad de registros mostrados por página',
                  configService.configuracionEncargado.registrosPorPagina
                      .toString(),
                  ['10', '20', '50', '100'],
                  (value) {
                    configService.configuracionEncargado.registrosPorPagina =
                        int.parse(value);
                    _onConfiguracionChange();
                  },
                ),
                const SizedBox(height: 16),
                _buildColumnasVisibles(configService),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfiguracionAdministrador() {
    return Consumer<ConfiguracionService>(
      builder: (context, configService, child) {
        return Column(
          children: [
            // General
            _buildSeccionConfiguracion(
              titulo: 'General',
              icono: Icons.admin_panel_settings,
              children: [
                _buildToggleItem(
                  'Modo Oscuro',
                  'Cambia entre tema claro y oscuro',
                  configService.configuracionEncargado.modoOscuro,
                  (value) {
                    configService.configuracionEncargado.modoOscuro = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
                _buildSelectItem(
                  'Tamaño de Texto',
                  'Ajusta el tamaño de letra en la aplicación',
                  configService.configuracionEncargado.tamanoTexto,
                  ['pequeño', 'normal', 'grande', 'extra-grande'],
                  (value) {
                    configService.configuracionEncargado.tamanoTexto = value;
                    configService.aplicarConfiguracionVisual();
                    _onConfiguracionChange();
                  },
                  aplicaInmediato: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dashboard Administrativo
            _buildSeccionConfiguracion(
              titulo: 'Panel de Administración',
              icono: Icons.dashboard,
              children: [
                _buildVistaSelector(
                  'Vista de Dashboard',
                  'Cómo se muestran los datos en el panel administrativo',
                  configService.configuracionEncargado.vistaDashboard,
                  (value) {
                    configService.configuracionEncargado.vistaDashboard = value;
                    _onConfiguracionChange();
                  },
                ),
                _buildSelectItem(
                  'Registros por página',
                  'Cantidad de registros mostrados por página',
                  configService.configuracionEncargado.registrosPorPagina
                      .toString(),
                  ['10', '20', '50', '100'],
                  (value) {
                    configService.configuracionEncargado.registrosPorPagina =
                        int.parse(value);
                    _onConfiguracionChange();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Configuración Avanzada
            _buildSeccionConfiguracion(
              titulo: 'Configuración Avanzada',
              icono: Icons.settings_applications,
              children: [
                _buildColumnasVisibles(configService),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeccionConfiguracion({
    required String titulo,
    required IconData icono,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(Constants.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icono,
                    color: const Color(Constants.primaryColor),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
      String titulo, String descripcion, bool valor, Function(bool) onChanged,
      {bool aplicaInmediato = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (aplicaInmediato)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Se aplica inmediatamente',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(Constants.successColor),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(Constants.primaryColor),
            activeTrackColor:
                const Color(Constants.primaryColor).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectItem(
    String titulo,
    String descripcion,
    String valorActual,
    List<String> opciones,
    Function(String) onChanged, {
    List<String>? displayNames,
    bool aplicaInmediato = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (aplicaInmediato)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Se aplica inmediatamente',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(Constants.successColor),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButton<String>(
              value: valorActual,
              isExpanded: true,
              underline: const SizedBox(),
              items: opciones.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final displayName =
                    displayNames != null && index < displayNames.length
                        ? displayNames[index]
                        : value;

                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVistaSelector(String titulo, String descripcion,
      String valorActual, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVistaBoton(
                  icono: Icons.list,
                  titulo: 'Tabla',
                  valor: 'tabla',
                  valorActual: valorActual,
                  onTap: () => onChanged('tabla'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVistaBoton(
                  icono: Icons.grid_view,
                  titulo: 'Cuadrícula',
                  valor: 'cuadricula',
                  valorActual: valorActual,
                  onTap: () => onChanged('cuadricula'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVistaBoton({
    required IconData icono,
    required String titulo,
    required String valor,
    required String valorActual,
    required VoidCallback onTap,
  }) {
    final isSelected = valorActual == valor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(Constants.primaryColor) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(Constants.primaryColor)
                : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(Constants.primaryColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnasVisibles(ConfiguracionService configService) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Columnas visibles en tabla',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona qué columnas mostrar en la tabla de asistencias',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Se guarda automáticamente',
            style: TextStyle(
              fontSize: 12,
              color: Color(Constants.successColor),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: configService.columnasDisponibles.map((columna) {
                final isEsencial = columna['esencial'] as bool;
                final key = columna['key'] as String;
                final label = columna['label'] as String;
                final isVisible = configService
                        .configuracionEncargado.columnasVisibles[key] ??
                    true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isVisible,
                        onChanged: isEsencial
                            ? null
                            : (value) {
                                configService.configuracionEncargado
                                    .columnasVisibles[key] = value ?? false;
                                configService.guardarConfiguracion();
                              },
                        activeColor: const Color(Constants.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isEsencial
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                            if (isEsencial)
                              Text(
                                'Columna esencial - siempre visible',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionAdicional() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[700]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Información',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userRole == 'Estudiante') ...[
                _buildInfoItem(
                    'Los cambios visuales se aplican inmediatamente'),
                _buildInfoItem(
                    'Las preferencias se guardan automáticamente en tu dispositivo'),
              ],
              if (userRole == 'Encargado' || userRole == 'Administrador') ...[
                _buildInfoItem(
                    'Los cambios visuales se aplican inmediatamente'),
                _buildInfoItem(
                    'Los cambios en columnas de tabla se guardan automáticamente'),
                _buildInfoItem(
                    'Otras configuraciones requieren "Aplicar cambios"'),
              ],
              _buildInfoItem(
                  'Puedes restablecer la configuración por defecto en cualquier momento'),
              _buildInfoItem(
                  'Tu configuración es personal y no afecta a otros usuarios'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
