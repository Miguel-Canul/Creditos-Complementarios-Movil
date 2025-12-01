import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/view_models/actividad_viewmodel.dart';
import 'package:provider/provider.dart';

import 'actividad_card.dart';

class ActividadesListSection extends StatelessWidget {
  const ActividadesListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActividadViewModel>();

    if (viewModel.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: const Color(Constants.primaryColor),
          ),
        ),
      );
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.cargarActividades(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final actividades = viewModel.actividades;

    if (actividades.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron actividades',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final actividad = actividades[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ActividadCard(actividad: actividad),
          );
        },
        childCount: actividades.length,
      ),
    );
  }
}
