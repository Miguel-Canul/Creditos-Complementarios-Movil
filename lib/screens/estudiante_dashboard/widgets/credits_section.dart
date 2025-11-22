import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class CreditsSection extends StatelessWidget {
  const CreditsSection({super.key});

  final double progressValue = 2 / 5; // Mantenemos el valor aquí para pasarlo

  @override
  Widget build(BuildContext context) {
    // El método build ahora es el ensamblador principal.
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderProgress(),
            _buildProgressBar(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // 1. Método: Construye el encabezado (Título + Contador)
  Widget _buildHeaderProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCreditsTitle(),
        _buildProgressCounter(),
      ],
    );
  }

// Construye el título "Créditos obtenidos"
  Widget _buildCreditsTitle() {
    return const Text(
      'Créditos obtenidos',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

// Construye el contador de progreso (ej: 2/5)
  Widget _buildProgressCounter() {
    return Text(
      '${(progressValue * 5).toInt()}/5',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(Constants.primaryColor),
      ),
    );
  }

  // 2. Método: Construye la barra de progreso
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(
            Color(Constants.primaryColor)), // Color principal
        minHeight: 10,
      ),
    );
  }

  // 3. Método: Construye el grupo de botones de acción
  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          const SizedBox(height: 2),
          _buildViewHistoryButton(),
          _buildDownloadCertificateButton(),
        ],
      ),
    );
  }

  // Construye el botón "Ver historial de actividades"
  Widget _buildViewHistoryButton() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        alignment: Alignment.centerRight,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        // Acción para "Ver historial"
      },
      child: const Text(
        'Ver historial de actividades',
        style: TextStyle(
          color: Color(Constants.accentColor),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

// Construye el botón "Descargar constancia de liberación"
  Widget _buildDownloadCertificateButton() {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        alignment: Alignment.centerRight,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: null, // Deshabilitado
      icon: const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 18),
      label: const Text(
        'Descargar constancia de liberación',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
