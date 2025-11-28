import 'package:flutter/material.dart';
import 'widgets/welcome_message.dart';
import '../widgets/custom_sliver_app_bar.dart';
import 'widgets/credits section/credits_section.dart';
import 'widgets/available activities section/available_activities_section.dart';

class EstudianteDashboardScreen extends StatefulWidget {
  const EstudianteDashboardScreen({super.key});

  @override
  _EstudianteDashboardScreenState createState() =>
      _EstudianteDashboardScreenState();
}

class _EstudianteDashboardScreenState extends State<EstudianteDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: const CustomScrollView(
        slivers: [
          CustomSliverAppBar(titulo: "Créditos complementarios"),
          WelcomeMessage(),
          CreditsSection(),
          AvailableActivitiesSection(),
        ],
      ),
    );
  }
}
