import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener la instancia de AuthService y escuchar cambios para el rebuild
    final servicioAutenticacion = context.watch<AuthService>();
    
    final nombre = servicioAutenticacion.userGivenName ?? 'Estudiante';

    // El nombre y apellido deberían venir en los claims de Cognito. 
    // Asumo que tu AuthService tiene getters llamados 'userName' y 'userFamilyName'.

    final mensaje = '¡Bienvenido, $nombre!';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Text(
          mensaje,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}