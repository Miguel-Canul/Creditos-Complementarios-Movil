import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _emailSent = false;
  
  late AnimationController _animationController;
  late AnimationController _successAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successAnimationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarRecuperacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      final success = await authService.recuperarPassword(_emailController.text.trim());

      setState(() => _isLoading = false);

      if (success) {
        setState(() {
          _emailSent = true;
          _successMessage = 'Se ha enviado un enlace de recuperación a tu correo electrónico.';
        });
        
        _successAnimationController.forward();
      } else {
        setState(() {
          _errorMessage = 'No se encontró una cuenta con este correo electrónico.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      });
    }
  }

  Future<void> _reenviarCorreo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.recuperarPassword(_emailController.text.trim());

      setState(() {
        _isLoading = false;
        _successMessage = 'Correo reenviado exitosamente.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correo de recuperación reenviado'),
          backgroundColor: Color(Constants.successColor),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al reenviar el correo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(Constants.primaryColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recuperar Contraseña',
          style: TextStyle(
            color: Color(Constants.primaryColor),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      
                      // Header
                      _buildHeader(),
                      
                      SizedBox(height: 40),
                      
                      // Contenido principal basado en el estado
                      if (_emailSent)
                        ScaleTransition(
                          scale: _successAnimation,
                          child: _buildSuccessContent(),
                        )
                      else
                        _buildFormContent(),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _emailSent 
                ? Color(Constants.successColor).withOpacity(0.1)
                : Color(Constants.warningColor).withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_emailSent 
                    ? Color(Constants.successColor) 
                    : Color(Constants.warningColor)).withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read_outlined : Icons.lock_reset,
            size: 50,
            color: _emailSent 
                ? Color(Constants.successColor)
                : Color(Constants.warningColor),
          ),
        ),
        
        SizedBox(height: 24),
        
        Text(
          _emailSent ? '¡Correo Enviado!' : '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(Constants.primaryColor),
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 12),
        
        Text(
          _emailSent 
              ? 'Revisa tu bandeja de entrada y sigue las instrucciones'
              : 'No te preocupes, te enviaremos un enlace para recuperarla',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    return Column(
      children: [
        // Formulario
        Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _enviarRecuperacion(),
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'tu.email@chetumal.tecnm.mx',
                prefixIcon: Container(
                  margin: EdgeInsets.all(12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(Constants.warningColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: Color(Constants.warningColor),
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(Constants.warningColor), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(Constants.dangerColor), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu correo electrónico';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
          ),
        ),
        
        // Mensaje de error
        if (_errorMessage != null) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(Constants.dangerColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(Constants.dangerColor).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Color(Constants.dangerColor),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
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
        
        SizedBox(height: 24),
        
        // Botón enviar
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(Constants.warningColor),
                Color(Constants.warningColor).withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(Constants.warningColor).withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _enviarRecuperacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Enviando...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Enviar Enlace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        SizedBox(height: 20),
        
        // Volver al login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                color: Color(Constants.primaryColor),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Volver al inicio de sesión',
                style: TextStyle(
                  color: Color(Constants.primaryColor),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Mensaje de éxito
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(Constants.successColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(Constants.successColor).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read,
                size: 60,
                color: Color(Constants.successColor),
              ),
              
              SizedBox(height: 16),
              
              Text(
                _successMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Información adicional
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Instrucciones',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionItem('1. Revisa tu bandeja de entrada'),
                  _buildInstructionItem('2. Busca el correo de TecNM'),
                  _buildInstructionItem('3. Haz clic en el enlace de recuperación'),
                  _buildInstructionItem('4. Crea tu nueva contraseña'),
                  SizedBox(height: 8),
                  Text(
                    'Si no encuentras el correo, revisa tu carpeta de spam.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24),
        
        // Botones de acción
        Column(
          children: [
            // Botón reenviar
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(Constants.primaryColor),
                  width: 2,
                ),
              ),
              child: OutlinedButton(
                onPressed: _isLoading ? null : _reenviarCorreo,
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(Constants.primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reenviando...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(Constants.primaryColor),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: Color(Constants.primaryColor),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Reenviar correo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(Constants.primaryColor),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Botón volver al login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Volver al inicio de sesión',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Mensaje de ayuda adicional
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.orange[700], size: 18),
                  SizedBox(width: 8),
                  Text(
                    '¿Necesitas ayuda?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Si sigues teniendo problemas para recuperar tu cuenta, contacta al administrador del sistema.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String instruction) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}