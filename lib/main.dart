import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/estudiante_dashboard_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/configuracion_service.dart';
import 'utils/constants.dart';

void main() {
  // Ocultar mensajes de overflow
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!details.toString().contains('overflowed')) {
      FlutterError.presentError(details);
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ConfiguracionService>(
          create: (_) => ConfiguracionService(),
        ),
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
      ],
      child: Consumer2<AuthService, ConfiguracionService>(
        builder: (context, authService, configService, child) {
          return MaterialApp(
            title: 'Gestión de Asistencias TecNM',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Container(
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      'Error en la aplicación',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              };
              return child!;
            },

            // Tema dinámico basado en configuración
            theme: _buildTheme(configService, false),
            darkTheme: _buildTheme(configService, true),
            themeMode: configService.modoOscuroActivo
                ? ThemeMode.dark
                : ThemeMode.light,

            // Navegación inicial basada en autenticación
            home: const EstudianteDashboardScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(ConfiguracionService configService, bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    const primaryColor = Color(Constants.primaryColor);
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Tamaño de texto basado en configuración
    double textScaleFactor = 1.0;
    switch (configService.tamanoTextoActivo) {
      case 'pequeño':
        textScaleFactor = 0.9;
        break;
      case 'normal':
        textScaleFactor = 1.0;
        break;
      case 'grande':
        textScaleFactor = 1.1;
        break;
      case 'extra-grande':
        textScaleFactor = 1.2;
        break;
    }

    return ThemeData(
      brightness: brightness,
      primarySwatch: const MaterialColor(
        Constants.primaryColor,
        <int, Color>{
          50: const Color(0xFFE3F2FD),
          100: const Color(0xFFBBDEFB),
          200: const Color(0xFF90CAF9),
          300: const Color(0xFF64B5F6),
          400: const Color(0xFF42A5F5),
          500: primaryColor,
          600: const Color(0xFF1E88E5),
          700: const Color(0xFF1976D2),
          800: const Color(0xFF1565C0),
          900: const Color(0xFF0D47A1),
        },
      ),

      // Colores principales
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20 * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: surfaceColor,
      ),

      // Input theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 16 * textScaleFactor),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontSize: 14 * textScaleFactor),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(fontSize: 14 * textScaleFactor),
        ),
      ),

      // FAB theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(Constants.successColor),
        foregroundColor: Colors.white,
      ),

      // Text theme con escalado
      textTheme: _buildTextTheme(textScaleFactor, isDark),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }

  TextTheme _buildTextTheme(double scaleFactor, bool isDark) {
    final baseColor = isDark ? Colors.white : Colors.black87;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32 * scaleFactor, color: baseColor),
      displayMedium: TextStyle(fontSize: 28 * scaleFactor, color: baseColor),
      displaySmall: TextStyle(fontSize: 24 * scaleFactor, color: baseColor),
      headlineLarge: TextStyle(fontSize: 22 * scaleFactor, color: baseColor),
      headlineMedium: TextStyle(fontSize: 20 * scaleFactor, color: baseColor),
      headlineSmall: TextStyle(fontSize: 18 * scaleFactor, color: baseColor),
      titleLarge: TextStyle(fontSize: 16 * scaleFactor, color: baseColor),
      titleMedium: TextStyle(fontSize: 14 * scaleFactor, color: baseColor),
      titleSmall: TextStyle(fontSize: 12 * scaleFactor, color: baseColor),
      bodyLarge: TextStyle(fontSize: 16 * scaleFactor, color: baseColor),
      bodyMedium: TextStyle(fontSize: 14 * scaleFactor, color: baseColor),
      bodySmall: TextStyle(fontSize: 12 * scaleFactor, color: baseColor),
      labelLarge: TextStyle(fontSize: 14 * scaleFactor, color: baseColor),
      labelMedium: TextStyle(fontSize: 12 * scaleFactor, color: baseColor),
      labelSmall: TextStyle(fontSize: 10 * scaleFactor, color: baseColor),
    );
  }
}

// Widget wrapper para manejar la autenticación y navegación por rol
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      final authService = context.read<AuthService>();
      final configService = context.read<ConfiguracionService>();

      // Inicializar servicios
      await authService.initialize();

      if (authService.isAuthenticated) {
        await configService.initialize(authService);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error al inicializar servicios: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(Constants.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando aplicación...',
                style: TextStyle(
                  color: Color(Constants.primaryColor),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          // Navegación basada en el rol del usuario
          final userRole = authService.getCurrentUserRole();

          switch (userRole) {
            case 'Estudiante':
              return EstudianteDashboardScreen();
            case 'Encargado':
            default:
              return const LoginScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
