import 'package:flutter/material.dart';
import 'package:mobile/screens/historial_actividades_screen.dart';
import '../../../utils/constants.dart';
import '../../../services/api_service.dart';

class CreditsSection extends StatefulWidget {
  const CreditsSection({super.key});

  @override
  State<CreditsSection> createState() => _CreditsSectionState();
}

class _CreditsSectionState extends State<CreditsSection> {
  static const String alumnoID = '290939ce-2031-7051-846b-9bd220fa68af';
  final ApiService _servicioApi = ApiService();

  // Variables de estado
  double _creditosObtenidos = 0.0;
  String? _urlConstancia;

  double get _progressValue =>
      _creditosObtenidos / Constants.creditosRequeridos;

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Inicia la carga de datos al inicializar el Widget
  }

  void _cargarDatos() async {
    bool cumpleRequisitos = false;

    // Paso 1: Obtener créditos
    try {
      final double creditos =
          await _servicioApi.obtenerCreditosComplementarios(alumnoID);

      // La condición lógica que determina la activación del botón
      if (creditos >= Constants.creditosRequeridos) {
        cumpleRequisitos = true;
      }

      // Paso 2: Si cumple, intentar obtener la URL
      String? urlConstancia;
      if (cumpleRequisitos) {
        urlConstancia =
            await _servicioApi.obtenerUrlConstanciaLiberacion(alumnoID);
      }

      setState(() {
        _creditosObtenidos = creditos;
        _urlConstancia = urlConstancia; // Puede ser String o null
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
    // El método build ahora es el ensamblador principal.
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
            _buildHeaderProgress(),
            _buildProgressBar(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // 1. Método: Construye el encabezado (Título + Contador)
  Widget _buildHeaderProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCreditsTitle(),
        _buildProgressCounter(),
      ],
    );
  }

// Construye el título "Créditos obtenidos"
  Widget _buildCreditsTitle() {
    return const Text(
      'Créditos obtenidos',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

// Construye el contador de progreso (ej: 2/5)
  Widget _buildProgressCounter() {
    return Text(
      '$_creditosObtenidos/${Constants.creditosRequeridos.toInt()}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(Constants.primaryColor),
      ),
    );
  }

  // 2. Método: Construye la barra de progreso
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: _progressValue.toDouble(),
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(
            Color(Constants.primaryColor)), // Color principal
        minHeight: 10,
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
          _buildViewHistoryButton(),
          _buildDownloadCertificateButton(),
        ],
      ),
    );
  }

  // Construye el botón "Ver historial de actividades"
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
    // Condición de Activación:
    // 1. Debe cumplir los créditos.
    // 2. La URL debe existir (_urlConstancia no es null) (Requerido por la API).
    final bool botonActivo = _urlConstancia != null &&
        _creditosObtenidos >= Constants.creditosRequeridos;

    // Si el botón está activo, se usa la función de descarga (placeholder).
    final VoidCallback? onPressedAction = botonActivo
        ? () {
            if (_urlConstancia != null) {
              print('Intentando descargar de: $_urlConstancia');
              // Aquí irá la lógica de lanzamiento o descarga de URL
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
