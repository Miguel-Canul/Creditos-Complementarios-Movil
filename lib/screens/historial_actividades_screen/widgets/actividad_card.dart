import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/utils/constants.dart';

class ActividadCard extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActividadCard({super.key, required this.actividad});

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    final bool isCompletado =
        actividad.estadoTexto.toLowerCase() == 'completado';
    final bool isEnCurso = actividad.estadoTexto.toLowerCase() == 'en curso';

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivityImage(),
          _buildActivityHeader(isCompletado),
          _buildActivityDetails(isEnCurso),
        ],
      ),
    );
  }

  Widget _buildActivityImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        height: 140,
        width: double.infinity,
        child: Image.network(
          actividad.fotoURL.isNotEmpty
              ? actividad.fotoURL
              : 'https://via.placeholder.com/400x200?text=Sin+Imagen',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Imagen no disponible',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityHeader(bool isCompletado) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getEstadoColor(actividad.estadoTexto).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actividad.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildCategoryChip(),
              ],
            ),
          ),
          if (isCompletado) _buildDownloadButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        actividad.categoriaNombre ?? 'Sin categoría',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2E7D32),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return IconButton(
      onPressed: () => _descargarConstancia(context!),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.file_download,
          color: Colors.white,
          size: 20,
        ),
      ),
      tooltip: 'Descargar constancia',
    );
  }

  Widget _buildActivityDetails(bool isEnCurso) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Período:',
                  actividad.periodoNombre ?? 'Sin período',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  'Estado:',
                  actividad.estadoTexto,
                  Icons.info_outline,
                  _getEstadoColor(actividad.estadoTexto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            isEnCurso ? 'Desempeño parcial:' : 'Desempeño:',
            actividad.desempenioTexto,
            Icons.assessment,
            _getDesempenioColor(actividad.desempenioTexto),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en curso':
        return Colors.orange;
      case 'esperando aprobación':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getDesempenioColor(String? desempenio) {
    if (desempenio == null || desempenio.isEmpty) return Colors.grey;

    switch (desempenio.toLowerCase()) {
      case 'excelente':
        return Colors.green;
      case 'notable':
        return Colors.lightGreen;
      case 'suficiente':
        return Colors.orange;
      case 'insuficiente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _descargarConstancia(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando constancia de ${actividad.nombre}'),
        backgroundColor: const Color(Constants.successColor),
        duration: const Duration(seconds: 2),
      ),
    );
    print('Iniciando descarga para: ${actividad.nombre}');
  }
}
