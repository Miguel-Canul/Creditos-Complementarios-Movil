import 'package:flutter/material.dart';
import 'package:mobile/screens/inscripcion_screen/widgets/inscripcion_button/widgets/inscripcion_confirm_modal.dart';
import 'package:mobile/screens/inscripcion_screen/widgets/inscripcion_button/widgets/inscripcion_error_modal.dart';
import 'package:mobile/screens/inscripcion_screen/widgets/inscripcion_button/widgets/inscripcion_success_modal.dart';
import 'package:provider/provider.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart'; 
import '../../../../utils/constants.dart';

// Clases y Objetos: Responsabilidad Única (Manejar el estado del botón y la transacción)
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

  // Funciones: Hace una sola cosa (Manejar la inscripción y mostrar modales de resultado)
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
      // Llama al widget de modal dedicado
      InscripcionSuccessModal.mostrar(context); 

    } catch (e) {
      // Si el error contiene la cadena "409" (Conflicto), muestra el modal específico
      if (e.toString().contains("409")) {
        InscripcionErrorModal.mostrar(context, 409);
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

  // Función: Muestra el modal de confirmación, iniciando el flujo de inscripción.
  void _mostrarConfirmacionModal() {
    InscripcionConfirmModal.mostrar(context, _manejarInscripcion);
  }

  @override
  Widget build(BuildContext context) {
    if (_inscripcionExitosa) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: _estaCargando ? null : _mostrarConfirmacionModal,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(Constants.primaryColor),
        foregroundColor: Colors.white,
      ), 
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
}