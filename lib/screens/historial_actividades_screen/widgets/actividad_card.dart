import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/utils/constants.dart';

class ActividadCard extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActividadCard({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final bool isAprobado = actividad.estaAprobado;
    final bool isReprobado = actividad.estaReprobado;
    final bool isEnCurso = actividad.estaEnCurso;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // CONTENIDO PRINCIPAL
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              _buildLeftImage(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _buildRightContent(
                    isAprobado: isAprobado,
                    isReprobado: isReprobado,
                    isEnCurso: isEnCurso,
                    context: context,
                  ),
                ),
              ),
              // Espacio extra a la derecha para que el botón no tape el texto
              const SizedBox(width: 40),
            ],
          ),

          // BOTÓN DE DESCARGA EN ESQUINA INFERIOR DERECHA
          if (isAprobado)
            Positioned(
              right: 12,
              bottom: 12,
              child: IconButton(
                icon: Icon(Icons.download,
                    size: 22, color: Theme.of(context).primaryColor),
                onPressed: () => _descargarConstancia(context),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------
  //   IMAGEN IZQUIERDA
  // -------------------------
  Widget _buildLeftImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: SizedBox(
        width: 100,
        height: 120,
        child: Image.network(
          actividad.fotoURL.isNotEmpty
              ? actividad.fotoURL
              : 'https://via.placeholder.com/150?text=Sin+Imagen',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  //   CONTENIDO DERECHO
  // -------------------------
  Widget _buildRightContent({
    required bool isAprobado,
    required bool isReprobado,
    required bool isEnCurso,
    required BuildContext context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TÍTULO
        Text(
          actividad.nombre,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // PERÍODO
        Text(
          "Periodo: ${actividad.periodoNombre ?? 'Sin período'}",
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),

        // ESTADO
        Text(
          "Estado: ${actividad.estadoTexto}",
          style: TextStyle(
            fontSize: 13,
            color: _getEstadoColor(actividad.estadoTexto),
            fontWeight: FontWeight.w600,
          ),
        ),

        // DESEMPEÑO
        if (isEnCurso)
          Text(
            "Desempeño parcial: ${actividad.desempenioParcialTexto}",
            style: TextStyle(
              fontSize: 13,
              color: _getDesempenioColor(actividad.desempenioParcialTexto),
            ),
          ),

        if (isAprobado || isReprobado)
          Text(
            "Desempeño: ${actividad.desempenioTexto}",
            style: TextStyle(
              fontSize: 13,
              color: _getDesempenioColor(actividad.desempenioTexto),
            ),
          ),
      ],
    );
  }

  // -------------------------------------
  //              COLORES
  // -------------------------------------
  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return Colors.green;
      case 'reprobado':
        return Colors.red;
      case 'en curso':
        return Colors.blue;
      case 'esperando aprobación':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getDesempenioColor(String? d) {
    if (d == null) return Colors.grey;

    switch (d.toLowerCase()) {
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

  // -------------------------------------
  //            DESCARGAR PDF
  // -------------------------------------
  void _descargarConstancia(BuildContext context) {
    if (!actividad.estaAprobado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo disponible para actividades aprobadas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando constancia de ${actividad.nombre}'),
        backgroundColor: const Color(Constants.successColor),
      ),
    );
  }
}
