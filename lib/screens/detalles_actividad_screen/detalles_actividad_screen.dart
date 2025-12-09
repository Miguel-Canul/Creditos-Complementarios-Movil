import 'package:flutter/material.dart';
import 'package:mobile/screens/widgets/ActivityDescriptionWidget.dart';
import 'package:mobile/screens/widgets/ActivityHeaderWidget.dart';
import 'package:mobile/screens/widgets/ActivityInfoCard.dart';
import 'package:mobile/screens/widgets/activity_carousel.dart';
import '../../models/actividad_historial.dart';
import '../widgets/custom_sliver_app_bar.dart';

class DetallesActividadScreen extends StatelessWidget {
  const DetallesActividadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ActividadHistorial actividad =
        ModalRoute.of(context)!.settings.arguments as ActividadHistorial;

    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            titulo: "Detalles de Actividad",
            mostrarBotonRetroceso: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  /// HEADER (foto + nombre + categoría)
                  ActivityHeaderWidget(actividad: actividad),

                  const SizedBox(height: 20),

                  /// DESCRIPCIÓN
                  ActivityDescriptionWidget(descripcion: actividad.descripcion),

                  const SizedBox(height: 20),

                  /// CARRUSEL (Periodo + Horario)
                  ActivityCarousel(actividad: actividad),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoDesempeno(ActividadHistorial actividad) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estado de la Actividad",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "• ${actividad.estadoTexto}",
            style: TextStyle(
              fontSize: 15,
              color: _getEstadoColor(actividad.estadoTexto),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actividad.desempenioTexto != "No evaluado") ...[
            const SizedBox(height: 8),
            Text(
              "• Desempeño: ${actividad.desempenioTexto}",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

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
}
