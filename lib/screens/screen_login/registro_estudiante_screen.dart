import 'package:flutter/material.dart';
import 'package:mobile/screens/screen_login/confirmacion_registro_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

class RegistroEstudianteScreen extends StatefulWidget {
  const RegistroEstudianteScreen({super.key});

  @override
  _RegistroEstudianteScreenState createState() =>
      _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _registrarEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();

      // IMPORTANTE: Tu AuthService ya maneja tanto número de control
      // como email completo. Solo necesitamos enviar lo que el usuario ingresó.
      final emailInput = _emailController.text.trim();
      final nombreCompleto =
          '${_nombreController.text.trim()} ${_apellidoController.text.trim()}'
              .trim();

      print('=== DATOS DEL REGISTRO ===');
      print('Email input: $emailInput');
      print('Nombre completo: $nombreCompleto');

      final result = await authService.registro(
        nombreCompleto,
        emailInput, // El AuthService se encargará de validar y formatear
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registro exitoso'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navegar a pantalla de confirmación si es necesario
        if (result['requiresConfirmation'] == true) {
          // Usar el email que retorna el AuthService (ya formateado)
          final emailFormateado = result['email'] ?? emailInput;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmacionRegistroScreen(
                email: emailFormateado,
              ),
            ),
          );
        } else {
          // Si no requiere confirmación, volver a login
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Error en el registro';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });
    }
  }

  void _volverALogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(Constants.primaryColor)),
          onPressed: _volverALogin,
        ),
        title: const Text(
          'Registro Estudiante',
          style: TextStyle(
            color: Color(Constants.primaryColor),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 20, bottom: 30),
                decoration: BoxDecoration(
                  color: const Color(Constants.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_tecnm.jpeg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person_add_alt_1,
                        size: 40,
                        color: const Color(Constants.primaryColor),
                      );
                    },
                  ),
                ),
              ),

              // Subtítulo
              Text(
                'TecNM Campus Chetumal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Instrucción
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: 'Puedes ingresar: ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: 'Lxxxxxxxx',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' o ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: 'Lxxxxxxxx@chetumal.tecnm.mx',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Formulario
              _buildForm(),

              const SizedBox(height: 20),

              // Botón de registro
              _buildRegistroButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nombre
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre(s)',
              hintText: '',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu nombre';
              }
              if (value.length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Apellido
          TextFormField(
            controller: _apellidoController,
            decoration: InputDecoration(
              labelText: 'Apellido(s)',
              hintText: '',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu apellido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo flexible: acepta número de control O email completo
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Número de Control o Email',
              hintText: 'Lxxxxxxxx o Lxxxxxxxx@chetumal.tecnm.mx',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText:
                  'El sistema automáticamente agregará el dominio si es necesario',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu número de control o email';
              }

              // Validar que sea un formato aceptable:
              // 1. Solo número de control: L21390305
              // 2. Email completo: L21390305@chetumal.tecnm.mx

              final input = value.trim();

              // Si es solo número de control
              if (!input.contains('@')) {
                if (!RegExp(r'^[Ll]\d{8}$').hasMatch(input)) {
                  return 'Formato: L + 8 dígitos (ej: L21390305)';
                }
              }
              // Si es email completo
              else {
                if (!input.toLowerCase().endsWith('@chetumal.tecnm.mx')) {
                  return 'Solo correos @chetumal.tecnm.mx';
                }
                // Extraer el número de control del email
                final numeroControl = input.split('@').first;
                if (!RegExp(r'^[Ll]\d{8}$').hasMatch(numeroControl)) {
                  return 'Formato incorrecto antes de @';
                }
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          // Contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Mínimo 8 caracteres',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Debe incluir mayúsculas y números',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una contraseña';
              }
              if (value.length < 8) {
                return 'Mínimo 8 caracteres';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Debe incluir al menos una mayúscula';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Debe incluir al menos un número';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirmar contraseña
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña',
              hintText: 'Repite tu contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),

          // Mensaje de error
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(Constants.dangerColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(Constants.dangerColor).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(Constants.dangerColor),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(Constants.dangerColor),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegistroButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registrarEstudiante,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(Constants.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Enviar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
