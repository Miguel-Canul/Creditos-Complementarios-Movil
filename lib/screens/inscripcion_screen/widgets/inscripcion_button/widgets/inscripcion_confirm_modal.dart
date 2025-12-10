import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';

// Clases y Objetos: Responsabilidad Única (Mostrar el modal de confirmación)
class InscripcionConfirmModal {
  // Nombres Significativos: El callback es la acción a ejecutar al confirmar.
  static void mostrar(BuildContext context, VoidCallback onConfirmar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(child: Text('Confirmar inscripción')),
          content: const Text('¿Inscribirse en esta actividad?'),
          actions: <Widget>[
            // Botón No (Cancela)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(Constants.primaryColor),
              ),
              child: const Text('No'),
            ),
            // Botón Sí (Confirma) con color primario
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmar(); // Llama al método de inscripción
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );
  }
}