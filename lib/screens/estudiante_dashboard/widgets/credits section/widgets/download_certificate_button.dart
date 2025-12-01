import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importar url_launcher
import '../../../../../../utils/constants.dart';

class DownloadCertificateButton extends StatelessWidget {
  final double creditosObtenidos;
  final String? urlConstancia;

  const DownloadCertificateButton({
    super.key,
    required this.creditosObtenidos,
    required this.urlConstancia,
  });

  // Método: Maneja el lanzamiento de la URL (Descarga/Vista del PDF)
  Future<void> _lanzarUrlConstancia(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Si la URL no puede ser lanzada (ej: formato incorrecto)
      print('Error: No se pudo lanzar la URL $url'); 
      throw Exception('No se pudo lanzar la URL $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Condición de Activación: Solo debe cumplir los créditos.
    final bool botonActivo = creditosObtenidos >= Constants.creditosRequeridos;

    final VoidCallback? onPressedAction = botonActivo
        ? () {
            if (urlConstancia != null) {
              // Llamada a la función de lanzamiento
              _lanzarUrlConstancia(urlConstancia!);
            } else {
              print('Créditos suficientes, pero URL de constancia nula.');
            }
          }
        : null;

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
      onPressed: onPressedAction,
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