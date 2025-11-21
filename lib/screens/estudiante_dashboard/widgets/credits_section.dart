// credits_section.dart

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class CreditsSection extends StatelessWidget {
  const CreditsSection({super.key});

  @override
  Widget build(BuildContext context) {
    const double progressValue = 2 / 5; // Valor de progreso

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
            // --- NUEVA DISPOSICIÓN: Título y Contador en la misma línea (Row) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea extremos
              children: [
                // Créditos obtenidos (Izquierda)
                const Text(
                  'Créditos obtenidos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Contador de Progreso (Derecha)
                Text(
                  '${(progressValue * 5).toInt()}/5',
                  style: const TextStyle(
                    fontSize: 18, // Aumentamos el tamaño para que coincida con el título
                    fontWeight: FontWeight.bold, // Aumentamos el peso
                    color: Color(Constants.primaryColor),
                  ),
                ),
              ],
            ),
            // ---------------------------------------------------------------------

            const SizedBox(height: 8), // Espacio después del título/contador

            // Barra de Progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(Constants.primaryColor)), // Color principal
                minHeight: 10,
              ),
            ),

            // Botones (Manteniendo el Align para agrupar los botones a la derecha)
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Eliminamos el espacio y el texto '2/5' que movimos arriba
                  const SizedBox(height: 8), // Espacio después de la barra de progreso

                  // 2. Espacio MÍNIMO entre la barra de progreso y el primer botón
                  const SizedBox(height: 2), 

                  // Botón 1: Ver historial
                  TextButton(
                    // ... (Estilos TextButton.styleFrom...)
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
                  ),

                  // Botón 2: Descargar constancia
                  TextButton.icon(
                    // ... (Estilos TextButton.styleFrom...)
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      alignment: Alignment.centerRight,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: null, // Deshabilitado
                    icon: const Icon(Icons.picture_as_pdf,
                        color: Colors.grey, size: 18),
                    label: const Text(
                      'Descargar constancia de liberación',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
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
}