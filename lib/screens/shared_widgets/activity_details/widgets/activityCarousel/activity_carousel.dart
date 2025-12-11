import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_inscripcion.dart';
import 'package:mobile/screens/shared_widgets/activity_details/widgets/activityCarousel/widgets/ActivityInfoCard.dart';
import 'package:mobile/screens/shared_widgets/activity_details/widgets/activityCarousel/widgets/activity_schedule_card.dart';
import 'package:mobile/screens/shared_widgets/activity_page_indicator.dart';

class ActivityCarouselMine extends StatelessWidget {
  final ActividadInscripcion actividad;

  const ActivityCarouselMine({super.key, required this.actividad});

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
              ActivityInfoCardMine(actividad: actividad),
              ActivityScheduleCardMine(actividad: actividad),
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
