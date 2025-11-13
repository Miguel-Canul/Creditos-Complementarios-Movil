import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/asistencia_detalle.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import 'editar_asistencia_screen.dart';

class DetalleAsistenciaScreen extends StatefulWidget {
  final int asistenciaId;

  const DetalleAsistenciaScreen({Key? key, required this.asistenciaId}) : super(key: key);

  @override
  _DetalleAsistenciaScreenState createState() => _DetalleAsistenciaScreenState();
}

class _DetalleAsistenciaScreenState extends State<DetalleAsistenciaScreen> {
  AsistenciaDetalle? _asistencia;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarAsistencia();
  }

  Future<void> _cargarAsistencia() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    final asistencia = await apiService.getAsistencia(widget.asistenciaId);
    
    if (asistencia != null) {
      setState(() {
        _asistencia = asistencia;
        _isLoading = false;
      });
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cargar la asistencia'),
          backgroundColor: Color(Constants.dangerColor),
        ),
      );
    }
  }

  Color _getEstadoColor() {
    if (_asistencia == null) return Colors.grey;
    
    switch (_asistencia!.estadoAsistencia) {
      case Constants.estadoAsistio:
        return Color(Constants.successColor);
      case Constants.estadoNoAsistio:
        return Color(Constants.dangerColor);
      case Constants.estadoJustificado:
        return Color(Constants.warningColor);
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon() {
    if (_asistencia == null) return Icons.help;
    
    switch (_asistencia!.estadoAsistencia) {
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

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Asistencia'),
        content: Text('¿Estás seguro de eliminar esta asistencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.dangerColor),
            ),
            child: Text('SÍ'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final apiService = context.read<ApiService>();
      final success = await apiService.eliminarAsistencia(widget.asistenciaId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asistencia eliminada correctamente'),
            backgroundColor: Color(Constants.successColor),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar la asistencia'),
            backgroundColor: Color(Constants.dangerColor),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Asistencia'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _isLoading ? null : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditarAsistenciaScreen(
                    asistenciaId: widget.asistenciaId,
                  ),
                ),
              );
              if (result == true) {
                _cargarAsistencia();
              }
            },
            tooltip: 'Editar asistencia',
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _isLoading ? null : _confirmarEliminar,
            tooltip: 'Eliminar asistencia',
          ),
        ],
      ),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando información...'),
              ],
            ),
          )
        : _asistencia == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se pudo cargar la información',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarAsistencia,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  // Estado de asistencia destacado
                  Card(
                    color: _getEstadoColor().withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getEstadoColor().withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getEstadoIcon(),
                              size: 48,
                              color: _getEstadoColor(),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            _asistencia!.estadoAsistencia,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getEstadoColor(),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Estado de asistencia',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Información del estudiante
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Color(Constants.primaryColor)),
                              SizedBox(width: 8),
                              Text(
                                'Estudiante',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(Constants.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildDetailRow(Icons.badge, 'N° de control', _asistencia!.numeroControl),
                          _buildDetailRow(Icons.person_outline, 'Nombre', _asistencia!.nombreEstudiante),
                          _buildDetailRow(Icons.school, 'Carrera', _asistencia!.carreraEstudiante),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Información de la actividad
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event, color: Color(Constants.primaryColor)),
                              SizedBox(width: 8),
                              Text(
                                'Actividad',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Color(Constants.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildDetailRow(Icons.event_note, 'Actividad', _asistencia!.nombreActividad),
                          _buildDetailRow(Icons.category, 'Extraescolar/Taller', _asistencia!.extraescolarCalculado),
                          _buildDetailRow(Icons.person_pin, 'Encargado', _asistencia!.encargado),
                          _buildDetailRow(
                            Icons.access_time, 
                            'Fecha y hora', 
                            DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(_asistencia!.fechaHora),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarAsistenciaScreen(
                                  asistenciaId: widget.asistenciaId,
                                ),
                              ),
                            );
                            if (result == true) {
                              _cargarAsistencia();
                            }
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(Constants.accentColor),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _confirmarEliminar,
                          icon: Icon(Icons.delete),
                          label: Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(Constants.dangerColor),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}