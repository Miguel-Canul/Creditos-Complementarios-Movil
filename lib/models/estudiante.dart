import 'package:mobile/services/auth_service.dart';

class Estudiante {
  final String sub; // ID único
  final String numeroControl; // Del email: l21390301
  final String nombreCompleto; // given_name + family_name
  final String email;
  final String? givenName;
  final String? familyName;
  final String rol;

  Estudiante({
    required this.sub,
    required this.numeroControl,
    required this.nombreCompleto,
    required this.email,
    this.givenName,
    this.familyName,
    required this.rol,
  });

  // Factory constructor desde AuthService
  factory Estudiante.fromAuthService(AuthService auth) {
    return Estudiante(
      sub: auth.userSub ?? '',
      numeroControl: auth.userNumeroControl ?? '',
      nombreCompleto: auth.userNombreCompleto ?? auth.userName ?? '',
      email: auth.userEmail ?? '',
      givenName: auth.userGivenName,
      familyName: auth.userFamilyName,
      rol: auth.userRole ?? 'Estudiante',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'numeroControl': numeroControl,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'givenName': givenName,
      'familyName': familyName,
      'rol': rol,
    };
  }

  @override
  String toString() {
    return 'Estudiante(sub: $sub, numeroControl: $numeroControl, nombre: $nombreCompleto, email: $email, rol: $rol)';
  }
}
