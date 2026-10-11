import 'package:flutter/material.dart';
import '../data/app_data.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _buscarController =
      TextEditingController();

  final List<Map<String, dynamic>> _personal = AppData.personal;

  // ═════════════════════════════════════════════════════════════
  // COLORES
  // ═════════════════════════════════════════════════════════════

  static const Color fondo = Color(0xFFF5F5F7);
  static const Color panel = Colors.white;
  static const Color borde = Color(0xFFE5E5EA);
  static const Color colorTexto = Color(0xFF1D1D1F);
  static const Color textoSecundario = Color(0xFF6E6E73);

  static const Color azul = Color(0xFF007AFF);
  static const Color verde = Color(0xFF34C759);
  static const Color naranja = Color(0xFFFF9500);
  static const Color rojo = Color(0xFFFF3B30);
  static const Color morado = Color(0xFFAF52DE);
  static const Color indigo = Color(0xFF5856D6);

  // ═════════════════════════════════════════════════════════════
  // ROLES
  // ═════════════════════════════════════════════════════════════

  final List<String> _roles = [
    'Encargado',
    'Ayudante',
    'Medio Instalador',
    'Instalador',
    'Contador/a',
  ];

  final List<String> _estados = [
    'Activo',
    'En obra',
    'Descanso',
    'Ausente',
    'Incapacidad',
    'Baja',
  ];

  @override
  void initState() {
    super.initState();
    _asegurarDatosUsuarios();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════════
  // NORMALIZACIÓN
  // ═════════════════════════════════════════════════════════════

  String _normalizarRol(String? rolActual) {
    final rol = rolActual?.trim() ?? '';

    switch (rol) {
      case 'Contador':
      case 'Contadora':
        return 'Contador/a';

      case 'Contador/a':
      case 'Encargado':
      case 'Ayudante':
      case 'Medio Instalador':
      case 'Instalador':
        return rol;

      case 'Administrador':
        return 'Encargado';

      default:
        return 'Ayudante';
    }
  }

  void _asegurarDatosUsuarios() {
    for (final persona in _personal) {
      if (persona['id'] == null ||
          persona['id'].toString().trim().isEmpty) {
        persona['id'] = AppData.siguienteIdUsuario();
      }

      if (persona['identificador'] == null ||
          persona['identificador'].toString().trim().isEmpty) {
        persona['identificador'] =
            AppData.generarIdentificador(
          persona['nombre']?.toString() ?? '',
        );
      }

      persona['rol'] =
          _normalizarRol(persona['rol']?.toString());

      persona['codigo'] ??= persona['id'];
      persona['acceso'] ??= false;

      final codigo =
          persona['codigoAcceso']?.toString().trim() ?? '';

      if (!RegExp(r'^\d{5}$').hasMatch(codigo)) {
        persona['codigoAcceso'] =
            AppData.siguienteCodigoAcceso();
      }

      persona['cuadrillaId'] ??= null;
      persona['cuadrilla'] ??= null;
      persona['rotacion'] ??= <Map<String, dynamic>>[];
      persona['entregas'] ??= <Map<String, dynamic>>[];
      persona['incidencias'] ??= <Map<String, dynamic>>[];
      persona['estado'] ??= 'Activo';
    }
  }

  // ═════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      child: Column(
        children: [
          _barraSuperior(),
          Expanded(
            child: _contenido(),
          ),
        ],
      ),
    );
  }

  Widget _barraSuperior() {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          bottom: BorderSide(
            color: borde,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_alt_outlined,
            size: 20,
            color: colorTexto,
          ),
          const SizedBox(width: 10),
          const Text(
            'Personal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorTexto,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.cloud_done_outlined,
                  size: 15,
                  color: verde,
                ),
                SizedBox(width: 6),
                Text(
                  'Sincronizado',
                  style: TextStyle(
                    fontSize: 11,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    return Column(
      children: [
        _encabezadoContenido(),
        Expanded(
          child: _vistaPersonal(),
        ),
      ],
    );
  }

  Widget _encabezadoContenido() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        28,
        24,
        28,
        16,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.7,
                    color: colorTexto,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Administración de usuarios y accesos de CEYRSA',
                  style: TextStyle(
                    fontSize: 14,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _crearPersona,
            icon: const Icon(
              Icons.add,
              size: 18,
            ),
            label: const Text(
              'Nuevo personal',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorTexto,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // LISTA
  // ═════════════════════════════════════════════════════════════

  Widget _vistaPersonal() {
    final busqueda =
        _buscarController.text.toLowerCase().trim();

    final personas = _personal.where((persona) {
      final nombre =
          persona['nombre']?.toString().toLowerCase() ?? '';

      final identificador =
          persona['identificador']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final codigo =
          persona['codigoAcceso']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final rol =
          persona['rol']?.toString().toLowerCase() ?? '';

      final estado =
          persona['estado']?.toString().toLowerCase() ?? '';

      return nombre.contains(busqueda) ||
          identificador.contains(busqueda) ||
          codigo.contains(busqueda) ||
          rol.contains(busqueda) ||
          estado.contains(busqueda);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: borde,
                    ),
                  ),
                  child: TextField(
                    controller: _buscarController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      color: colorTexto,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar personal...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: textoSecundario,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 19,
                        color: textoSecundario,
                      ),
                      suffixIcon:
                          _buscarController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _buscarController
                                          .clear();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    size: 17,
                                  ),
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 13,
                ),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color: borde,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      size: 17,
                      color: colorTexto,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Filtrar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorTexto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: _resumen(),
        ),
        const SizedBox(height: 17),
        Expanded(
          child: personas.isEmpty
              ? _estadoVacio(
                  icono: Icons.people_outline,
                  texto: _personal.isEmpty
                      ? 'No hay personal registrado'
                      : 'No se encontraron resultados',
                  botonTexto: _personal.isEmpty
                      ? 'Agregar personal'
                      : null,
                  onPressed: _personal.isEmpty
                      ? _crearPersona
                      : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    28,
                    0,
                    28,
                    28,
                  ),
                  itemCount: personas.length,
                  itemBuilder: (context, index) {
                    return _tarjetaPersona(
                      personas[index],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _resumen() {
    final activos = _personal
        .where((p) => p['estado'] == 'Activo')
        .length;

    final obra = _personal
        .where((p) => p['estado'] == 'En obra')
        .length;

    final acceso = _personal
        .where((p) => p['acceso'] == true)
        .length;

    return Row(
      children: [
        _tarjetaResumen(
          titulo: 'Personal',
          valor: _personal.length.toString(),
          icono: Icons.people_outline,
        ),
        const SizedBox(width: 12),
        _tarjetaResumen(
          titulo: 'Activos',
          valor: activos.toString(),
          icono: Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        _tarjetaResumen(
          titulo: 'En obra',
          valor: obra.toString(),
          icono: Icons.construction_outlined,
        ),
        const SizedBox(width: 12),
        _tarjetaResumen(
          titulo: 'Con acceso',
          valor: acceso.toString(),
          icono: Icons.lock_open_outlined,
        ),
      ],
    );
  }

  Widget _tarjetaResumen({
    required String titulo,
    required String valor,
    required IconData icono,
  }) {
    return Expanded(
      child: Container(
        height: 82,
        padding:
            const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: borde,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                size: 20,
                color: colorTexto,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorTexto,
                  ),
                ),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // TARJETA PERSONA
  // ═════════════════════════════════════════════════════════════

  Widget _tarjetaPersona(
    Map<String, dynamic> persona,
  ) {
    final nombre =
        persona['nombre']?.toString() ?? 'Sin nombre';

    final identificador =
        persona['identificador']?.toString() ??
            'Sin identificador';

    final codigo =
        persona['codigoAcceso']?.toString() ?? '-----';

    final rol =
        persona['rol']?.toString() ?? 'Sin rol';

    final estado =
        persona['estado']?.toString() ?? 'Sin estado';

    final acceso = persona['acceso'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borde,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _verPersona(persona),
          borderRadius:
              BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _avatarPersona(
                  nombre,
                  rol,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nombre,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w600,
                                color: colorTexto,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _chip(
                            identificador,
                            const Color(0xFFF2F2F7),
                            textoSecundario,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              rol,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color:
                                    textoSecundario,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Container(
                            width: 3,
                            height: 3,
                            decoration:
                                const BoxDecoration(
                              color:
                                  textoSecundario,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            'Código $codigo',
                            style: const TextStyle(
                              fontSize: 11,
                              color:
                                  textoSecundario,
                              fontFamily:
                                  'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          _estadoChip(estado),
                          const SizedBox(width: 6),
                          _estadoChip(
                            acceso
                                ? 'Acceso activo'
                                : 'Sin acceso',
                            color: acceso
                                ? verde
                                : textoSecundario,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Editar',
                  onPressed: () =>
                      _editarPersona(persona),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                    color: colorTexto,
                  ),
                ),
                IconButton(
                  tooltip: acceso
                      ? 'Deshabilitar acceso'
                      : 'Habilitar acceso',
                  onPressed: () =>
                      _cambiarAcceso(persona),
                  icon: Icon(
                    acceso
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                    size: 19,
                    color: acceso
                        ? verde
                        : textoSecundario,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: textoSecundario,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarPersona(
    String nombre,
    String rol,
  ) {
    Color color = azul;

    switch (rol) {
      case 'Encargado':
        color = morado;
        break;
      case 'Instalador':
        color = naranja;
        break;
      case 'Medio Instalador':
        color = indigo;
        break;
      case 'Ayudante':
        color = verde;
        break;
      case 'Contador/a':
        color = azul;
        break;
    }

    final limpio = nombre.trim();

    final inicial = limpio.isNotEmpty
        ? limpio.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _chip(
    String textoChip,
    Color fondoChip,
    Color colorChip,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: fondoChip,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        textoChip,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorChip,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _estadoChip(
    String textoChip, {
    Color? color,
  }) {
    final colorFinal =
        color ?? _colorEstado(textoChip);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorFinal.withOpacity(.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colorFinal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            textoChip,
            style: TextStyle(
              color: colorFinal,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Activo':
        return verde;
      case 'En obra':
        return azul;
      case 'Descanso':
        return naranja;
      case 'Incapacidad':
      case 'Baja':
        return rojo;
      case 'Ausente':
        return morado;
      default:
        return textoSecundario;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // CAMBIAR ACCESO
  // ═════════════════════════════════════════════════════════════

  void _cambiarAcceso(
    Map<String, dynamic> persona,
  ) {
    final actual = persona['acceso'] == true;
    final nuevo = !actual;

    showDialog(
      context: context,
      builder: (ctx) {
        return _ventanaMac(
          titulo: nuevo
              ? 'Habilitar acceso'
              : 'Deshabilitar acceso',
          subtitulo:
              'Administración de acceso al sistema',
          icono: nuevo
              ? Icons.lock_open_outlined
              : Icons.lock_outline,
          iconoColor: nuevo ? verde : rojo,
          ancho: 480,
          contenido: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              nuevo
                  ? '¿Deseas habilitar nuevamente el acceso de ${persona['nombre']}?'
                  : '¿Deseas deshabilitar el acceso de ${persona['nombre']}?',
              style: const TextStyle(
                fontSize: 14,
                color: textoSecundario,
                height: 1.5,
              ),
            ),
          ),
          acciones: [
            _botonSecundario(
              texto: 'Cancelar',
              onPressed: () =>
                  Navigator.pop(ctx),
            ),
            _botonPrincipal(
              texto:
                  nuevo ? 'Habilitar' : 'Deshabilitar',
              color: nuevo ? colorTexto : rojo,
              onPressed: () {
                setState(() {
                  persona['acceso'] = nuevo;
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CREAR PERSONA
  // ═════════════════════════════════════════════════════════════

  void _crearPersona() {
    final nombre = TextEditingController();
    final telefono = TextEditingController();
    final domicilio = TextEditingController();
    final sangre = TextEditingController();
    final nss = TextEditingController();
    final emergencia = TextEditingController();
    final telefonoEmergencia =
        TextEditingController();

    String rol = 'Medio Instalador';
    String estado = 'Activo';
    bool acceso = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuildContext, setDialogState) {
            final nombreActual =
                nombre.text.trim();

            final identificador =
                nombreActual.isEmpty
                    ? 'Se generará automáticamente'
                    : AppData.generarIdentificadorUnico(
                        nombreActual,
                      );

            return _ventanaMac(
              titulo: 'Nuevo personal',
              subtitulo:
                  'Registra un nuevo integrante de CEYRSA',
              icono: Icons.person_add_outlined,
              iconoColor: azul,
              ancho: 900,
              altoMaximo: 820,
              contenido: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  28,
                  24,
                  28,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _encabezadoIdentidad(
                      identificador,
                    ),

                    const SizedBox(height: 26),

                    _tituloSeccion(
                      'Información personal',
                      'Datos principales del trabajador',
                      Icons.person_outline,
                      azul,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _campoMac(
                            controller: nombre,
                            label: 'Nombre completo',
                            icon:
                                Icons.person_outline,
                            hint:
                                'Ej. Giovani Ayala',
                            onChanged: (_) {
                              setDialogState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: _campoMac(
                            controller: telefono,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            hint: 'Número telefónico',
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _campoMac(
                      controller: domicilio,
                      label: 'Domicilio',
                      icon: Icons.home_outlined,
                      hint:
                          'Domicilio completo del trabajador',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller: sangre,
                            label: 'Tipo de sangre',
                            icon:
                                Icons.bloodtype_outlined,
                            hint: 'Ej. O+',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _campoMac(
                            controller: nss,
                            label: 'NSS',
                            icon: Icons.badge_outlined,
                            hint:
                                'Número de seguridad social',
                            keyboardType:
                                TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ═══════════════════════════════
                    // ROL
                    // ═══════════════════════════════

                    _tituloSeccion(
                      'Rol del personal',
                      'Selecciona la función que desempeña dentro de CEYRSA',
                      Icons.work_outline,
                      morado,
                    ),

                    const SizedBox(height: 14),

                    _selectorRoles(
                      seleccionado: rol,
                      onSelected: (nuevoRol) {
                        setDialogState(() {
                          rol = nuevoRol;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ═══════════════════════════════
                    // ESTADO
                    // ═══════════════════════════════

                    _tituloSeccion(
                      'Estado actual',
                      'Indica la situación actual del trabajador',
                      Icons.radio_button_checked,
                      azul,
                    ),

                    const SizedBox(height: 14),

                    _selectorEstados(
                      seleccionado: estado,
                      onSelected: (nuevoEstado) {
                        setDialogState(() {
                          estado = nuevoEstado;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // ═══════════════════════════════
                    // EMERGENCIA
                    // ═══════════════════════════════

                    _tituloSeccion(
                      'Contacto de emergencia',
                      'Persona que deberá contactarse en caso de emergencia',
                      Icons.emergency_outlined,
                      naranja,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller: emergencia,
                            label:
                                'Nombre del contacto',
                            icon: Icons
                                .contact_phone_outlined,
                            hint:
                                'Nombre completo',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _campoMac(
                            controller:
                                telefonoEmergencia,
                            label:
                                'Teléfono de emergencia',
                            icon:
                                Icons.phone_outlined,
                            hint:
                                'Número telefónico',
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ═══════════════════════════════
                    // ACCESO
                    // ═══════════════════════════════

                    _tituloSeccion(
                      'Acceso a CEYRSA',
                      'Controla si este trabajador puede ingresar al sistema',
                      Icons.security_outlined,
                      verde,
                    ),

                    const SizedBox(height: 14),

                    _tarjetaAcceso(
                      acceso,
                      (value) {
                        setDialogState(() {
                          acceso = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              acciones: [
                _botonSecundario(
                  texto: 'Cancelar',
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                ),
                _botonPrincipal(
                  texto: 'Crear personal',
                  icono: Icons.check,
                  onPressed: () {
                    final nombreFinal =
                        nombre.text.trim();

                    if (nombreFinal.isEmpty) {
                      ScaffoldMessenger.of(
                        dialogBuildContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Escribe el nombre completo.',
                          ),
                        ),
                      );
                      return;
                    }

                    final identificadorFinal =
                        AppData
                            .generarIdentificadorUnico(
                      nombreFinal,
                    );

                    final id =
                        AppData.siguienteIdUsuario();

                    final codigoAcceso =
                        AppData.siguienteCodigoAcceso();

                    setState(() {
                      _personal.add({
                        'id': id,
                        'codigo': id,
                        'identificador':
                            identificadorFinal,
                        'codigoAcceso':
                            codigoAcceso,
                        'nombre': nombreFinal,
                        'telefono':
                            telefono.text.trim(),
                        'domicilio':
                            domicilio.text.trim(),
                        'tipoSangre':
                            sangre.text.trim(),
                        'nss':
                            nss.text.trim(),
                        'contactoEmergencia':
                            emergencia.text.trim(),
                        'telefonoEmergencia':
                            telefonoEmergencia.text
                                .trim(),
                        'rol': rol,
                        'estado': estado,
                        'acceso': acceso,
                        'cuadrillaId': null,
                        'cuadrilla': null,
                        'rotacion':
                            <Map<String, dynamic>>[],
                        'entregas':
                            <Map<String, dynamic>>[],
                        'incidencias':
                            <Map<String, dynamic>>[],
                      });
                    });

                    Navigator.pop(dialogContext);

                    _mostrarCodigoGenerado(
                      identificadorFinal,
                      codigoAcceso,
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // EDITAR PERSONA
  // ═════════════════════════════════════════════════════════════

  void _editarPersona(
    Map<String, dynamic> persona,
  ) {
    final nombre = TextEditingController(
      text: persona['nombre']?.toString() ?? '',
    );

    final telefono = TextEditingController(
      text: persona['telefono']?.toString() ?? '',
    );

    final domicilio = TextEditingController(
      text: persona['domicilio']?.toString() ?? '',
    );

    final sangre = TextEditingController(
      text: persona['tipoSangre']?.toString() ?? '',
    );

    final nss = TextEditingController(
      text: persona['nss']?.toString() ?? '',
    );

    final emergencia = TextEditingController(
      text:
          persona['contactoEmergencia']?.toString() ??
              '',
    );

    final telefonoEmergencia =
        TextEditingController(
      text:
          persona['telefonoEmergencia']
                  ?.toString() ??
              '',
    );

    String rol =
        _normalizarRol(persona['rol']?.toString());

    String estado =
        persona['estado']?.toString() ?? 'Activo';

    if (!_estados.contains(estado)) {
      estado = 'Activo';
    }

    bool acceso = persona['acceso'] == true;

    final identificador =
        persona['identificador']?.toString() ?? '';

    final codigo =
        persona['codigoAcceso']?.toString() ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogBuildContext, setDialogState) {
            return _ventanaMac(
              titulo: 'Editar personal',
              subtitulo:
                  'Actualiza la información del usuario',
              icono: Icons.person_outline,
              iconoColor: azul,
              ancho: 900,
              altoMaximo: 820,
              contenido: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  28,
                  24,
                  28,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _encabezadoIdentidadCompleto(
                      identificador,
                      codigo,
                    ),

                    const SizedBox(height: 26),

                    _tituloSeccion(
                      'Información personal',
                      'Datos principales del trabajador',
                      Icons.person_outline,
                      azul,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _campoMac(
                            controller: nombre,
                            label: 'Nombre completo',
                            icon:
                                Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: _campoMac(
                            controller: telefono,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _campoMac(
                      controller: domicilio,
                      label: 'Domicilio',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller: sangre,
                            label: 'Tipo de sangre',
                            icon:
                                Icons.bloodtype_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _campoMac(
                            controller: nss,
                            label: 'NSS',
                            icon: Icons.badge_outlined,
                            keyboardType:
                                TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ROL

                    _tituloSeccion(
                      'Rol del personal',
                      'Selecciona la función que desempeña dentro de CEYRSA',
                      Icons.work_outline,
                      morado,
                    ),

                    const SizedBox(height: 14),

                    _selectorRoles(
                      seleccionado: rol,
                      onSelected: (nuevoRol) {
                        setDialogState(() {
                          rol = nuevoRol;
                        });
                      },
                    ),

                    const SizedBox(height: 28),

                    // ESTADO

                    _tituloSeccion(
                      'Estado actual',
                      'Indica la situación actual del trabajador',
                      Icons.radio_button_checked,
                      azul,
                    ),

                    const SizedBox(height: 14),

                    _selectorEstados(
                      seleccionado: estado,
                      onSelected: (nuevoEstado) {
                        setDialogState(() {
                          estado = nuevoEstado;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // EMERGENCIA

                    _tituloSeccion(
                      'Contacto de emergencia',
                      'Información para situaciones de emergencia',
                      Icons.emergency_outlined,
                      naranja,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller: emergencia,
                            label:
                                'Nombre del contacto',
                            icon: Icons
                                .contact_phone_outlined,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _campoMac(
                            controller:
                                telefonoEmergencia,
                            label:
                                'Teléfono de emergencia',
                            icon:
                                Icons.phone_outlined,
                            keyboardType:
                                TextInputType.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // ACCESO

                    _tituloSeccion(
                      'Acceso a CEYRSA',
                      'Controla si este trabajador puede ingresar al sistema',
                      Icons.security_outlined,
                      verde,
                    ),

                    const SizedBox(height: 14),

                    _tarjetaAcceso(
                      acceso,
                      (value) {
                        setDialogState(() {
                          acceso = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              acciones: [
                _botonSecundario(
                  texto: 'Cancelar',
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                ),
                _botonPrincipal(
                  texto: 'Guardar cambios',
                  icono: Icons.save_outlined,
                  onPressed: () {
                    final nombreFinal =
                        nombre.text.trim();

                    if (nombreFinal.isEmpty) {
                      ScaffoldMessenger.of(
                        dialogBuildContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El nombre completo no puede quedar vacío.',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      persona['nombre'] =
                          nombreFinal;

                      persona['telefono'] =
                          telefono.text.trim();

                      persona['domicilio'] =
                          domicilio.text.trim();

                      persona['tipoSangre'] =
                          sangre.text.trim();

                      persona['nss'] =
                          nss.text.trim();

                      persona['rol'] = rol;

                      persona['estado'] = estado;

                      persona['acceso'] = acceso;

                      persona['contactoEmergencia'] =
                          emergencia.text.trim();

                      persona['telefonoEmergencia'] =
                          telefonoEmergencia.text
                              .trim();
                    });

                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SELECTOR DE ROLES
  // ═════════════════════════════════════════════════════════════

  Widget _selectorRoles({
    required String seleccionado,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _roles.map((rol) {
        final activo = rol == seleccionado;

        return _botonSeleccion(
          texto: rol,
          icono: _iconoRol(rol),
          color: _colorRol(rol),
          seleccionado: activo,
          onTap: () => onSelected(rol),
        );
      }).toList(),
    );
  }

  IconData _iconoRol(String rol) {
    switch (rol) {
      case 'Encargado':
        return Icons.manage_accounts_outlined;
      case 'Ayudante':
        return Icons.handyman_outlined;
      case 'Medio Instalador':
        return Icons.build_outlined;
      case 'Instalador':
        return Icons.construction_outlined;
      case 'Contador/a':
        return Icons.calculate_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'Encargado':
        return morado;
      case 'Ayudante':
        return verde;
      case 'Medio Instalador':
        return indigo;
      case 'Instalador':
        return naranja;
      case 'Contador/a':
        return azul;
      default:
        return colorTexto;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // SELECTOR DE ESTADOS
  // ═════════════════════════════════════════════════════════════

  Widget _selectorEstados({
    required String seleccionado,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _estados.map((estado) {
        final activo = estado == seleccionado;

        return _botonSeleccion(
          texto: estado,
          icono: _iconoEstado(estado),
          color: _colorEstado(estado),
          seleccionado: activo,
          onTap: () => onSelected(estado),
        );
      }).toList(),
    );
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'Activo':
        return Icons.check_circle_outline;
      case 'En obra':
        return Icons.construction_outlined;
      case 'Descanso':
        return Icons.free_breakfast_outlined;
      case 'Ausente':
        return Icons.person_off_outlined;
      case 'Incapacidad':
        return Icons.medical_services_outlined;
      case 'Baja':
        return Icons.block_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // BOTÓN DE SELECCIÓN
  // ═════════════════════════════════════════════════════════════

  Widget _botonSeleccion({
    required String texto,
    required IconData icono,
    required Color color,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: seleccionado
                ? color.withOpacity(.10)
                : const Color(0xFFF7F7F8),
            borderRadius:
                BorderRadius.circular(11),
            border: Border.all(
              color: seleccionado
                  ? color
                  : borde,
              width: seleccionado ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? color.withOpacity(.13)
                      : const Color(0xFFEFEFF1),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Icon(
                  icono,
                  size: 16,
                  color: seleccionado
                      ? color
                      : textoSecundario,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: seleccionado
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: seleccionado
                      ? color
                      : colorTexto,
                ),
              ),
              if (seleccionado) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // VENTANA MACOS
  // ═════════════════════════════════════════════════════════════

  Widget _ventanaMac({
    required String titulo,
    required String subtitulo,
    required Widget contenido,
    required List<Widget> acciones,
    IconData? icono,
    Color iconoColor = azul,
    double ancho = 850,
    double? altoMaximo,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ancho,
          maxHeight:
              altoMaximo ?? 760,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD9D9DE),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.18),
                blurRadius: 45,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color:
                    Colors.black.withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 76,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFFBFBFC),
                  border: Border(
                    bottom: BorderSide(
                      color: borde,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        _puntoVentana(
                          const Color(0xFFFF5F57),
                        ),
                        const SizedBox(width: 7),
                        _puntoVentana(
                          const Color(0xFFFFBD2E),
                        ),
                        const SizedBox(width: 7),
                        _puntoVentana(
                          const Color(0xFF28C840),
                        ),
                      ],
                    ),
                    const SizedBox(width: 22),
                    if (icono != null) ...[
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: iconoColor
                              .withOpacity(.10),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icono,
                          size: 20,
                          color: iconoColor,
                        ),
                      ),
                      const SizedBox(width: 11),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w700,
                              color: colorTexto,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitulo,
                            style:
                                const TextStyle(
                              fontSize: 11,
                              color:
                                  textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        size: 19,
                      ),
                      style: IconButton.styleFrom(
                        foregroundColor:
                            textoSecundario,
                        hoverColor:
                            const Color(0xFFEFEFF2),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: contenido,
              ),

              Container(
                height: 72,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFFBFBFC),
                  border: Border(
                    top: BorderSide(
                      color: borde,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: acciones,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _puntoVentana(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // SECCIONES
  // ═════════════════════════════════════════════════════════════

  Widget _tituloSeccion(
    String titulo,
    String subtitulo,
    IconData icono,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(.09),
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icono,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorTexto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 10,
                  color: textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _encabezadoIdentidad(
    String identificador,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3F7FF),
            Color(0xFFF8FAFF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: azul.withOpacity(.13),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: azul.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: azul,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'IDENTIFICADOR DEL USUARIO',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: textoSecundario,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  identificador,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Se genera automáticamente al crear el usuario.',
                  style: TextStyle(
                    fontSize: 10,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _encabezadoIdentidadCompleto(
    String identificador,
    String codigo,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: borde,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _datoIdentidad(
              'IDENTIFICADOR',
              identificador,
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: borde,
          ),
          const SizedBox(width: 22),
          Expanded(
            child: _datoIdentidad(
              'CÓDIGO DE ACCESO',
              codigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _datoIdentidad(
    String titulo,
    String valor,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: textoSecundario,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            color: colorTexto,
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════
  // CAMPOS
  // ═════════════════════════════════════════════════════════════

  Widget _campoMac({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 13,
        color: colorTexto,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: textoSecundario,
        ),
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9A9AA0),
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: textoSecundario,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F8),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borde,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: azul,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ACCESO
  // ═════════════════════════════════════════════════════════════

  Widget _tarjetaAcceso(
    bool acceso,
    ValueChanged<bool> onChanged,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!acceso),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: acceso
                ? const Color(0xFFF2FBF5)
                : const Color(0xFFF7F7F8),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: acceso
                  ? verde.withOpacity(.30)
                  : borde,
              width: acceso ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: acceso
                      ? verde.withOpacity(.11)
                      : const Color(0xFFEFEFF1),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  acceso
                      ? Icons.lock_open_outlined
                      : Icons.lock_outline,
                  size: 21,
                  color: acceso
                      ? verde
                      : textoSecundario,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      acceso
                          ? 'Acceso habilitado'
                          : 'Acceso deshabilitado',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                        color: colorTexto,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      acceso
                          ? 'El usuario podrá ingresar a CEYRSA.'
                          : 'El usuario será registrado sin acceso al sistema.',
                      style: const TextStyle(
                        fontSize: 10,
                        color: textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: acceso,
                activeColor: verde,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // BOTONES
  // ═════════════════════════════════════════════════════════════

  Widget _botonSecundario({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorTexto,
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: borde,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(9),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _botonPrincipal({
    required String texto,
    required VoidCallback onPressed,
    Color color = colorTexto,
    IconData? icono,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icono == null
          ? const SizedBox.shrink()
          : Icon(
              icono,
              size: 17,
            ),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(9),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // USUARIO CREADO
  // ═════════════════════════════════════════════════════════════

  void _mostrarCodigoGenerado(
    String identificador,
    String codigo,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return _ventanaMac(
          titulo: 'Usuario creado',
          subtitulo:
              'El registro se creó correctamente',
          icono: Icons.check_circle_outline,
          iconoColor: verde,
          ancho: 520,
          contenido: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos de acceso',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                    color: colorTexto,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Guarda estos datos para identificar al usuario dentro de CEYRSA.',
                  style: TextStyle(
                    fontSize: 12,
                    color: textoSecundario,
                  ),
                ),
                const SizedBox(height: 18),
                _encabezadoIdentidadCompleto(
                  identificador,
                  codigo,
                ),
              ],
            ),
          ),
          acciones: [
            _botonPrincipal(
              texto: 'Listo',
              onPressed: () =>
                  Navigator.pop(ctx),
            ),
          ],
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════
  // DETALLE
  // ═════════════════════════════════════════════════════════════

  void _verPersona(
    Map<String, dynamic> persona,
  ) {
    final nombre =
        persona['nombre']?.toString() ??
            'Detalles';

    final rol =
        persona['rol']?.toString() ?? '';

    final acceso =
        persona['acceso'] == true;

    showDialog(
      context: context,
      builder: (ctx) {
        return _ventanaMac(
          titulo: nombre,
          subtitulo:
              'Información del usuario',
          icono: Icons.person_outline,
          iconoColor: azul,
          ancho: 620,
          contenido: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Row(
                  children: [
                    _avatarPersona(
                      nombre,
                      rol,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            rol,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  colorTexto,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _estadoChip(
                                persona['estado']
                                        ?.toString() ??
                                    'Sin estado',
                              ),
                              const SizedBox(width: 6),
                              _estadoChip(
                                acceso
                                    ? 'Acceso activo'
                                    : 'Sin acceso',
                                color: acceso
                                    ? verde
                                    : textoSecundario,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFF7F7F8),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _filaDato(
                        'Identificador',
                        persona['identificador']
                                ?.toString() ??
                            '',
                      ),
                      _filaDato(
                        'Código de acceso',
                        persona['codigoAcceso']
                                ?.toString() ??
                            '',
                      ),
                      _filaDato(
                        'Estado',
                        persona['estado']
                                ?.toString() ??
                            '',
                      ),
                      _filaDato(
                        'Teléfono',
                        persona['telefono']
                                ?.toString() ??
                            'No registrado',
                      ),
                      _filaDato(
                        'Domicilio',
                        persona['domicilio']
                                ?.toString() ??
                            'No registrado',
                      ),
                      _filaDato(
                        'Tipo de sangre',
                        persona['tipoSangre']
                                ?.toString() ??
                            'No registrado',
                      ),
                      _filaDato(
                        'NSS',
                        persona['nss']
                                ?.toString() ??
                            'No registrado',
                      ),
                      _filaDato(
                        'Contacto emergencia',
                        persona[
                                    'contactoEmergencia']
                                ?.toString() ??
                            'No registrado',
                      ),
                      _filaDato(
                        'Teléfono emergencia',
                        persona[
                                    'telefonoEmergencia']
                                ?.toString() ??
                            'No registrado',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          acciones: [
            _botonSecundario(
              texto: 'Cerrar',
              onPressed: () =>
                  Navigator.pop(ctx),
            ),
            _botonPrincipal(
              texto: 'Editar',
              icono: Icons.edit_outlined,
              onPressed: () {
                Navigator.pop(ctx);
                _editarPersona(persona);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _filaDato(
    String etiqueta,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 155,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: textoSecundario,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
                color: colorTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ESTADO VACÍO
  // ═════════════════════════════════════════════════════════════

  Widget _estadoVacio({
    required IconData icono,
    required String texto,
    String? botonTexto,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEFEFF1),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              icono,
              size: 32,
              color: textoSecundario,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 14,
            ),
          ),
          if (botonTexto != null) ...[
            const SizedBox(height: 17),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(
                Icons.add,
                size: 17,
              ),
              label: Text(botonTexto),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    colorTexto,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}