import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/asistencia_detalle.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'crear_asistencia_screen.dart';
import 'detalle_asistencia_screen.dart';
import 'editar_asistencia_screen.dart';
import 'configuracion_screen.dart';
import 'login_screen.dart';

class ListaAsistenciasScreen extends StatefulWidget {
  @override
  _ListaAsistenciasScreenState createState() => _ListaAsistenciasScreenState();
}

class _ListaAsistenciasScreenState extends State<ListaAsistenciasScreen> 
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<AsistenciaDetalle> _asistencias = [];
  List<AsistenciaDetalle> _asistenciasFiltradas = [];
  bool _isLoading = true;
  String _searchTerm = '';
  DateTime? _fechaFiltro;
  int? _mesFiltro;
  int? _anioFiltro;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut)
    );
    _obtenerRolUsuario();
    _cargarAsistencias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _obtenerRolUsuario() {
    final authService = context.read<AuthService>();
    setState(() {
      _userRole = authService.getCurrentUserRole() ?? '';
    });
  }

  Future<void> _cargarAsistencias() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    final asistencias = await apiService.getAsistencias();
    
    setState(() {
      _asistencias = asistencias;
      _asistenciasFiltradas = asistencias;
      _isLoading = false;
    });
    
    _fabAnimationController.forward();
  }

  void _buscar(String term) {
    setState(() {
      _searchTerm = term;
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    List<AsistenciaDetalle> resultado = List.from(_asistencias);
    
    // Filtro por búsqueda
    if (_searchTerm.isNotEmpty) {
      final apiService = context.read<ApiService>();
      resultado = apiService.filtrarAsistencias(resultado, _searchTerm);
    }
    
    // Filtro por fecha específica
    if (_fechaFiltro != null) {
      final apiService = context.read<ApiService>();
      resultado = apiService.filtrarPorFecha(resultado, _fechaFiltro);
    }
    
    // Filtro por mes y año
    if (_mesFiltro != null || _anioFiltro != null) {
      final apiService = context.read<ApiService>();
      resultado = apiService.filtrarPorMesAnio(resultado, _mesFiltro, _anioFiltro);
    }
    
    setState(() {
      _asistenciasFiltradas = resultado;
    });
  }

  void _mostrarFiltroFecha() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltroFecha(),
    );
  }

  void _mostrarSelectorMes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar mes'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Constants.meses.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(Constants.meses[index]),
              onTap: () {
                setState(() {
                  _mesFiltro = index + 1;
                  _fechaFiltro = null;
                });
                _aplicarFiltros();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarSelectorAnio() {
    final anioActual = DateTime.now().year;
    final anios = List.generate(anioActual - 2019, (index) => 2020 + index);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar año'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: anios.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(anios[index].toString()),
              onTap: () {
                setState(() {
                  _anioFiltro = anios[index];
                  _fechaFiltro = null;
                });
                _aplicarFiltros();
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cerrar sesión'),
        content: Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authService = context.read<AuthService>();
              await authService.logout();
              
              // Navegar al login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.dangerColor),
            ),
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _navegarACrearAsistencia() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearAsistenciaScreen()),
    );
    if (result == true) {
      _cargarAsistencias();
    }
  }

  void _navegarADetalle(int asistenciaId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleAsistenciaScreen(asistenciaId: asistenciaId),
      ),
    );
  }

  void _navegarAEditar(int asistenciaId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarAsistenciaScreen(asistenciaId: asistenciaId),
      ),
    );
    if (result == true) {
      _cargarAsistencias();
    }
  }

  void _navegarAConfiguracion() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfiguracionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xfff0f2f5),
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildStatsSection(),
          _buildSearchSection(),
          SliverToBoxAdapter(child: _buildFiltrosActivos()),
          _buildAsistenciasList(),
        ],
      ),
      floatingActionButton: _userRole == 'Encargado' || _userRole == 'Administrador' 
        ? ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              onPressed: () => _navegarACrearAsistencia(),
              backgroundColor: Color(Constants.successColor),
              foregroundColor: Colors.white,
              elevation: 8,
              child: Icon(Icons.add, size: 20),
            ),
          )
        : null,
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
              Color(Constants.primaryColor),
              Color(Constants.primaryColor).withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        _userRole == 'Estudiante' 
                          ? 'assets/images/estudiante-avatar.png'
                          : _userRole == 'Encargado'
                            ? 'assets/images/encargado-avatar.png'
                            : 'assets/images/admin-avatar.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person, 
                            size: 35, 
                            color: Color(Constants.primaryColor)
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.userName ?? 'Usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authService.userRole ?? 'Usuario',
                              style: TextStyle(
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
            
            // Menú según el rol
            if (_userRole == 'Estudiante') ...[
              _buildDrawerItem(Icons.dashboard, 'Dashboard', false),
              _buildDrawerItem(Icons.school, 'Mis Actividades', false),
              _buildDrawerItem(Icons.assignment, 'Mi Historial', true),
            ] else if (_userRole == 'Encargado') ...[
              _buildDrawerItem(Icons.dashboard, 'Dashboard', false),
              _buildDrawerItem(Icons.assignment, 'Gestión de Asistencias', true),
              _buildDrawerItem(Icons.people, 'Gestión de Estudiantes', false),
              _buildDrawerItem(Icons.event, 'Gestión de Actividades', false),
              _buildDrawerItem(Icons.analytics, 'Reportes y Estadísticas', false),
            ] else if (_userRole == 'Administrador') ...[
              _buildDrawerItem(Icons.dashboard, 'Dashboard', false),
              _buildDrawerItem(Icons.assignment, 'Gestión de Asistencias', true),
              _buildDrawerItem(Icons.people, 'Gestión de Usuarios', false),
              _buildDrawerItem(Icons.event, 'Gestión de Actividades', false),
              _buildDrawerItem(Icons.analytics, 'Reportes y Estadísticas', false),
              _buildDrawerItem(Icons.admin_panel_settings, 'Administración del Sistema', false),
            ],
            
            Divider(color: Colors.white30, thickness: 1),
            _buildDrawerItem(Icons.settings, 'Configuración', false, onTap: () {
              Navigator.pop(context);
              _navegarAConfiguracion();
            }),
            _buildDrawerItem(Icons.help_outline, 'Ayuda', false),
            Spacer(),
            _buildDrawerItem(Icons.logout, 'Cerrar sesión', false, onTap: () {
              Navigator.pop(context);
              _mostrarDialogoCerrarSesion();
            }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool isSelected, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget _buildTituloResponsivo(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    
    return Expanded(
      child: isPortrait 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gestión de',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Asistencias',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        : Center(
            child: Text(
              'Gestión de Asistencias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Color(Constants.primaryColor),
      elevation: 4,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(Constants.primaryColor),
                Color(Constants.primaryColor).withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        child: IconButton(
                          icon: Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                      
                      _buildTituloResponsivo(context),
                      
                      Container(
                        width: 52,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo-tecnm.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.school,
                                color: Color(Constants.primaryColor),
                                size: 32,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  Center(
                    child: Material(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _mostrarFiltroFecha,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list, 
                                color: Colors.white, 
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Filtros',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', _asistencias.length.toString(), Icons.assignment, Color(Constants.primaryColor))),
                SizedBox(width: 8),
                Expanded(child: _buildStatCard('Asistieron', _asistencias.where((a) => a.estadoAsistencia == 'Asistio').length.toString(), Icons.check_circle, Color(Constants.successColor))),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Justificados', _asistencias.where((a) => a.estadoAsistencia == 'Justificado').length.toString(), Icons.info, Color(Constants.warningColor))),
                SizedBox(width: 8),
                Expanded(child: _buildStatCard('Faltas', _asistencias.where((a) => a.estadoAsistencia == 'No asistio').length.toString(), Icons.cancel, Color(Constants.dangerColor))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '¿Qué estudiante buscas?',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Color(Constants.primaryColor)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                    onPressed: () {
                      _searchController.clear();
                      _buscar('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: _buscar,
        ),
      ),
    );
  }

  Widget _buildFiltroFecha() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          Text(
            'Filtrar por fecha',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          
          // Filtro por día específico
          _buildFiltroTile(
            icon: Icons.calendar_today,
            titulo: 'Día específico',
            subtitulo: _fechaFiltro != null 
              ? DateFormat('dd/MM/yyyy').format(_fechaFiltro!)
              : 'Seleccionar fecha',
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaFiltro ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (fecha != null) {
                setState(() {
                  _fechaFiltro = fecha;
                  _mesFiltro = null;
                  _anioFiltro = null;
                });
                _aplicarFiltros();
                Navigator.pop(context);
              }
            },
          ),
          
          // Filtro por mes
          _buildFiltroTile(
            icon: Icons.date_range,
            titulo: 'Mes',
            subtitulo: _mesFiltro != null 
              ? Constants.meses[_mesFiltro! - 1]
              : 'Seleccionar mes',
            onTap: () => _mostrarSelectorMes(),
          ),
          
          // Filtro por año
          _buildFiltroTile(
            icon: Icons.date_range,
            titulo: 'Año',
            subtitulo: _anioFiltro != null 
              ? _anioFiltro.toString()
              : 'Seleccionar año',
            onTap: () => _mostrarSelectorAnio(),
          ),
          
          // Limpiar filtros
          _buildFiltroTile(
            icon: Icons.clear,
            titulo: 'Limpiar filtros',
            subtitulo: 'Remover todos los filtros',
            onTap: () {
              setState(() {
                _fechaFiltro = null;
                _mesFiltro = null;
                _anioFiltro = null;
              });
              _aplicarFiltros();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Filtros removidos'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFiltroTile({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(Constants.primaryColor).withOpacity(0.1),
          child: Icon(icon, color: Color(Constants.primaryColor)),
        ),
        title: Text(
          titulo,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitulo),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFiltrosActivos() {
    List<Widget> chips = [];
    
    if (_searchTerm.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Búsqueda: "$_searchTerm"'),
          deleteIcon: Icon(Icons.close, size: 18),
          onDeleted: () {
            _searchController.clear();
            _buscar('');
          },
        ),
      );
    }
    
    if (_fechaFiltro != null) {
      chips.add(
        Chip(
          label: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaFiltro!)}'),
          deleteIcon: Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() => _fechaFiltro = null);
            _aplicarFiltros();
          },
        ),
      );
    }
    
    if (_mesFiltro != null) {
      chips.add(
        Chip(
          label: Text('Mes: ${Constants.meses[_mesFiltro! - 1]}'),
          deleteIcon: Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() => _mesFiltro = null);
            _aplicarFiltros();
          },
        ),
      );
    }
    
    if (_anioFiltro != null) {
      chips.add(
        Chip(
          label: Text('Año: $_anioFiltro'),
          deleteIcon: Icon(Icons.close, size: 18),
          onDeleted: () {
            setState(() => _anioFiltro = null);
            _aplicarFiltros();
          },
        ),
      );
    }
    
    if (chips.isEmpty) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros activos:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildAsistenciasList() {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(Constants.primaryColor)),
              SizedBox(height: 16),
              Text('Cargando asistencias...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_asistenciasFiltradas.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No se encontraron registros',
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              if (_searchTerm.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'Intenta con otro término de búsqueda',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final asistencia = _asistenciasFiltradas[index];
          return _buildAsistenciaCard(asistencia);
        },
        childCount: _asistenciasFiltradas.length,
      ),
    );
  }

  Widget _buildAsistenciaCard(AsistenciaDetalle asistencia) {
    Color estadoColor = asistencia.estadoAsistencia == 'Asistio' 
        ? Color(Constants.successColor)
        : asistencia.estadoAsistencia == 'No asistio'
            ? Color(Constants.dangerColor)
            : Color(Constants.warningColor);

    IconData estadoIcon = asistencia.estadoAsistencia == 'Asistio' 
        ? Icons.check_circle
        : asistencia.estadoAsistencia == 'No asistio'
            ? Icons.cancel
            : Icons.info;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navegarADetalle(asistencia.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(Constants.primaryColor).withOpacity(0.1),
                    child: Text(
                      asistencia.numeroControl.substring(asistencia.numeroControl.length - 2),
                      style: TextStyle(
                        color: Color(Constants.primaryColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asistencia.nombreEstudiante,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${asistencia.numeroControl} • ${DateFormat('dd MMM, HH:mm').format(asistencia.fechaHora)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: estadoColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(estadoIcon, size: 14, color: estadoColor),
                        SizedBox(width: 4),
                        Text(
                          asistencia.estadoAsistencia,
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
              
              SizedBox(height: 12),
              
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.school, 'Carrera', asistencia.carreraEstudiante),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.event, 'Actividad', asistencia.nombreActividad),
                    SizedBox(height: 8),
                    _buildInfoRow(Icons.person, 'Encargado', asistencia.encargado),
                  ],
                ),
              ),
              
              if (_userRole == 'Encargado' || _userRole == 'Administrador') ...[
                SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.visibility,
                        label: 'Ver detalle',
                        color: Color(Constants.primaryColor),
                        onTap: () => _navegarADetalle(asistencia.id),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.edit,
                        label: 'Editar',
                        color: Color(Constants.accentColor),
                        onTap: () => _navegarAEditar(asistencia.id),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}