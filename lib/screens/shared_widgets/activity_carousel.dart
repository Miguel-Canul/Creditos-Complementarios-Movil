import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:mobile/screens/shared_widgets/ActivityInfoCard.dart';
import 'package:mobile/screens/shared_widgets/activity_page_indicator.dart';
import 'package:mobile/screens/shared_widgets/activity_schedule_card.dart';

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
