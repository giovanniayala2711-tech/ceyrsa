// =========================================================
// CEYRSA — PERFILES Y PERMISOS
// =========================================================
enum UserRole {
  administrador,
  encargado,
  ayudante,
  medioLlanero,
  contador,
  contadora,
}

class Permission {
  final String id;
  final String nombre;
  final String descripcion;
  const Permission({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });
}

// =========================================================
// PERMISOS DEL SISTEMA
// =========================================================
class CeyrsaPermissions {
  static const bitacoraCrear = Permission(
    id: 'bitacora_crear',
    nombre: 'Crear bitácoras',
    descripcion: 'Crear y guardar nuevas bitácoras.',
  );
  static const bitacoraConsultar = Permission(
    id: 'bitacora_consultar',
    nombre: 'Consultar bitácoras',
    descripcion: 'Consultar bitácoras existentes.',
  );
  static const materialesRegistrar = Permission(
    id: 'materiales_registrar',
    nombre: 'Registrar materiales',
    descripcion: 'Registrar uso, recepción o solicitud de materiales.',
  );
  static const materialesSolicitar = Permission(
    id: 'materiales_solicitar',
    nombre: 'Solicitar materiales',
    descripcion: 'Solicitar materiales para una obra.',
  );
  static const herramientasRegistrar = Permission(
    id: 'herramientas_registrar',
    nombre: 'Registrar herramientas',
    descripcion: 'Registrar entrega, devolución o incidencia.',
  );
  static const evidenciasCrear = Permission(
    id: 'evidencias_crear',
    nombre: 'Crear evidencias',
    descripcion: 'Tomar y registrar fotografías de la obra.',
  );
  static const gastosRegistrar = Permission(
    id: 'gastos_registrar',
    nombre: 'Registrar gastos',
    descripcion: 'Registrar gastos y comprobantes.',
  );
  static const usuariosAdministrar = Permission(
    id: 'usuarios_administrar',
    nombre: 'Administrar usuarios',
    descripcion: 'Crear, editar y desactivar usuarios.',
  );
  static const cuadrillasAdministrar = Permission(
    id: 'cuadrillas_administrar',
    nombre: 'Administrar cuadrillas',
    descripcion: 'Crear y administrar cuadrillas.',
  );
  static const obrasAdministrar = Permission(
    id: 'obras_administrar',
    nombre: 'Administrar obras',
    descripcion: 'Crear y administrar obras.',
  );
  static const documentosConsultar = Permission(
    id: 'documentos_consultar',
    nombre: 'Consultar documentos',
    descripcion: 'Consultar documentos generados.',
  );
}

// =========================================================
// PERFIL DE USUARIO
// =========================================================
class UserProfile {
  final UserRole rol;
  final String nombre;
  final List<Permission> permisos;
  const UserProfile({
    required this.rol,
    required this.nombre,
    required this.permisos,
  });

  bool tienePermiso(Permission permiso) {
    return permisos.any((p) => p.id == permiso.id);
  }
}

// =========================================================
// PERFILES CEYRSA
// =========================================================
class Profiles {
  static UserProfile administrador(String nombre) {
    return UserProfile(
      rol: UserRole.administrador,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.bitacoraCrear,
        CeyrsaPermissions.bitacoraConsultar,
        CeyrsaPermissions.materialesRegistrar,
        CeyrsaPermissions.materialesSolicitar,
        CeyrsaPermissions.herramientasRegistrar,
        CeyrsaPermissions.evidenciasCrear,
        CeyrsaPermissions.gastosRegistrar,
        CeyrsaPermissions.usuariosAdministrar,
        CeyrsaPermissions.cuadrillasAdministrar,
        CeyrsaPermissions.obrasAdministrar,
        CeyrsaPermissions.documentosConsultar,
      ],
    );
  }

  static UserProfile encargado(String nombre) {
    return UserProfile(
      rol: UserRole.encargado,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.bitacoraCrear,
        CeyrsaPermissions.bitacoraConsultar,
        CeyrsaPermissions.materialesRegistrar,
        CeyrsaPermissions.materialesSolicitar,
        CeyrsaPermissions.herramientasRegistrar,
        CeyrsaPermissions.evidenciasCrear,
        CeyrsaPermissions.gastosRegistrar,
        CeyrsaPermissions.documentosConsultar,
      ],
    );
  }

  static UserProfile ayudante(String nombre) {
    return UserProfile(
      rol: UserRole.ayudante,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.bitacoraConsultar,
        CeyrsaPermissions.materialesRegistrar,
        CeyrsaPermissions.herramientasRegistrar,
        CeyrsaPermissions.evidenciasCrear,
      ],
    );
  }

  static UserProfile medioLlanero(String nombre) {
    return UserProfile(
      rol: UserRole.medioLlanero,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.bitacoraConsultar,
        CeyrsaPermissions.materialesRegistrar,
        CeyrsaPermissions.herramientasRegistrar,
        CeyrsaPermissions.evidenciasCrear,
      ],
    );
  }

  static UserProfile contador(String nombre) {
    return UserProfile(
      rol: UserRole.contador,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.gastosRegistrar,
        CeyrsaPermissions.documentosConsultar,
      ],
    );
  }

  static UserProfile contadora(String nombre) {
    return UserProfile(
      rol: UserRole.contadora,
      nombre: nombre,
      permisos: const [
        CeyrsaPermissions.gastosRegistrar,
        CeyrsaPermissions.documentosConsultar,
      ],
    );
  }
}