// screens/estudiante_dashboard/widgets/activity_card.dart

import 'package:flutter/material.dart';
import '../../../../../models/Actividad_inscripcion.dart';
import '../../../../../utils/constants.dart';

class ActivityCard extends StatelessWidget {
  final ActividadInscripcion actividad;

  const ActivityCard({
    super.key,
    required this.actividad,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Lógica de navegación a la pantalla de detalle
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetalleActividadScreen(actividad: actividad),
        //   ),
        // );
        print('Clic en actividad: ${actividad.nombre}. Objeto completo pasado.');
      },
      child: Container(
        width: 100, // Ancho fijo para el carrusel
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            _buildActivityAvatar(actividad.fotoUrl),
            const SizedBox(height: 8), 
            _buildActivityTitle(actividad.nombre),
          ],
        ),
      ),
    );
  }

  // Método: Construye el Avatar (Imagen o Icono de reemplazo)
  Widget _buildActivityAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 35,
      backgroundColor: const Color(Constants.primaryColor).withAlpha(10),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.star, // Icono de reemplazo si la imagen falla
              size: 30,
              color: Color(Constants.primaryColor),
            );
          },
        ),
      ),
    );
  }

  // Método: Construye el título del elemento del carrusel
  Widget _buildActivityTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}