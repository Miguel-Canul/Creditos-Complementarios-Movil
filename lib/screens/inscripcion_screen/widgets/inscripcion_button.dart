import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart'; // Asumiendo AuthService
import '../../../../utils/constants.dart';

// Clases y Objetos: Responsabilidad Única (manejar la inscripción)
class InscripcionButton extends StatefulWidget {
  final String idActividad;

  const InscripcionButton({
    super.key,
    required this.idActividad,
  });

  @override
  State<InscripcionButton> createState() => _InscripcionButtonState();
}

class _InscripcionButtonState extends State<InscripcionButton> {
  bool _estaCargando = false;
  bool _inscripcionExitosa = false;

  // Funciones: Hace una sola cosa (manejar la inscripción)
  void _manejarInscripcion() async {
    final servicioAutenticacion = context.read<AuthService>();
    final idEstudiante = servicioAutenticacion.userSub;

    if (idEstudiante == null) return;

    setState(() {
      _estaCargando = true;
    });

    try {
      final apiService = ApiService();
      await apiService.inscribirAlumno(idEstudiante, widget.idActividad);
      
      setState(() {
        _inscripcionExitosa = true;
      });
      // Muestra un SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscripción exitosa.')),
      );
    } catch (e) {
      // Muestra el mensaje de error (ej: Cupo lleno, Error HTTP)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fallo en la inscripción: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inscripcionExitosa) {
      return const Text(
        '¡Inscrito!',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _estaCargando ? null : _manejarInscripcion,
      icon: _estaCargando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.check_circle_outline),
      label: Text(_estaCargando ? 'Inscribiendo...' : 'Inscribirse Ahora'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(Constants.primaryColor),
        foregroundColor: Colors.white,
      ),
    );
  }
}