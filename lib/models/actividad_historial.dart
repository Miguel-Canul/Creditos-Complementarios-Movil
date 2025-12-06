class ActividadHistorial {
  final String categoria;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final double cantidadCreditos;
  final String periodo;
  final int
      estado; // Estado de la actividad (0: En curso, 1: Completado, 2: Esperando aprobación)
  final String encargado;
  final String fechaFin;
  final String departamento;
  final int cupoActual;
  final String fechaInicio;
  final int cupoMaximo;
  final String pk;
  final String fotoURL;
  final String sk;

  // Campos de la inscripción
  final int? desempeno;
  final int? desempenoParcial;
  final String? observaciones;
  final int? estadoInscripcion; // 0: En curso, 1: Aprobado, 2: Reprobado
  final double? valorNumerico;

  // Campos del JSON de respuesta
  final String? categoriaNombre;
  final String? periodoNombre;

  ActividadHistorial({
    required this.categoria,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    required this.cantidadCreditos,
    required this.periodo,
    required this.estado,
    required this.encargado,
    required this.fechaFin,
    required this.departamento,
    required this.cupoActual,
    required this.fechaInicio,
    required this.cupoMaximo,
    required this.pk,
    required this.fotoURL,
    required this.sk,
    // Campos de inscripción
    this.desempeno,
    this.desempenoParcial,
    this.observaciones,
    this.estadoInscripcion,
    this.valorNumerico,
    // Campos del JSON de respuesta
    this.categoriaNombre,
    this.periodoNombre,
  });

  factory ActividadHistorial.fromJson(Map<String, dynamic> json) {
    return ActividadHistorial(
      categoria: json['Categoria']?.toString() ?? '',
      nombre: json['Nombre']?.toString() ?? '',
      descripcion: json['Descripcion']?.toString() ?? '',
      ubicacion: json['Ubicacion']?.toString() ?? '',
      cantidadCreditos: (json['CantidadCreditos'] ?? 0.0).toDouble(),
      periodo: json['Periodo']?.toString() ?? '',
      estado: (json['Estado'] ?? 0).toInt(),
      encargado: json['Encargado']?.toString() ?? '',
      fechaFin: json['FechaFin']?.toString() ?? '',
      departamento: json['Departamento']?.toString() ?? '',
      cupoActual: (json['CupoActual'] ?? 0).toInt(),
      fechaInicio: json['FechaInicio']?.toString() ?? '',
      cupoMaximo: (json['CupoMaximo'] ?? 0).toInt(),
      pk: json['PK']?.toString() ?? '',
      fotoURL: json['FotoURL']?.toString() ?? '',
      sk: json['SK']?.toString() ?? '',
      // Inicializar campos de inscripción
      desempeno: (json['Desempeno'] ?? 0).toInt(),
      desempenoParcial: (json['DesempenoParcial'] ?? 0).toInt(),
      observaciones: json['Observaciones']?.toString() ?? '',
      estadoInscripcion:
          (json['EstadoInscripcion'] ?? json['Estado'] ?? 0).toInt(),
      valorNumerico: (json['ValorNumerico'] ?? 0.0).toDouble(),
      // Campos del JSON de respuesta
      categoriaNombre: json['CategoriaNombre']?.toString() ?? '',
      periodoNombre: json['PeriodoNombre']?.toString() ?? '',
    );
  }

  // Método para crear desde el JSON de historial (con inscripción combinada)
  factory ActividadHistorial.fromHistorialJson(
      Map<String, dynamic> historialJson) {
    final actividadJson = historialJson['actividad'] ?? {};
    final inscripcionJson = historialJson['inscripcion'] ?? {};

    // Obtener el estado de la inscripción, si no existe usar 0 (En curso) como valor por defecto
    final estadoInscripcion = (inscripcionJson['Estado'] ?? 0).toInt();

    return ActividadHistorial(
      categoria: actividadJson['Categoria']?.toString() ?? '',
      nombre: actividadJson['Nombre']?.toString() ?? '',
      descripcion: actividadJson['Descripcion']?.toString() ?? '',
      ubicacion: actividadJson['Ubicacion']?.toString() ?? '',
      cantidadCreditos: (actividadJson['CantidadCreditos'] ?? 0.0).toDouble(),
      periodo: actividadJson['Periodo']?.toString() ?? '',
      estado: (actividadJson['Estado'] ?? 0).toInt(),
      encargado: actividadJson['Encargado']?.toString() ?? '',
      fechaFin: actividadJson['FechaFin']?.toString() ?? '',
      departamento: actividadJson['Departamento']?.toString() ?? '',
      cupoActual: (actividadJson['CupoActual'] ?? 0).toInt(),
      fechaInicio: actividadJson['FechaInicio']?.toString() ?? '',
      cupoMaximo: (actividadJson['CupoMaximo'] ?? 0).toInt(),
      pk: actividadJson['PK']?.toString() ?? '',
      fotoURL: actividadJson['FotoURL']?.toString() ?? '',
      sk: actividadJson['SK']?.toString() ?? '',
      // Campos de la inscripción - SIEMPRE usar los de inscripción
      desempeno: (inscripcionJson['Desempeno'] ?? 0).toInt(),
      desempenoParcial: (inscripcionJson['DesempenoParcial'] ?? 0).toInt(),
      observaciones: inscripcionJson['Observaciones']?.toString() ?? '',
      estadoInscripcion:
          estadoInscripcion, // <-- Usar el estado de la inscripción
      valorNumerico: (inscripcionJson['ValorNumerico'] ?? 0.0).toDouble(),
      // Campos del JSON de respuesta
      categoriaNombre: actividadJson['CategoriaNombre']?.toString() ?? '',
      periodoNombre: actividadJson['PeriodoNombre']?.toString() ?? '',
    );
  }

  // Métodos auxiliares para compatibilidad con tu UI existente
  // SIEMPRE usar estadoInscripcion (0: En curso, 1: Aprobado, 2: Reprobado)
  String get estadoTexto {
    // SIEMPRE usar estadoInscripcion, nunca el estado de la actividad
    final estadoFinal = estadoInscripcion ??
        0; // Si es null, usar 0 (En curso) como valor por defecto

    switch (estadoFinal) {
      case 0:
        return 'En curso';
      case 1:
        return 'Aprobado';
      case 2:
        return 'Reprobado';
      default:
        return 'Desconocido';
    }
  }

  // Métodos booleanos para verificar el estado de la inscripción
  bool get estaAprobado => (estadoInscripcion ?? 0) == 1;
  bool get estaReprobado => (estadoInscripcion ?? 0) == 2;
  bool get estaEnCurso => (estadoInscripcion ?? 0) == 0;

  // Método para verificar si la actividad otorga créditos (aprobada)
  bool get otorgaCreditos => estaAprobado;

  // Método para obtener créditos otorgados (solo si está aprobado)
  double get creditosOtorgados => estaAprobado ? cantidadCreditos : 0.0;

  String get desempenioTexto {
    // Usar el desempeño de la inscripción
    final desempenoFinal = desempeno ?? 0;

    switch (desempenoFinal) {
      case 0:
        return 'No evaluado';
      case 1:
        return 'Insuficiente';
      case 2:
        return 'Suficiente';
      case 3:
        return 'Notable';
      case 4:
        return 'Excelente';
      default:
        return 'No evaluado';
    }
  }

  String get desempenioParcialTexto {
    // Para actividades en curso
    final desempenoParcialFinal = desempenoParcial ?? 0;

    switch (desempenoParcialFinal) {
      case 0:
        return 'No evaluado';
      case 1:
        return 'Insuficiente';
      case 2:
        return 'Suficiente';
      case 3:
        return 'Notable';
      case 4:
        return 'Excelente';
      default:
        return 'No evaluado';
    }
  }

  // Getter para mostrar valorNumerico formateado (opcional)
  String get valorNumericoFormateado {
    if (valorNumerico == null) return '0.0';
    return valorNumerico!.toStringAsFixed(2); // 2 decimales
  }

  String? get folio => pk.isNotEmpty ? pk.split('#').last : null;

  DateTime? get fechaInicioDate {
    try {
      return DateTime.parse(fechaInicio);
    } catch (e) {
      return null;
    }
  }

  DateTime? get fechaFinDate {
    try {
      return fechaFin.isNotEmpty ? DateTime.parse(fechaFin) : null;
    } catch (e) {
      return null;
    }
  }

  // Para compatibilidad con tu UI actual
  String get foto => fotoURL;

  // Método para combinar actividad con datos de inscripción
  ActividadHistorial copyWithInscripcion({
    int? desempeno,
    int? desempenoParcial,
    String? observaciones,
    int? estadoInscripcion,
    double? valorNumerico,
    String? categoriaNombre,
    String? periodoNombre,
  }) {
    return ActividadHistorial(
      categoria: categoria,
      nombre: nombre,
      descripcion: descripcion,
      ubicacion: ubicacion,
      cantidadCreditos: cantidadCreditos,
      periodo: periodo,
      estado: estado,
      encargado: encargado,
      fechaFin: fechaFin,
      departamento: departamento,
      cupoActual: cupoActual,
      fechaInicio: fechaInicio,
      cupoMaximo: cupoMaximo,
      pk: pk,
      fotoURL: fotoURL,
      sk: sk,
      desempeno: desempeno ?? this.desempeno,
      desempenoParcial: desempenoParcial ?? this.desempenoParcial,
      observaciones: observaciones ?? this.observaciones,
      estadoInscripcion: estadoInscripcion ?? this.estadoInscripcion,
      valorNumerico: valorNumerico ?? this.valorNumerico,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      periodoNombre: periodoNombre ?? this.periodoNombre,
    );
  }

  // Método para comparar basado en el estado de inscripción
  bool tieneEstadoInscripcion(int estado) {
    return (estadoInscripcion ?? 0) == estado;
  }

  // Método para obtener el color del estado (útil para UI)
  // Puedes ajustar estos colores según tu tema
  String get estadoColor {
    switch (estadoInscripcion ?? 0) {
      case 0: // En curso
        return '0xFF2196F3'; // Azul
      case 1: // Aprobado
        return '0xFF4CAF50'; // Verde
      case 2: // Reprobado
        return '0xFFF44336'; // Rojo
      default:
        return '0xFF9E9E9E'; // Gris
    }
  }
}
