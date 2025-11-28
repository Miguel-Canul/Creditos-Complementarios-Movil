import 'package:flutter/material.dart';
import 'package:mobile/screens/historial_actividades_screen.dart';
import '../../../../utils/constants.dart';

class ViewHistoryButton extends StatelessWidget {
  const ViewHistoryButton({super.key});

  // Construye el botón "Ver historial de actividades"
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        alignment: Alignment.centerRight,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        // Navegar a la pantalla HistorialActividadesScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistorialActividadesScreen(),
          ),
        );
      },
      child: const Text(
        'Ver historial de actividades',
        style: TextStyle(
          color: Color(Constants.accentColor),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}