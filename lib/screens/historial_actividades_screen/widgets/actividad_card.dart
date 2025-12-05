import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/utils/constants.dart';

class ActividadCard extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActividadCard({super.key, required this.actividad});

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    // CAMBIO IMPORTANTE: Usar los estados booleanos de la inscripción
    final bool isAprobado = actividad.estaAprobado;
    final bool isReprobado = actividad.estaReprobado;
    final bool isEnCurso = actividad.estaEnCurso;

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
          _buildActivityHeader(isAprobado),
          _buildActivityDetails(isEnCurso, isAprobado, isReprobado),
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

  Widget _buildActivityHeader(bool isAprobado) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // CAMBIO: Usar el color del estado de inscripción
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
                // NUEVO: Mostrar créditos otorgados si está aprobado
                if (isAprobado) ...[
                  const SizedBox(height: 4),
                  _buildCreditosChip(),
                ],
              ],
            ),
          ),
          // CAMBIO: Solo mostrar botón de descarga si está APROBADO
          if (isAprobado) _buildDownloadButton(),
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

  // NUEVO: Chip para mostrar créditos otorgados
  Widget _buildCreditosChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${actividad.cantidadCreditos} créditos aprobados',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4CAF50),
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

  Widget _buildActivityDetails(
      bool isEnCurso, bool isAprobado, bool isReprobado) {
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
                  actividad
                      .estadoTexto, // <-- Esto ahora muestra el estado de INSCRIPCIÓN
                  Icons.info_outline,
                  _getEstadoColor(actividad.estadoTexto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mostrar valor numérico si está disponible
          if (actividad.valorNumerico != null && actividad.valorNumerico! > 0)
            _buildDetailItem(
              'Calificación:',
              actividad.valorNumericoFormateado,
              Icons.grade,
              _getValorNumericoColor(actividad.valorNumerico!),
            ),

          // Mostrar desempeño según el estado
          if (isEnCurso)
            _buildDetailItem(
              'Desempeño parcial:',
              actividad.desempenioParcialTexto,
              Icons.assessment,
              _getDesempenioColor(actividad.desempenioParcialTexto),
            ),

          if (isAprobado || isReprobado)
            _buildDetailItem(
              'Desempeño final:',
              actividad.desempenioTexto,
              Icons.assessment,
              _getDesempenioColor(actividad.desempenioTexto),
            ),

          // Mostrar observaciones si existen
          if (actividad.observaciones != null &&
              actividad.observaciones!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildObservaciones(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
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
      ),
    );
  }

  // NUEVO: Widget para mostrar observaciones
  Widget _buildObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.message,
              size: 16,
              color: Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              'Observaciones:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            actividad.observaciones!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange[800],
            ),
          ),
        ),
      ],
    );
  }

  // CAMBIO IMPORTANTE: Actualizar los colores según los nuevos estados
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return const Color(0xFF4CAF50); // Verde
      case 'reprobado':
        return const Color(0xFFF44336); // Rojo
      case 'en curso':
        return const Color(0xFF2196F3); // Azul
      default:
        return Colors.grey;
    }
  }

  // NUEVO: Método para obtener color basado en valor numérico
  Color _getValorNumericoColor(double valor) {
    if (valor >= 8.0) return Colors.green;
    if (valor >= 6.0) return Colors.orange;
    return Colors.red;
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
      case 'no evaluado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _descargarConstancia(BuildContext context) {
    // Solo permitir descargar si está aprobado
    if (!actividad.estaAprobado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Solo puedes descargar constancias de actividades aprobadas'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

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
