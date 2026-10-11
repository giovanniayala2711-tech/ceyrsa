import 'dart:math';

class AppData {
  // =========================================================
  // OBRAS
  // =========================================================

  static final List<Map<String, dynamic>> obras = [
    {
      'id': 'OBR-0001',
      'folio': '45872',
      'nombre': 'Industrial Park Norte',
      'cliente': 'Cliente Industrial',
      'ubicacion': 'Zona Industrial',
      'estado': 'Activa',
      'cuadrillaId': null,
      'encargadoId': 'USR-GA-0001',
      'cuadrilla': null,
      'encargado': 'Giovani Ayala',
      'gerente': null,
      'gerenteTerritorio': null,
    },
  ];

  // =========================================================
  // BITÁCORAS
  // =========================================================

  static final List<Map<String, dynamic>> bitacoras = [];

  // =========================================================
  // ASISTENCIAS
  // =========================================================

  static final List<Map<String, dynamic>> asistencias = [];

  // =========================================================
  // PERSONAL
  // =========================================================

  static final List<Map<String, dynamic>> personal = [
    // ADMINISTRADOR: acceso total.
    {
      'id': 'USR-AD-0001',
      'identificador': 'ADMINISTRADOR',
      'codigoAcceso': '58321',
      'nombre': 'Administrador',
      'foto': '',
      'telefono': '',
      'domicilio': '',
      'tipoSangre': '',
      'nss': '',
      'contactoEmergencia': '',
      'telefonoEmergencia': '',
      'rol': 'Administrador',
      'puesto': 'Administrador',
      'estado': 'Activo',
      'acceso': true,
      'cuadrillaId': null,
      'cuadrilla': null,
      'rotacion': <Map<String, dynamic>>[],
      'entregas': <Map<String, dynamic>>[],
      'incidencias': <Map<String, dynamic>>[],
    },

    // GIOVANI AYALA: ENCARGADO.
    {
      'id': 'USR-GA-0001',
      'identificador': 'GIOVANI.AYALA',
      'codigoAcceso': '61427',
      'nombre': 'Giovani Ayala',
      'foto': '',
      'telefono': '',
      'domicilio': '',
      'tipoSangre': '',
      'nss': '',
      'contactoEmergencia': '',
      'telefonoEmergencia': '',
      'rol': 'Encargado',
      'puesto': 'Instalador',
      'estado': 'Activo',
      'acceso': true,
      'cuadrillaId': null,
      'cuadrilla': null,
      'rotacion': <Map<String, dynamic>>[],
      'entregas': <Map<String, dynamic>>[],
      'incidencias': <Map<String, dynamic>>[],
    },
  ];

  // =========================================================
  // ASIGNACIONES DE PERSONAL
  // =========================================================

  static final List<Map<String, dynamic>> cuadrillas = [];

  // =========================================================
  // SIGUIENTE CÓDIGO DE ACCESO
  // =========================================================

  static String siguienteCodigoAcceso() {
    final random = Random();
    String codigo;

    do {
      codigo = (10000 + random.nextInt(90000)).toString();
    } while (
        personal.any(
          (persona) =>
              (persona['codigoAcceso'] ?? '').toString().trim() ==
              codigo,
        ));

    return codigo;
  }

  // =========================================================
  // GENERAR IDENTIFICADOR
  // =========================================================

  static String generarIdentificador(String nombre) {
    final limpio = nombre.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (limpio.isEmpty) {
      return '';
    }

    return limpio
        .split(' ')
        .map((parte) => parte.trim())
        .where((parte) => parte.isNotEmpty)
        .join('.')
        .toUpperCase();
  }

  // =========================================================
  // GENERAR IDENTIFICADOR ÚNICO
  // =========================================================

  static String generarIdentificadorUnico(String nombre) {
    final base = generarIdentificador(nombre);

    if (base.isEmpty) {
      return '';
    }

    String resultado = base;
    int contador = 2;

    while (
        personal.any(
          (persona) =>
              (persona['identificador'] ?? '')
                  .toString()
                  .toUpperCase() ==
              resultado.toUpperCase(),
        )) {
      resultado = '$base.$contador';
      contador++;
    }

    return resultado;
  }

  // =========================================================
  // SIGUIENTE ID DE USUARIO
  // =========================================================

  static String siguienteIdUsuario() {
    int mayor = 0;

    for (final persona in personal) {
      final id = (persona['id'] ?? '').toString();
      final match = RegExp(r'(\d+)$').firstMatch(id);

      if (match != null) {
        final numero = int.tryParse(match.group(1)!);

        if (numero != null && numero > mayor) {
          mayor = numero;
        }
      }
    }

    return 'USR-${(mayor + 1).toString().padLeft(4, '0')}';
  }

