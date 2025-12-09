import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ProgressBar extends StatelessWidget {
  final String titulo;
  final double cantidadActual;
  final double cantidadMaxima;

  const ProgressBar({
    super.key,
    required this.titulo,
    required this.cantidadActual,
    required this.cantidadMaxima,
  });

  double get _valorProgreso => cantidadActual / cantidadMaxima;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderProgress(),
        const SizedBox(height: 8),
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildHeaderProgress() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTitle(),
        _buildProgressCounter(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProgressCounter() {
    return Text(
      '$cantidadActual/${cantidadMaxima.toInt()}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(Constants.primaryColor),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: _valorProgreso,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(
            Color(Constants.primaryColor)),
        minHeight: 10,
      ),
    );
  }
}