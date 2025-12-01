class ActividadHistorial {
  final String categoria;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final double cantidadCreditos;
  final String periodo;
  final int estado;
  final String encargado;
  final String fechaFin;
  final String departamento;
  final int cupoActual;
  final String fechaInicio;
  final int cupoMaximo;
  final String pk;
  final String fotoURL;
  final String sk;

  // Nuevos campos para la inscripción
  final int? desempeno;
  final int? desempenoParcial;
  final String? observaciones;
  final int? estadoInscripcion;
  final double? valorNumerico; // <-- Cambiado a double

  // Nuevos campos del JSON de respuesta
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
    // Nuevos campos opcionales
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
      // Inicializar nuevos campos con valores por defecto
      desempeno: (json['Desempeno'] ?? 0).toInt(),
      desempenoParcial: (json['DesempenoParcial'] ?? 0).toInt(),
      observaciones: json['Observaciones']?.toString() ?? '',
      estadoInscripcion: (json['EstadoInscripcion'] ?? 0).toInt(),
      valorNumerico: (json['ValorNumerico'] ?? 0.0).toDouble(), // <-- Cambiado
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
      // Campos de la inscripción
      desempeno: (inscripcionJson['Desempeno'] ?? 0).toInt(),
      desempenoParcial: (inscripcionJson['DesempenoParcial'] ?? 0).toInt(),
      observaciones: inscripcionJson['Observaciones']?.toString() ?? '',
      estadoInscripcion: (inscripcionJson['Estado'] ?? 0).toInt(),
      valorNumerico:
          (inscripcionJson['ValorNumerico'] ?? 0.0).toDouble(), // <-- Cambiado
      // Campos del JSON de respuesta
      categoriaNombre: actividadJson['CategoriaNombre']?.toString() ?? '',
      periodoNombre: actividadJson['PeriodoNombre']?.toString() ?? '',
    );
  }

  // Métodos auxiliares para compatibilidad con tu UI existente
  String get estadoTexto {
    // Usar estadoInscripcion si está disponible, sino usar estado de la actividad
    final estadoFinal = estadoInscripcion ?? estado;

    switch (estadoFinal) {
      case 0:
        return 'En curso';
      case 1:
        return 'Completado';
      case 2:
        return 'Esperando aprobación';
      default:
        return 'Desconocido';
    }
  }

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
    double? valorNumerico, // <-- Cambiado a double
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
}
