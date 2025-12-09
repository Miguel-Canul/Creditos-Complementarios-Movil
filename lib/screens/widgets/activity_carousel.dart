import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/screens/widgets/ActivityInfoCard.dart';
import 'activity_schedule_card.dart';
import 'activity_page_indicator.dart';

class ActivityCarousel extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActivityCarousel({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return Column(
      children: [
        SizedBox(
          height: 350,
          child: PageView(
            controller: controller,
            children: [
              ActivityInfoCard(actividad: actividad),
              ActivityScheduleCard(actividad: actividad),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Indicador de páginas (puntitos)
        ActivityPageIndicator(
          controller: controller,
          pageCount: 2,
        ),
      ],
    );
  }
}
