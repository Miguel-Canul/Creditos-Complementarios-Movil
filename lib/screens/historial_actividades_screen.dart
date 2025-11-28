import 'package:flutter/material.dart';
import 'package:mobile/models/actividad_historial.dart';
import 'package:provider/provider.dart';
import '../view_models/actividad_viewmodel.dart';
import '../utils/constants.dart';

class HistorialActividadesScreen extends StatefulWidget {
  const HistorialActividadesScreen({super.key});

  @override
  _HistorialActividadesScreenState createState() =>
      _HistorialActividadesScreenState();
}

class _HistorialActividadesScreenState
    extends State<HistorialActividadesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActividadViewModel>().cargarActividades();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f2f5),
      appBar: AppBar(
        title: const Text('Historial de Actividades'),
        backgroundColor: const Color(Constants.primaryColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCreditosSection(),
          _buildActividadesList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: const Text(
        'Historial de actividades',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCreditosSection() {
    final viewModel = context.watch<ActividadViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Créditos obtenidos por categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Mostrar créditos por categoría desde la API
          if (viewModel.creditosPorCategoria.isNotEmpty)
            ...viewModel.creditosPorCategoria.entries.map((entry) {
              return Column(
                children: [
                  _buildCategoriaItem(
                    _formatearCategoria(entry.key),
                    (entry.value as num).toDouble(),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList()
          else
            const Text(
              'No hay créditos registrados por categoría',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          // Total de créditos
          Text(
            'Total de créditos: ${viewModel.totalCreditos}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearCategoria(String categoria) {
    // Remover el prefijo "CATEGORIA#" si existe
    if (categoria.contains('#')) {
      return categoria.split('#').last;
    }
    return categoria;
  }

  Widget _buildCategoriaItem(String categoria, double creditos) {
    // Cambia int por double
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[600]!, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$categoria $creditos', // Esto mostrará el double correctamente
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActividadesList() {
    final viewModel = context.watch<ActividadViewModel>();

    if (viewModel.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(Constants.primaryColor),
          ),
        ),
      );
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                viewModel.errorMessage,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.cargarActividades(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final actividades = viewModel.actividades;

    if (actividades.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No se encontraron actividades',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actividades.length,
        itemBuilder: (context, index) {
          final actividad = actividades[index];
          return _buildActividadCard(actividad);
        },
      ),
    );
  }

  Widget _buildActividadCard(ActividadHistorial actividad) {
    final bool isCompletado =
        actividad.estadoTexto.toLowerCase() == 'completado';
    final bool isEnCurso = actividad.estadoTexto.toLowerCase() == 'en curso';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN DE LA ACTIVIDAD - CAMBIA Image.asset POR Image.network
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              height: 140,
              width: double.infinity,
              child: Image.network(
                // CAMBIO IMPORTANTE
                actividad.fotoURL.isNotEmpty
                    ? actividad.fotoURL
                    : 'https://via.placeholder.com/400x200?text=Sin+Imagen',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Imagen no disponible',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Header con nombre y botón de descarga
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getEstadoColor(actividad.estadoTexto)
                  .withOpacity(0.1), // USA estadoTexto
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Categoría debajo del nombre
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatearCategoria(
                              actividad.categoria), // FORMATEA LA CATEGORÍA
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompletado)
                  IconButton(
                    onPressed: () {
                      _descargarConstancia(actividad);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.file_download,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    tooltip: 'Descargar constancia',
                  ),
              ],
            ),
          ),

          // Contenido de la actividad
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila: Período y Estado
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Período:',
                        _formatearPeriodo(
                            actividad.periodo), // FORMATEA EL PERIODO
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        'Estado:',
                        actividad.estadoTexto, // USA estadoTexto
                        Icons.info_outline,
                        _getEstadoColor(
                            actividad.estadoTexto), // USA estadoTexto
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Segunda fila: Folio y Desempeño
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Folio:',
                        actividad.folio?.isNotEmpty == true
                            ? actividad.folio!
                            : 'No asignado',
                        Icons.assignment,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailItem(
                        isEnCurso ? 'Desempeño parcial:' : 'Desempeño:',
                        actividad.desempenioTexto, // USA desempenioTexto
                        Icons.assessment,
                        _getDesempenioColor(
                            actividad.desempenioTexto), // USA desempenioTexto
                      ),
                    ),
                  ],
                ),

                // Fechas si están disponibles - USA LOS GETTERS DE DATETIME
                if (actividad.fechaInicioDate != null ||
                    actividad.fechaFinDate != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Fecha inicio:',
                              actividad.fechaInicioDate != null
                                  ? _formatDate(actividad.fechaInicioDate!)
                                  : 'No definida',
                              Icons.play_arrow,
                              Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailItem(
                              'Fecha fin:',
                              actividad.fechaFinDate != null
                                  ? _formatDate(actividad.fechaFinDate!)
                                  : 'No definida',
                              Icons.stop,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Créditos de la actividad
                const SizedBox(height: 16),
                _buildDetailItem(
                  'Créditos:',
                  '${actividad.cantidadCreditos}',
                  Icons.school,
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Métodos auxiliares
  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en curso':
        return Colors.orange;
      case 'esperando aprobación':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getDesempenioColor(String? desempenio) {
    if (desempenio == null || desempenio.isEmpty) return Colors.grey;

    switch (desempenio.toLowerCase()) {
      case 'excelente':
        return Colors.green;
      case 'notable':
        return Colors.lightGreen;
      case 'suficiente':
        return Colors.orange;
      case 'insuficiente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _descargarConstancia(ActividadHistorial actividad) {
    // Simular descarga de constancia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando constancia de ${actividad.nombre}'),
        backgroundColor: const Color(Constants.successColor),
        duration: const Duration(seconds: 2),
      ),
    );

    // Aquí iría la lógica real de descarga
    print('Iniciando descarga para: ${actividad.nombre}');
  }

  String _formatearPeriodo(String periodo) {
    // Remover el prefijo "PERIODO#" si existe
    if (periodo.contains('#')) {
      return periodo.split('#').last;
    }
    return periodo;
  }
}
