import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../../screens/login_screen.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: const Color(Constants.primaryColor),
      elevation: 4,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16.0,
      title: _buildTitle(),
      actions: _buildActions(context),
    );
  }

// 1. Método para construir el TÍTULO
  Widget _buildTitle() {
    return const Text(
      'Créditos complementarios',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

// 2. Método para construir el BOTÓN DE CERRAR SESIÓN
  List<Widget> _buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.logout,
          color: Colors.white,
          size: 26,
        ),
        // Llama al nuevo método para manejar la acción
        onPressed: () => _handleLogout(context),
      ),
      const SizedBox(width: 8),
    ];
  }

  // Método: Manejar la lógica de cierre de sesión y navegación
  Future<void> _handleLogout(BuildContext context) async {
    final servicioAutenticacion =
        Provider.of<AuthService>(context, listen: false);

    // Navegar al LoginScreen y eliminar todas las rutas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );

    // Llamar al logout (cierra la sesión en Cognito y limpia datos)
    await servicioAutenticacion.logout();
  }
}