  // =========================================================
  // SIGUIENTE ID DE OBRA
  // =========================================================

  static String siguienteIdObra() {
    int mayor = 0;

    for (final obra in obras) {
      final id = (obra['id'] ?? '').toString();
      final match = RegExp(r'(\d+)$').firstMatch(id);

      if (match != null) {
        final numero = int.tryParse(match.group(1)!);

        if (numero != null && numero > mayor) {
          mayor = numero;
        }
      }
    }

    return 'OBR-${(mayor + 1).toString().padLeft(4, '0')}';
  }

  // =========================================================
  // SIGUIENTE ID DE ASIGNACIÓN
  // =========================================================

  static String siguienteIdCuadrilla() {
    int mayor = 0;

    for (final cuadrilla in cuadrillas) {
      final id = (cuadrilla['id'] ?? '').toString();
      final match = RegExp(r'(\d+)$').firstMatch(id);

      if (match != null) {
        final numero = int.tryParse(match.group(1)!);

        if (numero != null && numero > mayor) {
          mayor = numero;
        }
      }
    }

    return 'CUA-${(mayor + 1).toString().padLeft(4, '0')}';
  }

  // =========================================================
  // SIGUIENTE ID DE ASISTENCIA
  // =========================================================

  static String siguienteIdAsistencia() {
    int mayor = 0;

    for (final asistencia in asistencias) {
      final id = (asistencia['id'] ?? '').toString();
      final match = RegExp(r'(\d+)$').firstMatch(id);

      if (match != null) {
        final numero = int.tryParse(match.group(1)!);

        if (numero != null && numero > mayor) {
          mayor = numero;
        }
      }
    }

    return 'ASI-${(mayor + 1).toString().padLeft(4, '0')}';
  }

  // =========================================================
  // BUSCAR PERSONAL
  // =========================================================

  static Map<String, dynamic>? buscarPersonal(String referencia) {
    final ref = referencia.trim().toUpperCase();

    if (ref.isEmpty) {
      return null;
    }

    for (final persona in personal) {
      final id = (persona['id'] ?? '').toString().toUpperCase();
      final codigoAcceso =
          (persona['codigoAcceso'] ?? '').toString().toUpperCase();
      final identificador =
          (persona['identificador'] ?? '').toString().toUpperCase();

      if (id == ref ||
          codigoAcceso == ref ||
          identificador == ref) {
        return persona;
      }
    }

    return null;
  }

  // =========================================================
  // BUSCAR PERSONAL POR CÓDIGO DE ACCESO
  // =========================================================

  static Map<String, dynamic>? buscarPersonalPorCodigoAcceso(
    String codigo,
  ) {
    final ref = codigo.trim();

    if (ref.isEmpty) {
      return null;
    }

    for (final persona in personal) {
      final codigoAcceso =
          (persona['codigoAcceso'] ?? '').toString().trim();

      if (codigoAcceso == ref) {
        return persona;
      }
    }

    return null;
  }

  // =========================================================
  // BUSCAR PERSONAL POR ID
  // =========================================================

  static Map<String, dynamic>? buscarPersonalPorId(String id) {
    final ref = id.trim().toUpperCase();

    if (ref.isEmpty) {
      return null;
    }

    for (final persona in personal) {
      final personaId =
          (persona['id'] ?? '').toString().toUpperCase();

      if (personaId == ref) {
        return persona;
      }
    }

    return null;
  }

  // =========================================================
  // BUSCAR ASIGNACIÓN POR ID
  // =========================================================

  static Map<String, dynamic>? buscarCuadrillaPorId(String id) {
    final ref = id.trim().toUpperCase();

    if (ref.isEmpty) {
      return null;
    }

    for (final cuadrilla in cuadrillas) {
      final cuadrillaId =
          (cuadrilla['id'] ?? '').toString().toUpperCase();

      if (cuadrillaId == ref) {
        return cuadrilla;
      }
    }

    return null;
  }

  // =========================================================
  // BUSCAR OBRA
  // =========================================================

  static Map<String, dynamic>? buscarObraPorId(String id) {
    final ref = id.trim().toUpperCase();

    if (ref.isEmpty) {
      return null;
    }

    for (final obra in obras) {
      final obraId = (obra['id'] ?? '').toString().toUpperCase();

      if (obraId == ref) {
        return obra;
      }
    }

    return null;
  }

  // =========================================================
  // REFERENCIA ESTABLE DE PERSONA
  // =========================================================

  static String referenciaEstablePersona(
    Map<String, dynamic> persona,
  ) {
    final id = (persona['id'] ?? '').toString().trim();

    if (id.isNotEmpty) {
      return id;
    }

    return '';
  }
}