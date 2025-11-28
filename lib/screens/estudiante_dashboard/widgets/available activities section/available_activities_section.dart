// screens/estudiante_dashboard/widgets/available_activities_section.dart

import 'package:flutter/material.dart';
import 'widgets/activities_data_controller.dart'; // Nuevo widget para la lógica de estado

class AvailableActivitiesSection extends StatelessWidget {
  const AvailableActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
        // Delega la responsabilidad de estado y carga al controlador
        child: ActivitiesDataController(), 
      ),
    );
  }
}