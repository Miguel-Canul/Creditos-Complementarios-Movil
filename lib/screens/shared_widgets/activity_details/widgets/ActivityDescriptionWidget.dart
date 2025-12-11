import 'package:flutter/material.dart';

class ActivityDescription extends StatelessWidget {
  final String descripcion;

  const ActivityDescription({super.key, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity, // <-- Ocupa todo el ancho disponible
        ),
        child: Text(descripcion),
      ),
    );
  }
}
