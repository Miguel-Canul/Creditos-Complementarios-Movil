import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/estudiante.dart';
import '../models/actividad.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CrearAsistenciaScreen extends StatefulWidget {
  @override
  _CrearAsistenciaScreenState createState() => _CrearAsistenciaScreenState();
}

class _CrearAsistenciaScreenState extends State<CrearAsistenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  List<Estudiante> _estudiantes = [];
  List<Actividad> _actividades = [];
  
  String? _numeroControlSeleccionado;
  int? _actividadIdSeleccionada;
  Actividad? _actividadSeleccionada;
  String _estadoAsistencia = Constants.estadoAsistio;
  DateTime _fechaHora = DateTime.now();
  
  bool _isLoading = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    final apiService = context.read<ApiService>();
    
    final estudiantes = await apiService.getEstudiantes();
    final actividades = await apiService.getActividades();
    
    setState(() {
      _estudiantes = estudiantes;
      _actividades = actividades;
      _isLoading = false;
    });

    if (_estudiantes.isEmpty || _actividades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos. Verifica tu conexión.'),
          backgroundColor: Color(Constants.warningColor),
        ),
      );
    }
  }

  void _onActividadSeleccionada(int? actividadId) {
    setState(() {
      _actividadIdSeleccionada = actividadId;
      if (actividadId != null) {
        _actividadSeleccionada = _actividades
            .firstWhere((actividad) => actividad.id == actividadId);
      } else {
        _actividadSeleccionada = null;
      }
    });
  }

  Future<void> _seleccionarFechaHora() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaHora),
      );
      
      if (hora != null) {
        setState(() {
          _fechaHora = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  Future<void> _guardarAsistencia() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _guardando = true);
    
    final asistenciaData = {
      'numeroControl': _numeroControlSeleccionado,
      'actividadId': _actividadIdSeleccionada,
      'fechaHora': _fechaHora.toIso8601String(),
      'estadoAsistencia': _estadoAsistencia,
    };
    
    final apiService = context.read<ApiService>();
    final success = await apiService.crearAsistencia(asistenciaData);
    
    setState(() => _guardando = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Asistencia registrada correctamente'),
          backgroundColor: Color(Constants.successColor),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar la asistencia'),
          backgroundColor: Color(Constants.dangerColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Nueva Asistencia'),
        backgroundColor: Color(Constants.successColor),
      ),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando datos...'),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Información del Estudiante
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
                              'Información del Estudiante',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'N° de control *',
                            prefixIcon: Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _numeroControlSeleccionado,
                          items: _estudiantes.map((estudiante) {
                            return DropdownMenuItem<String>(
                              value: estudiante.numeroControl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    estudiante.numeroControl,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    estudiante.nombre,
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _numeroControlSeleccionado = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione un estudiante';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Información de la Actividad
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
                              'Información de la Actividad',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Actividad *',
                            prefixIcon: Icon(Icons.event_note),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          value: _actividadIdSeleccionada,
                          items: _actividades.map((actividad) {
                            return DropdownMenuItem<int>(
                              value: actividad.id,
                              child: Text(
                                actividad.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _onActividadSeleccionada,
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione una actividad';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                        
                        // Información adicional de la actividad seleccionada
                        if (_actividadSeleccionada != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(Constants.primaryColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(Constants.primaryColor).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow('Extraescolar/Taller:', _actividadSeleccionada!.tipo),
                                SizedBox(height: 8),
                                _buildInfoRow('Encargado:', _actividadSeleccionada!.encargado),
                                SizedBox(height: 8),
                                _buildInfoRow('Nombre Actividad:', _actividadSeleccionada!.nombre),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Fecha y Hora
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Color(Constants.primaryColor)),
                            SizedBox(width: 8),
                            Text(
                              'Fecha y Hora',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: _seleccionarFechaHora,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Día y hora de inicio/fin',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(_fechaHora),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Estado de Asistencia
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Color(Constants.primaryColor)),
                            SizedBox(width: 8),
                            Text(
                              'Estado de Asistencia',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(Constants.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ...Constants.estadosAsistencia.map((estado) {
                          Color estadoColor;
                          IconData estadoIcon;
                          
                          switch (estado) {
                            case Constants.estadoAsistio:
                              estadoColor = Color(Constants.successColor);
                              estadoIcon = Icons.check_circle;
                              break;
                            case Constants.estadoNoAsistio:
                              estadoColor = Color(Constants.dangerColor);
                              estadoIcon = Icons.cancel;
                              break;
                            case Constants.estadoJustificado:
                              estadoColor = Color(Constants.warningColor);
                              estadoIcon = Icons.info;
                              break;
                            default:
                              estadoColor = Colors.grey;
                              estadoIcon = Icons.help;
                          }
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: RadioListTile<String>(
                              title: Row(
                                children: [
                                  Icon(estadoIcon, color: estadoColor, size: 20),
                                  SizedBox(width: 8),
                                  Text(estado),
                                ],
                              ),
                              value: estado,
                              groupValue: _estadoAsistencia,
                              onChanged: (value) {
                                setState(() => _estadoAsistencia = value!);
                              },
                              activeColor: estadoColor,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _guardando ? null : () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Cancelar'),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardarAsistencia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(Constants.successColor),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: _guardando
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Guardando...'),
                                ],
                              )
                            : Text('Registrar'),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(Constants.primaryColor),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}