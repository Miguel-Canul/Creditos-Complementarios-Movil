import 'package:flutter/material.dart';
import 'package:mobile/screens/shared_widgets/progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screens/estudiante_dashboard/widgets/credits%20section/widgets/view_history_button.dart'; // Nuevo widget
import 'package:mobile/screens/estudiante_dashboard/widgets/credits%20section/widgets/download_certificate_button.dart'; // Nuevo widget
import '../../../../utils/constants.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';

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
            await _servicioApi.obtenerUrlConstanciaLiberacion(_idEstudiante!) ??
                await _servicioApi.crearConstanciaLiberacion(_idEstudiante!);
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
            // Uso del widget ProgressBar
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

  // 3. Método: Construye el grupo de botones de acción
  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 8),
          const SizedBox(height: 2),
          // Uso de los nuevos widgets de botón
          const ViewHistoryButton(),
          DownloadCertificateButton(
            creditosObtenidos: _creditosObtenidos,
            urlConstancia: _urlConstancia,
          ),
        ],
      ),
    );
  }
  // Se eliminan _buildViewHistoryButton y _buildDownloadCertificateButton
}
