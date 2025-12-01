import 'package:flutter/material.dart';
import 'package:mobile/screens/widgets/progress_bar.dart';
import 'package:mobile/view_models/actividad_viewmodel.dart';
import 'package:provider/provider.dart';

class CreditosSection extends StatelessWidget {
  const CreditosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ActividadViewModel>();

    // Verificar si hay datos
    final hasCreditData = viewModel.creditosPorCategoria.isNotEmpty;
    final numeroCategorias = viewModel.creditosPorCategoria.keys.length;
    // ignore: unused_local_variable
    final maximoTotal = (numeroCategorias * 2).toDouble();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          _buildSectionTitle(),
          const SizedBox(height: 16),

          // Barras de progreso por categoría
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
    return const Text(
      'Créditos obtenidos por categoría',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  List<Widget> _buildCategoryProgressBars(
      Map<String, dynamic> creditosPorCategoria) {
    return creditosPorCategoria.entries.map((entry) {
      final categoria = entry.key;
      final creditos = _parseCreditos(entry.value);

      // Verificar que no exceda el máximo de 2
      final creditosAjustados = creditos > 2.0 ? 2.0 : creditos;
      const maximoCategoria = 2.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ProgressBar(
          titulo: _formatearCategoria(categoria),
          cantidadActual: creditosAjustados,
          cantidadMaxima: maximoCategoria,
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
    // Remover el prefijo "CATEGORIA#" si existe
    if (categoria.contains('#')) {
      return categoria.split('#').last;
    }
    return categoria;
  }

  double _parseCreditos(dynamic value) {
    // Convertir el valor a double de forma segura
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
