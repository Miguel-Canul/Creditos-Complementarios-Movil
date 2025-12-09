import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';

class ConfirmacionRegistroScreen extends StatefulWidget {
  final String email;

  const ConfirmacionRegistroScreen({
    super.key,
    required this.email,
  });

  @override
  _ConfirmacionRegistroScreenState createState() =>
      _ConfirmacionRegistroScreenState();
}

class _ConfirmacionRegistroScreenState
    extends State<ConfirmacionRegistroScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getCodigo() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _confirmarRegistro() async {
    final codigo = _getCodigo();

    if (codigo.length != 6) {
      setState(() {
        _errorMessage = 'Ingresa el código completo de 6 dígitos';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final confirmado = await authService.confirmarRegistro(
        widget.email,
        codigo,
      );

      setState(() => _isLoading = false);

      if (confirmado) {
        // Mostrar mensaje de éxito y regresar a login
        _mostrarExitoYRegresar();
      } else {
        setState(() {
          _errorMessage = 'Código incorrecto';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al confirmar';
      });
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final reenviado = await authService.reenviarCodigoConfirmacion(
        widget.email,
      );

      setState(() => _isLoading = false);

      if (reenviado) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código reenviado al correo'),
            backgroundColor: Color(Constants.successColor),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Error al reenviar';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión';
      });
    }
  }

  void _mostrarExitoYRegresar() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Cuenta Confirmada!'),
        content: const Text(
            'Tu cuenta ha sido verificada exitosamente. Ahora puedes iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Regresar a login
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void _manejarCambioTexto(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Si se borró un carácter, retroceder
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmar Registro',
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
              // Icono
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 40, bottom: 30),
                decoration: BoxDecoration(
                  color: const Color(Constants.primaryColor).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: Color(Constants.primaryColor),
                  ),
                ),
              ),

              // Título
              const Text(
                'Verifica tu correo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(Constants.primaryColor),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Instrucciones
              Text(
                'Se envió un código de 6 dígitos a:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(Constants.primaryColor),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Código de 6 dígitos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(Constants.primaryColor),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(Constants.primaryColor),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _manejarCambioTexto(index, value),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Reenviar código
              TextButton(
                onPressed: _isLoading ? null : _reenviarCodigo,
                child: const Text(
                  'Reenviar código',
                  style: TextStyle(
                    color: Color(Constants.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Mensaje de error
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(Constants.dangerColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Botón de confirmar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarRegistro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(Constants.successColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirmar Cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
