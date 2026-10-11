import 'package:ceyrsa_app/data/app_data.dart';

class AuthService {
  static Map<String, dynamic>? _usuarioActual;

  // =========================================================
  // USUARIO ACTUAL
  // =========================================================

  static Map<String, dynamic>? get usuarioActual =>
      _usuarioActual;

  // =========================================================
  // IDENTIFICADOR
  // =========================================================

  static String? get usuario =>
      _usuarioActual?['identificador']?.toString();

  // =========================================================
  // ROL
  // =========================================================

  static String? get rol =>
      _usuarioActual?['rol']?.toString();

  // =========================================================
  // ESTADO
  // =========================================================

  static String? get estado =>
      _usuarioActual?['estado']?.toString();

  // =========================================================
  // CÓDIGO DE ACCESO
  // =========================================================

  static String? get codigoAcceso =>
      _usuarioActual?['codigoAcceso']?.toString();

  // =========================================================
  // AUTENTICACIÓN
  // =========================================================

  static bool get estaAutenticado =>
      _usuarioActual != null;

  // =========================================================
  // INICIAR SESIÓN
  // =========================================================

  static bool iniciarSesion(String codigo) {
    final codigoLimpio = codigo.trim();

    if (!RegExp(r'^\d{5}$').hasMatch(codigoLimpio)) {
      return false;
    }

    final personal =
        AppData.buscarPersonalPorCodigoAcceso(
      codigoLimpio,
    );

    if (personal == null) {
      return false;
    }

    if (personal['acceso'] != true) {
      return false;
    }

    final estadoPersonal =
        personal['estado']
            ?.toString()
            .toLowerCase();

    if (estadoPersonal == 'baja') {
      return false;
    }

    _usuarioActual = personal;

    return true;
  }

  // =========================================================
  // CERRAR SESIÓN
  // =========================================================

  static void cerrarSesion() {
    _usuarioActual = null;
  }

  // =========================================================
  // COMPROBAR ROL
  // =========================================================

  static bool tieneRol(String rolBuscado) {
    return rol?.toLowerCase() ==
        rolBuscado.toLowerCase();
  }

  // =========================================================
  // COMPROBAR VARIOS ROLES
  // =========================================================

  static bool tieneAlgunoDeLosRoles(
    List<String> rolesBuscados,
  ) {
    if (rol == null) {
      return false;
    }

    return rolesBuscados.any(
      (r) =>
          r.toLowerCase() ==
          rol!.toLowerCase(),
    );
  }

  // =========================================================
  // ACTUALIZAR SESIÓN
  // =========================================================

  static void actualizarSesion(
    Map<String, dynamic> usuario,
  ) {
    _usuarioActual = usuario;
  }
}