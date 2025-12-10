import 'package:flutter/material.dart';
import 'package:mobile/utils/constants.dart';

// Clases y Objetos: Responsabilidad Única (Mostrar el modal de error 409)
class InscripcionErrorModal {
  static void mostrar(BuildContext context, int codigoError) {
    String titulo = 'Atención';
    String mensaje = 'Ha ocurrido un error inesperado.';

    // Lógica simple para manejar el 409, puede ser más robusta
    if (codigoError == 409) {
      mensaje = 'Ya estás inscrito en esta actividad.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(titulo)),
          content: Text(
            mensaje,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Botón de cierre con color primario
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              }
              ,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}