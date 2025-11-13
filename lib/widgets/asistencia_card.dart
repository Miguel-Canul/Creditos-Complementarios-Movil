import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/asistencia_detalle.dart';
import '../utils/constants.dart';

class AsistenciaCard extends StatelessWidget {
  final AsistenciaDetalle asistencia;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AsistenciaCard({
    Key? key,
    required this.asistencia,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getEstadoColor() {
    switch (asistencia.estadoAsistencia) {
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
    switch (asistencia.estadoAsistencia) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con número de control y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asistencia.numeroControl,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(Constants.primaryColor),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          asistencia.nombreEstudiante,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getEstadoColor(),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getEstadoIcon(),
                          size: 16,
                          color: _getEstadoColor(),
                        ),
                        SizedBox(width: 4),
                        Text(
                          asistencia.estadoAsistencia,
                          style: TextStyle(
                            color: _getEstadoColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Información de la actividad
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.school,
                      'Carrera',
                      asistencia.carreraEstudiante,
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.category,
                      'Extraescolar/Taller',
                      asistencia.extraescolarCalculado,
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.person,
                      'Encargado',
                      asistencia.encargado,
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.event,
                      'Actividad',
                      asistencia.nombreActividad,
                    ),
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.access_time,
                      'Fecha y hora',
                      DateFormat('dd/MM/yyyy \'a las\' HH:mm').format(asistencia.fechaHora),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 12),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(Constants.accentColor),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                  if (onEdit != null && onDelete != null) SizedBox(width: 8),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete, size: 16),
                      label: Text('Eliminar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(Constants.dangerColor),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
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
}