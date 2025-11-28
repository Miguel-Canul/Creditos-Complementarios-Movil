import 'package:flutter/material.dart';
import '../../../../utils/constants.dart';

class DownloadCertificateButton extends StatelessWidget {
  final double creditosObtenidos;
  final String? urlConstancia;

  const DownloadCertificateButton({
    super.key,
    required this.creditosObtenidos,
    required this.urlConstancia,
  });

  @override
  Widget build(BuildContext context) {
    // Condición de Activación: Solo debe cumplir los créditos.
    final bool botonActivo = creditosObtenidos >= Constants.creditosRequeridos;

    // Si el botón está activo, se usa la función de descarga (placeholder).
    final VoidCallback? onPressedAction = botonActivo
        ? () {
            if (urlConstancia != null) {
              print('Intentando descargar de: $urlConstancia');
              // Aquí irá la lógica de lanzamiento o descarga de URL
            } else {
              print('Créditos suficientes, pero URL de constancia nula.');
            }
          }
        : null; // null desactiva el TextButton

    final Color colorTexto =
        botonActivo ? const Color(Constants.accentColor) : Colors.grey;

    final Color colorIcono =
        botonActivo ? const Color(Constants.accentColor) : Colors.grey;

    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        alignment: Alignment.centerRight,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressedAction, // Usa la función o null
      icon: Icon(Icons.picture_as_pdf, color: colorIcono, size: 18),
      label: Text(
        'Descargar constancia de liberación',
        style: TextStyle(
          color: colorTexto,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}