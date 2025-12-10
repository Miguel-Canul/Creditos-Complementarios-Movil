import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';

// Clases y Objetos: Responsabilidad Única (Mostrar el modal de éxito)
class InscripcionSuccessModal {
  static void mostrar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(child: Text('¡Inscripción Exitosa!')),
          content: const Text(
            'Te has inscrito con éxito en la actividad.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Botón de cierre con color primario
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(Constants.primaryColor),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        );
      },
    );
  }
}