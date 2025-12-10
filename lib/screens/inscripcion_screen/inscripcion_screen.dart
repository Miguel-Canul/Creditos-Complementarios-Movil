import 'package:flutter/material.dart';
import 'package:mobile/screens/inscripcion_screen/widgets/inscripcion_button.dart';
import 'package:mobile/screens/shared_widgets/activity_details/activity_details.dart';
import 'package:mobile/screens/shared_widgets/custom_sliver_app_bar.dart';
import '../../models/actividad_inscripcion.dart';

// Nombres Significativos: Pantalla específica para inscripción.
class InscripcionScreen extends StatelessWidget {
  final ActividadInscripcion actividad;

  const InscripcionScreen({
    super.key,
    required this.actividad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(
            titulo: "Inscripción de Actividad",
            mostrarBotonRetroceso: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reusa la sección de información existente
                ActivityDetails(actividad: actividad),

                const SizedBox(height: 30),

                // Botón de Inscripción
                Center(
                  child: InscripcionButton(idActividad: actividad.id),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}