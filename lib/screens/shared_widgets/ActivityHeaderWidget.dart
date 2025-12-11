import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';

class ActivityHeaderWidget extends StatelessWidget {
  final ActividadHistorial actividad;

  const ActivityHeaderWidget({super.key, required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            actividad.foto,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          actividad.nombre,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "(${actividad.categoriaNombre ?? actividad.categoria})",
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
