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

      // REEMPLAZO: Muestra el modal de éxito en lugar del SnackBar
      _mostrarExitoModal();
    } catch (e) {
      // Si el error contiene la cadena "409" (Conflicto), muestra el modal específico
      if (e.toString().contains("409")) {
        _mostrarErrorInscripcionModal();
      } else {
        // Muestra el mensaje de error general
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fallo en la inscripción: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _estaCargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inscripcionExitosa) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed:
          _estaCargando ? null : _mostrarConfirmacionModal, // Texto sin ícono
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(Constants.primaryColor),
        foregroundColor: Colors.white,
      ), // Llama al modal
      child: _estaCargando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text('Inscribirme'),
    );
  }

  // Función: Muestra el modal de confirmación.
  void _mostrarConfirmacionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Confirmar Inscripción')),
          content: const Text('¿Inscribirse en esta actividad?'),
          actions: <Widget>[
            // Botón No (Cancela)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            // Botón Sí (Confirma) con color primario
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _manejarInscripcion(); // Llama a la lógica de inscripción
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, Inscribirme'),
            ),
          ],
        );
      },
    );
  }

  // Función: Muestra el modal de error por inscripción existente (Error 409).
  void _mostrarErrorInscripcionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Atención')),
          content: const Text(
            'Ya estás inscrito en esta actividad.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Botón de cierre con color primario
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(Constants.primaryColor),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Función: Muestra el modal de inscripción exitosa.
  void _mostrarExitoModal() {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe presionar 'Cerrar'
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('¡Inscripción Exitosa!')),
          content: const Text(
            'Te has inscrito con éxito en la actividad.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // Botón de cierre con color primario
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(Constants.primaryColor),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        );
      },
    );
  }
}
