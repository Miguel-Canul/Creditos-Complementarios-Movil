import 'package:flutter/material.dart';
import 'package:mobile/screens/historial_actividades_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'configuracion_screen.dart';
import 'login_screen.dart';

class EstudianteDashboardScreen extends StatefulWidget {
  const EstudianteDashboardScreen({super.key});

  @override
  _EstudianteDashboardScreenState createState() =>
      _EstudianteDashboardScreenState();
}

class _EstudianteDashboardScreenState extends State<EstudianteDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista temporal para actividades - reemplaza con tu modelo real
  List<Map<String, dynamic>> _misActividades = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _obtenerNumeroControl();
    _cargarMisActividades();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _obtenerNumeroControl() {
    context.read<AuthService>();
    setState(() {});
  }

  Future<void> _cargarMisActividades() async {
    setState(() => _isLoading = true);

    // Simular carga de datos - reemplaza con tu lógica real
    await Future.delayed(const Duration(seconds: 1));

    // Datos de ejemplo - reemplaza con tu data real
    final actividadesEjemplo = [
      {
        'id': '1',
        'nombre': 'Clase de Matemáticas',
        'encargado': 'Dr. García',
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'estado': Constants.estadoAsistio,
      },
      {
        'id': '2',
        'nombre': 'Laboratorio de Física',
        'encargado': 'Dra. Martínez',
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'estado': Constants.estadoNoAsistio,
      },
      {
        'id': '3',
        'nombre': 'Taller de Programación',
        'encargado': 'Ing. Rodríguez',
        'fecha': DateTime.now().subtract(const Duration(days: 3)),
        'estado': Constants.estadoJustificado,
      },
    ];

    setState(() {
      _misActividades = actividadesEjemplo;
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final authService = context.read<AuthService>();
              await authService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(Constants.dangerColor),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _navegarAConfiguracion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfiguracionScreen()),
    );
  }

  // Estadísticas de actividades
  Map<String, int> _calcularEstadisticas() {
    final total = _misActividades.length;
    final asistio = _misActividades
        .where((a) => a['estado'] == Constants.estadoAsistio)
        .length;
    final noAsistio = _misActividades
        .where((a) => a['estado'] == Constants.estadoNoAsistio)
        .length;
    final justificado = _misActividades
        .where((a) => a['estado'] == Constants.estadoJustificado)
        .length;

    return {
      'total': total,
      'asistio': asistio,
      'noAsistio': noAsistio,
      'justificado': justificado,
    };
  }

  // Actividades recientes (últimas 5)
  List<Map<String, dynamic>> _obtenerActividadesRecientes() {
    final actividades = List<Map<String, dynamic>>.from(_misActividades);
    actividades.sort(
        (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime));
    return actividades.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xfff0f2f5),
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildWelcomeSection(),
          _buildStatsSection(),
          _buildRecentActivitiesSection(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(Constants.primaryColor),
              const Color(Constants.primaryColor).withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/estudiante-avatar.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 35, color: Color(Constants.primaryColor));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.userName ?? 'Estudiante',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                              authService.userRole ?? 'Estudiante',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', true),
            _buildDrawerItem(Icons.school, 'Mis Actividades', false),
            _buildDrawerItem(Icons.assignment, 'Mi Historial', false,
                onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistorialActividadesScreen(),
                ),
              );
            }),
            const Divider(color: Colors.white30, thickness: 1),
            _buildDrawerItem(Icons.settings, 'Configuración', false, onTap: () {
              Navigator.pop(context);
              _navegarAConfiguracion();
            }),
            _buildDrawerItem(Icons.help_outline, 'Ayuda', false),
            const Spacer(),
            _buildDrawerItem(Icons.logout, 'Cerrar sesión', false, onTap: () {
              Navigator.pop(context);
              _mostrarDialogoCerrarSesion();
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap ?? () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(Constants.primaryColor),
      elevation: 4,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Mi Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_tecnm.jpeg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.school,
                          color: Color(Constants.primaryColor),
                          size: 32,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(Constants.successColor),
                const Color(Constants.successColor).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(Constants.successColor).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '¡Hola!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return Text(
                          authService.userName ?? 'Estudiante',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aquí puedes ver el resumen de tus actividades y asistencias.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Image.asset(
                  'assets/images/Estudiante.jpeg',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = _calcularEstadisticas();

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Resumen de Actividades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(Constants.primaryColor),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      stats['total'].toString(),
                      Icons.assignment,
                      const Color(Constants.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Asistí',
                      stats['asistio'].toString(),
                      Icons.check_circle,
                      const Color(Constants.successColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Justificado',
                      stats['justificado'].toString(),
                      Icons.info,
                      const Color(Constants.warningColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Faltas',
                      stats['noAsistio'].toString(),
                      Icons.cancel,
                      const Color(Constants.dangerColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    final actividadesRecientes = _obtenerActividadesRecientes();

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actividades Recientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(Constants.primaryColor),
                    ),
                  ),
                  if (actividadesRecientes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Navegar a historial completo
                      },
                      child: const Text(
                        'Ver todas',
                        style: TextStyle(
                          color: Color(Constants.accentColor),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: Color(Constants.primaryColor),
                    ),
                  ),
                )
              else if (actividadesRecientes.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: actividadesRecientes
                      .map((actividad) => _buildActivityCard(actividad))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/images/no-actividades.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.event_note,
                size: 80,
                color: Colors.grey[400],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes actividades registradas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando tengas actividades registradas, aparecerán aquí.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> actividad) {
    Color estadoColor = _getEstadoColor(actividad['estado']);
    IconData estadoIcon = _getEstadoIcon(actividad['estado']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono de la actividad
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(Constants.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.event,
                color: Color(Constants.primaryColor),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Información de la actividad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad['nombre'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    actividad['encargado'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(actividad['fecha']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Estado de asistencia
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: estadoColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(estadoIcon, size: 14, color: estadoColor),
                  const SizedBox(width: 4),
                  Text(
                    actividad['estado'],
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case Constants.estadoAsistio:
        return const Color(Constants.successColor);
      case Constants.estadoNoAsistio:
        return const Color(Constants.dangerColor);
      case Constants.estadoJustificado:
        return const Color(Constants.warningColor);
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case Constants.estadoAsistio:
        return Icons.check_circle;
      case Constants.estadoNoAsistio:
        return Icons.cancel;
      case Constants.estadoJustificado:
        return Icons.info;
      default:
        return Icons.help;
    }
  }
}
