import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/actividad.dart';
import '../models/asistencia_detalle.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class EditarAsistenciaScreen extends StatefulWidget {
  final int asistenciaId;

  const EditarAsistenciaScreen({Key? key, required this.asistenciaId}) : super(key: key);

  @override
  _EditarAsistenciaScreenState createState() => _EditarAsistenciaScreenState();
}

class _EditarAsistenciaScreenState extends State<EditarAsistenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  AsistenciaDetalle? _asistencia;
  List<Actividad> _actividades = [];
  
  int? _actividadIdSeleccionada;
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
    
    final asistencia = await apiService.getAsistencia(widget.asistenciaId);
    final actividades = await apiService.getActividades();
    
    if (asistencia != null) {
      setState(() {
        _asistencia = asistencia;
        _actividades = actividades;
        _actividadIdSeleccionada = asistencia.actividadId;
        _estadoAsistencia = asistencia.estadoAsistencia;
        _fechaHora = asistencia.fechaHora;
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

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _guardando = true);
    
    final asistenciaData = {
      'id': widget.asistenciaId,
      'numeroControl': _asistencia!.numeroControl,
      'actividadId': _actividadIdSeleccionada,
      'fechaHora': _fechaHora.toIso8601String(),
      'estadoAsistencia': _estadoAsistencia,
    };
    
    final apiService = context.read<ApiService>();
    final success = await apiService.actualizarAsistencia(widget.asistenciaId, asistenciaData);
    
    setState(() => _guardando = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Asistencia actualizada correctamente'),
          backgroundColor: Color(Constants.successColor),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la asistencia'),
          backgroundColor: Color(Constants.dangerColor),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Asistencia'),
        backgroundColor: Color(Constants.accentColor),
      ),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando asistencia...'),
              ],
            ),
          )
        : Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Información del estudiante (solo lectura)
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
                        _buildReadOnlyField('N° de control', _asistencia!.numeroControl, Icons.badge),
                        SizedBox(height: 12),
                        _buildReadOnlyField('Nombre', _asistencia!.nombreEstudiante, Icons.person_outline),
                        SizedBox(height: 12),
                        _buildReadOnlyField('Carrera', _asistencia!.carreraEstudiante, Icons.school),
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
                          onChanged: (value) {
                            setState(() => _actividadIdSeleccionada = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione una actividad';
                            }
                            return null;
                          },
                          isExpanded: true,
                        ),
                        SizedBox(height: 16),
                        _buildReadOnlyField('Extraescolar/Taller', _asistencia!.extraescolarCalculado, Icons.category),
                        SizedBox(height: 12),
                        _buildReadOnlyField('Encargado', _asistencia!.encargado, Icons.person_pin),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Fecha y hora
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
                
                // Estado de asistencia
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
                        onPressed: _guardando ? null : _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(Constants.accentColor),
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
                            : Text('Guardar'),
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

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      readOnly: true,
    );
  }
}