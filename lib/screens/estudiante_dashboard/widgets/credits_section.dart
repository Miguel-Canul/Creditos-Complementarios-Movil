import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screens/historial_actividades_screen.dart';
import 'package:mobile/screens/widgets/progress_bar.dart'; // Importar nuevo widget
import '../../../utils/constants.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class CreditsSection extends StatefulWidget {
  const CreditsSection({super.key});

  @override
  State<CreditsSection> createState() => _CreditsSectionState();
}

class _CreditsSectionState extends State<CreditsSection> {
  String? _idEstudiante;
  final ApiService _servicioApi = ApiService();

  // Variables de estado
  double _creditosObtenidos = 0.0;
  String? _urlConstancia;

  @override
  void initState() {
    super.initState();

    final servicioAutenticacion = context.read<AuthService>();
    _idEstudiante = servicioAutenticacion.userSub;

    if (_idEstudiante != null) {
      _cargarDatos();
    } else {
      print('Error: ID de estudiante no disponible en la sesión activa.');
    }
  }

  void _cargarDatos() async {
    if (_idEstudiante == null) return;

    bool cumpleRequisitos = false;

    // Paso 1: Obtener créditos
    try {
      final double creditos =
          await _servicioApi.obtenerCreditosComplementarios(_idEstudiante!);

      // La condición lógica que determina la activación del botón
      if (creditos >= Constants.creditosRequeridos) {
        cumpleRequisitos = true;
      }

      // Paso 2: Si cumple, intentar obtener la URL
      String? urlConstancia;
      if (cumpleRequisitos) {
        urlConstancia =
            await _servicioApi.obtenerUrlConstanciaLiberacion(_idEstudiante!);
      }

      setState(() {
        _creditosObtenidos = creditos;
        _urlConstancia = urlConstancia;
      });
    } catch (e) {
      print('Error al cargar datos en UI: $e');
      setState(() {
        _creditosObtenidos = 0.0;
        _urlConstancia = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se eliminan _progressValue, _buildHeaderProgress y _buildProgressBar.
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uso del nuevo widget ProgressBar
            ProgressBar(
              titulo: 'Créditos obtenidos',
              cantidadActual: _creditosObtenidos,
              cantidadMaxima: Constants.creditosRequeridos,
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Los métodos _buildHeaderProgress, _buildCreditsTitle y _buildProgressCounter
  // ya no son necesarios aquí y han sido eliminados.

  // 3. Método: Construye el grupo de botones de acción
  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          const SizedBox(height: 2),
          _buildViewHistoryButton(),
          _buildDownloadCertificateButton(),
        ],
      ),
    );
  }

  // Construye el botón "Ver historial de actividades"
  Widget _buildViewHistoryButton() {
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

// Construye el botón "Descargar constancia de liberación"
  Widget _buildDownloadCertificateButton() {
    // Condición de Activación: Solo debe cumplir los créditos.
    final bool botonActivo = 
        _creditosObtenidos >= Constants.creditosRequeridos;

    // Si el botón está activo, se usa la función de descarga (placeholder).
    final VoidCallback? onPressedAction = botonActivo
        ? () {
            if (_urlConstancia != null) {
              print('Intentando descargar de: $_urlConstancia');
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