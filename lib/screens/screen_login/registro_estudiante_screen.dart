import 'package:flutter/material.dart';
import 'package:mobile/screens/screen_login/confirmacion_registro_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // SEPARAR EN NOMBRES Y APELLIDOS
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();

  // Lista de carreras
  final List<String> _carreras = [
    'Ingeniería en Administración',
    'Licenciatura en Administración',
    'Arquitectura',
    'Licenciatura en Biología',
    'Licenciatura en Turismo',
    'Ingeniería Civil',
    'Contador Público',
    'Ingeniería Eléctrica',
    'Ingeniería Electromecánica',
    'Ingeniería en Gestión Empresarial',
    'Ingeniería en Desarrollo de Aplicaciones',
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería en Tecnologías de la Información y Comunicaciones',
  ];

  // Lista de semestres
  final List<String> _semestres =
      List.generate(12, (index) => 'Semestre ${index + 1}');

  // Variables para los nuevos campos
  String? _selectedCarrera;
  String? _selectedSemestre;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    super.dispose();
  }

  Future<void> _registrarEstudiante() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar los nuevos campos
    if (_selectedCarrera == null || _selectedCarrera!.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor selecciona tu carrera';
      });
      return;
    }

    if (_selectedSemestre == null || _selectedSemestre!.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor selecciona tu semestre';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();

      final emailInput = _emailController.text.trim();
      final nombre = _nombresController.text.trim();
      final apellidos = _apellidosController.text.trim();

      // Para Cognito: given_name = nombres, family_name = apellidos
      final nombreCompletoCognito = '$nombre $apellidos'.trim();

      // Para DynamoDB: guardamos por separado
      final semestreNumero = _selectedSemestre!.replaceAll('Semestre ', '');

      print('=== DATOS DEL REGISTRO ===');
      print('Email input: $emailInput');
      print('Nombres: $nombre');
      print('Apellidos: $apellidos');
      print('Nombre completo (Cognito): $nombreCompletoCognito');
      print('Carrera: $_selectedCarrera');
      print('Semestre: $semestreNumero');

      // 1. Registrar en Cognito
      final result = await authService.registro(
        nombreCompletoCognito, // Este se separará en given_name y family_name
        emailInput,
        _passwordController.text,
      );

      if (result['success'] == true) {
        final emailFormateado = result['email'] ?? emailInput;

        // 2. Registrar en DynamoDB con nombres y apellidos separados
        final dynamoResult = await authService.registrarEnDynamoDB(
          email: emailFormateado,
          nombre: nombre,
          apellidos: apellidos,
          carrera: _selectedCarrera!,
          semestre: semestreNumero,
        );

        setState(() => _isLoading = false);

        if (dynamoResult['success'] == true) {
          // Éxito completo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registro completo exitoso'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          if (result['requiresConfirmation'] == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmacionRegistroScreen(
                  email: emailFormateado,
                ),
              ),
            );
          } else {
            Navigator.pop(context);
          }
        } else {
          // Error en DynamoDB
          setState(() {
            _errorMessage = dynamoResult['message'] ??
                'Error al guardar datos en la base de datos';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
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
          // NOMBRES (given_name en Cognito)
          TextFormField(
            controller: _nombresController,
            decoration: InputDecoration(
              labelText: 'Nombres',
              hintText: 'Ej: Marco Antonio',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              helperText: 'Todos tus nombres',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tus nombres';
              }
              if (value.length < 2) {
                return 'Debe tener al menos 2 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // APELLIDOS (family_name en Cognito)
          TextFormField(
            controller: _apellidosController,
            decoration: InputDecoration(
              labelText: 'Apellidos',
              hintText: 'Ej: González Arias',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              helperText: 'Todos tus apellidos',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tus apellidos';
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

          // Carrera - Dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedCarrera,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.school_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                ),
                items: _carreras
                    .map((carrera) => DropdownMenuItem<String>(
                          value: carrera,
                          child: Text(carrera),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCarrera = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona tu carrera';
                  }
                  return null;
                },
                hint: const Text('Selecciona tu carrera'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                dropdownColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Semestre - Dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonFormField<String>(
                value: _selectedSemestre,
                decoration: InputDecoration(
                  labelText: 'Semestre',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.class_outlined),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                ),
                items: _semestres
                    .map((semestre) => DropdownMenuItem<String>(
                          value: semestre,
                          child: Text(semestre),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSemestre = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona tu semestre';
                  }
                  return null;
                },
                hint: const Text('Selecciona tu semestre'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                dropdownColor: Colors.white,
              ),
            ),
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

          // Nota sobre los datos
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(Constants.primaryColor).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(Constants.primaryColor).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Text(
              'Nota: Los datos se guardarán después de confirmar tu correo electrónico.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
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
