import 'package:flutter/material.dart';
import 'package:mobile/screens/widgets/progress_bar.dart';
import 'package:mobile/view_models/actividad_viewmodel.dart';
import 'package:provider/provider.dart';

class CreditosSection extends StatelessWidget {
  const CreditosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActividadViewModel>();

    final hasCreditData = viewModel.creditosPorCategoria.isNotEmpty;
    final numeroCategorias = viewModel.creditosPorCategoria.keys.length;
    final maximoTotal = (numeroCategorias * 2).toDouble();

    return Container(
      margin: const EdgeInsets.all(16), // 👈 MISMO MARGEN
      padding: const EdgeInsets.all(20), // 👈 MISMO PADDING
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // 👈 UNIFICADO
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          const SizedBox(height: 16),
          if (hasCreditData) ...[
            ..._buildCategoryProgressBars(viewModel.creditosPorCategoria),
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Center(
      child: Text(
        'Créditos obtenidos por categoría',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, // 👈 NEGRITAS MÁS FUERTES
          color: Colors.black87,
        ),
      ),
    );
  }

  List<Widget> _buildCategoryProgressBars(
      Map<String, dynamic> creditosPorCategoria) {
    return creditosPorCategoria.entries.map((entry) {
      final categoria = entry.key;
      final creditos = _parseCreditos(entry.value);

      final creditosAjustados = creditos > 2.0 ? 2.0 : creditos;
      const maximoCategoria = 2.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatearCategoria(categoria),
              style: const TextStyle(
                fontSize: 20, // 👈 TAMAÑO MÁS PEQUEÑO
                fontWeight: FontWeight.w500, // 👈 PESO INTERMEDIO
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4), // 👈 ESPACIO ENTRE TÍTULO Y BARRA
            ProgressBar(
              titulo: '', // 👈 DEJAMOS VACÍO EL TÍTULO DEL PROGRESSBAR
              cantidadActual: creditosAjustados,
              cantidadMaxima: maximoCategoria,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[300],
    );
  }

  String _formatearCategoria(String categoria) {
    if (categoria.contains('#')) {
      return categoria.split('#').last;
    }
    return categoria;
  }

  double _parseCreditos(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
