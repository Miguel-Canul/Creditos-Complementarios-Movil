class Constants {
  // Para iOS Simulator (localhost funciona directamente)
  static const String apiUrlIOS = 'http://localhost:5273';
  
  // Para Android Emulator (usar 10.0.2.2 en lugar de localhost)
  static const String apiUrlAndroid = 'http://192.168.0.5:5273';
  
  // Para dispositivos físicos (usar la IP correcta en la red local)
  static const String apiUrlDevice = 'http://192.168.0.5:5273'; 
  
  // URL que se usará (detecta automáticamente la plataforma)
  static String get apiUrl {
    // URL de Android que funciona en ambos emuladores
    return apiUrlAndroid;
  }
  
  // Colores del tema
  static const primaryColor = 0xFF004a87;    // Azul principal
  static const secondaryColor = 0xFF697D99;  // Azul secundario
  static const accentColor = 0xFF17a2b8;     // Acento
  static const successColor = 0xFF28a745;    // Verde éxito
  static const warningColor = 0xFFffc107;    // Amarillo advertencia
  static const dangerColor = 0xFFdc3545;     // Rojo peligro
  
  // Estados de asistencia
  static const String estadoAsistio = 'Asistio';
  static const String estadoNoAsistio = 'No asistio';
  static const String estadoJustificado = 'Justificado';
  
  static const List<String> estadosAsistencia = [
    estadoAsistio,
    estadoNoAsistio,
    estadoJustificado,
  ];
  
  // Meses del año
  static const List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
}