
import 'package:flutter/material.dart';
import '../data/app_data.dart';

class BitacorasScreen extends StatefulWidget {
  final Map<String, dynamic> obra;

  const BitacorasScreen({
    super.key,
    required this.obra,
  });

  @override
  State<BitacorasScreen> createState() => _BitacorasScreenState();
}

class _BitacorasScreenState extends State<BitacorasScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _proyecto;
  late final TextEditingController _folio;
  late final TextEditingController _gerente;
  late final TextEditingController _cliente;
  late final TextEditingController _ubicacion;
  late final TextEditingController _instalador;
  late final TextEditingController _fecha;
  late final TextEditingController _personas;
  late final TextEditingController _contacto;
  late final TextEditingController _adicionales;

  late final TextEditingController _temperaturaArea;
  late final TextEditingController _presionOsmotica;
  late final TextEditingController _electricidad;
  late final TextEditingController _tipoContaminacion;
  late final TextEditingController _temperaturaPiso;

  late final TextEditingController _observaciones;
  late final TextEditingController _firmaGerente;
  late final TextEditingController _firmaSupervisor;

  bool? _trabajosOriginales;
  bool? _ventilacion;
  String? _condicionSubstrato;
  bool? _contaminacionSubstrato;
  bool? _obstaculosRetirados;

  final Set<String> _areas = {};
  final Set<String> _iluminacion = {};

  DateTime? _fechaSeleccionada;

  final List<Map<String, String>> _alcances = [];
  final List<Map<String, String>> _productos = [];
  final List<Map<String, String>> _personal = [];

  // =========================================================
  // REFERENCIAS RESUELTAS
  //
  // Estas referencias corresponden a la relación real:
  //
  // OBRA
  //   ↓
  // CUADRILLA
  //   ↓
  // PERSONAL
  //
  // Se conservan para guardar la bitácora correctamente.
  // =========================================================

  Map<String, dynamic>? _cuadrillaResuelta;
  Map<String, dynamic>? _encargadoResuelto;

  @override
  void initState() {
    super.initState();

    final obra = widget.obra;

    _proyecto = TextEditingController(
      text: (obra['nombre'] ?? '').toString(),
    );

    _folio = TextEditingController(
      text: (obra['folio'] ?? '').toString(),
    );

    // ---------------------------------------------------------
    // EL GERENTE ES INDEPENDIENTE DEL ENCARGADO.
    // ---------------------------------------------------------

    _gerente = TextEditingController(
      text: (
        obra['gerenteTerritorio'] ??
        obra['gerente'] ??
        ''
      ).toString(),
    );

    _cliente = TextEditingController(
      text: (obra['cliente'] ?? '').toString(),
    );

    _ubicacion = TextEditingController(
      text: (obra['ubicacion'] ?? '').toString(),
    );

    _instalador = TextEditingController();

    _fecha = TextEditingController();

    _personas = TextEditingController();

    _contacto = TextEditingController();

    _adicionales = TextEditingController();

    _temperaturaArea = TextEditingController();

    _presionOsmotica = TextEditingController();

    _electricidad = TextEditingController();

    _tipoContaminacion = TextEditingController();

    _temperaturaPiso = TextEditingController();

    _observaciones = TextEditingController();

    _firmaGerente = TextEditingController(
      text: (
        obra['gerenteTerritorio'] ??
        obra['gerente'] ??
        ''
      ).toString(),
    );

    _firmaSupervisor = TextEditingController();

    _crearRenglonesIniciales();

    // ---------------------------------------------------------
    // AUTORRELLENADO DE PERSONAL
    // ---------------------------------------------------------

    _cargarPersonalDeLaObra();
  }

  // =========================================================
  // UTILIDADES DE COMPARACIÓN
  // =========================================================

  String _valor(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  bool _igualTexto(dynamic a, dynamic b) {
    final valorA = _valor(a);
    final valorB = _valor(b);

    if (valorA.isEmpty || valorB.isEmpty) {
      return false;
    }

    return valorA.toLowerCase() == valorB.toLowerCase();
  }

  // =========================================================
  // BUSCAR PERSONA
  //
  // Primero se utiliza ID/código.
  // El nombre solamente se utiliza como compatibilidad.
  // =========================================================

  Map<String, dynamic>? _buscarPersona({
    dynamic id,
    dynamic codigo,
    dynamic nombre,
  }) {
    final idBuscado = _valor(id);
    final codigoBuscado = _valor(codigo);
    final nombreBuscado = _valor(nombre);

    // ---------------------------------------------------------
    // 1. ID
    // ---------------------------------------------------------

    if (idBuscado.isNotEmpty) {
      for (final persona in AppData.personal) {
        if (_igualTexto(persona['id'], idBuscado)) {
          return persona;
        }
      }
    }

    // ---------------------------------------------------------
    // 2. CÓDIGO
    // ---------------------------------------------------------

    if (codigoBuscado.isNotEmpty) {
      for (final persona in AppData.personal) {
        if (_igualTexto(persona['codigo'], codigoBuscado)) {
          return persona;
        }
      }
    }

    // ---------------------------------------------------------
    // 3. NOMBRE
    // ---------------------------------------------------------

    if (nombreBuscado.isNotEmpty) {
      for (final persona in AppData.personal) {
        if (_igualTexto(persona['nombre'], nombreBuscado)) {
          return persona;
        }
      }
    }

    return null;
  }

  // =========================================================
  // BUSCAR CUADRILLA
  // =========================================================

  Map<String, dynamic>? _buscarCuadrilla({
    dynamic id,
    dynamic nombre,
    dynamic codigo,
  }) {
    final idBuscado = _valor(id);
    final nombreBuscado = _valor(nombre);
    final codigoBuscado = _valor(codigo);

    // ---------------------------------------------------------
    // 1. ID
    // ---------------------------------------------------------

    if (idBuscado.isNotEmpty) {
      for (final cuadrilla in AppData.cuadrillas) {
        if (_igualTexto(cuadrilla['id'], idBuscado)) {
          return cuadrilla;
        }
      }
    }

    // ---------------------------------------------------------
    // 2. CÓDIGO
    // ---------------------------------------------------------

    if (codigoBuscado.isNotEmpty) {
      for (final cuadrilla in AppData.cuadrillas) {
        if (_igualTexto(cuadrilla['codigo'], codigoBuscado)) {
          return cuadrilla;
        }
      }
    }

    // ---------------------------------------------------------
    // 3. NOMBRE
    // ---------------------------------------------------------

    if (nombreBuscado.isNotEmpty) {
      for (final cuadrilla in AppData.cuadrillas) {
        if (_igualTexto(cuadrilla['nombre'], nombreBuscado)) {
          return cuadrilla;
        }
      }
    }

    return null;
  }

  // =========================================================
  // OBTENER ID ESTABLE DE UNA PERSONA
  // =========================================================

  String _idPersona(Map<String, dynamic> persona) {
    final id = _valor(persona['id']);

    if (id.isNotEmpty) {
      return id;
    }

    return _valor(persona['codigo']);
  }

  // =========================================================
  // CREAR RENGLONES INICIALES
  // =========================================================

  void _crearRenglonesIniciales() {
    for (int i = 0; i < 4; i++) {
      _alcances.add({
        'area': '',
        'medida': '',
        'producto': '',
        'cajasBolsa': '',
        'descripcion': '',
      });
    }

    for (int i = 0; i < 4; i++) {
      _productos.add({
        'lote': '',
        'numeroProducto': '',
        'nombreProducto': '',
        'cantidad': '',
        'rendimiento': '',
        'comentarios': '',
      });
    }

    // Si no encontramos cuadrilla, se mantienen estos 5.
    for (int i = 0; i < 5; i++) {
      _personal.add({
        'id': '',
        'nombre': '',
        'puesto': '',
        'nss': '',
      });
    }
  }

  // =========================================================
  // AUTORRELLENAR PERSONAL
  //
  // OBRA
  //   ↓
  // ENCARGADO
  //   ↓
  // CUADRILLA
  //   ↓
  // INTEGRANTES
  //
  // IMPORTANTE:
  // Esta función solamente COPIA las personas a la bitácora.
  //
  // NO elimina ni modifica integrantes de la cuadrilla.
  // =========================================================

  void _cargarPersonalDeLaObra() {
    final obra = widget.obra;

    Map<String, dynamic>? encargado;
    Map<String, dynamic>? cuadrilla;

    // =======================================================
    // 1. RESOLVER ENCARGADO DE LA OBRA
    // =======================================================

    encargado = _buscarPersona(
      id: obra['encargadoId'],
      nombre: obra['encargado'],
    );

    // =======================================================
    // 2. RESOLVER CUADRILLA POR ID DIRECTO DE LA OBRA
    // =======================================================

    cuadrilla = _buscarCuadrilla(
      id: obra['cuadrillaId'],
    );

    // =======================================================
    // 3. COMPATIBILIDAD CON obra['cuadrilla']
    // =======================================================

    if (cuadrilla == null) {
      final valorCuadrilla = obra['cuadrilla'];

      if (valorCuadrilla is Map) {
        cuadrilla = _buscarCuadrilla(
          id: valorCuadrilla['id'],
          codigo: valorCuadrilla['codigo'],
          nombre: valorCuadrilla['nombre'],
        );
      } else {
        cuadrilla = _buscarCuadrilla(
          nombre: valorCuadrilla,
        );
      }
    }

    // =======================================================
    // 4. SI NO HAY CUADRILLA, BUSCARLA POR EL ENCARGADO
    // =======================================================

    if (cuadrilla == null && encargado != null) {
      final encargadoId = _idPersona(encargado);
      final encargadoNombre = _valor(encargado['nombre']);

      for (final item in AppData.cuadrillas) {
        final itemEncargadoId =
            _valor(item['encargadoId']);

        final itemEncargado =
            _valor(item['encargado']);

        if (
          (encargadoId.isNotEmpty &&
              _igualTexto(
                itemEncargadoId,
                encargadoId,
              )) ||
          (encargadoNombre.isNotEmpty &&
              _igualTexto(
                itemEncargado,
                encargadoNombre,
              ))
        ) {
          cuadrilla = item;
          break;
        }
      }
    }

    // =======================================================
    // 5. SEGUNDA BÚSQUEDA POR INTEGRANTES
    //
    // Por si la cuadrilla tiene integrantes pero no tiene
    // correctamente guardado encargadoId.
    // =======================================================

    if (cuadrilla == null && encargado != null) {
      final encargadoId = _idPersona(encargado);
      final encargadoCodigo = _valor(encargado['codigo']);
      final encargadoNombre = _valor(encargado['nombre']);

      for (final item in AppData.cuadrillas) {
        final integrantes = item['integrantes'];

        if (integrantes is! List) {
          continue;
        }

        bool encontrado = false;

        for (final integrante in integrantes) {
          if (integrante is! Map) {
            continue;
          }

          final integranteId =
              _valor(integrante['id']);

          final integranteCodigo =
              _valor(integrante['codigo']);

          final integranteNombre =
              _valor(integrante['nombre']);

          if (
            (encargadoId.isNotEmpty &&
                _igualTexto(
                  integranteId,
                  encargadoId,
                )) ||
            (encargadoCodigo.isNotEmpty &&
                _igualTexto(
                  integranteCodigo,
                  encargadoCodigo,
                )) ||
            (encargadoNombre.isNotEmpty &&
                _igualTexto(
                  integranteNombre,
                  encargadoNombre,
                ))
          ) {
            encontrado = true;
            break;
          }
        }

        if (encontrado) {
          cuadrilla = item;
          break;
        }
      }
    }

    // =======================================================
    // GUARDAR REFERENCIAS RESUELTAS
    // =======================================================

    _cuadrillaResuelta = cuadrilla;
    _encargadoResuelto = encargado;

    // =======================================================
    // SI NO HAY CUADRILLA, DEJAR LOS 5 RENGLONES VACÍOS
    // =======================================================

    if (cuadrilla == null) {
      return;
    }

    final nuevos = <Map<String, String>>[];

    // =======================================================
    // FUNCIÓN LOCAL PARA EVITAR DUPLICADOS
    // =======================================================

    bool yaExiste(
      String id,
      String nombre,
    ) {
      return nuevos.any((persona) {
        final idExistente =
            _valor(persona['id']);

        final nombreExistente =
            _valor(persona['nombre']);

        if (
          id.isNotEmpty &&
          idExistente.isNotEmpty &&
          _igualTexto(
            idExistente,
            id,
          )
        ) {
          return true;
        }

        if (
          nombre.isNotEmpty &&
          nombreExistente.isNotEmpty &&
          _igualTexto(
            nombreExistente,
            nombre,
          )
        ) {
          return true;
        }

        return false;
      });
    }

    // =======================================================
    // 6. CARGAR INTEGRANTES DE LA CUADRILLA
    // =======================================================

    final integrantes = cuadrilla['integrantes'];

    if (integrantes is List) {
      for (final integrante in integrantes) {
        if (integrante is! Map) {
          continue;
        }

        final integranteId =
            _valor(integrante['id']);

        final integranteCodigo =
            _valor(integrante['codigo']);

        final integranteNombre =
            _valor(integrante['nombre']);

        final integranteRol =
            _valor(
              integrante['rol'] ??
              integrante['puesto'],
            );

        final integranteNss =
            _valor(integrante['nss']);

        // -----------------------------------------------------
        // Buscar la persona real en AppData.personal
        // -----------------------------------------------------

        final personaActual = _buscarPersona(
          id: integranteId,
          codigo: integranteCodigo,
          nombre: integranteNombre,
        );

        if (personaActual != null) {
          final id =
              _idPersona(personaActual);

          final nombre =
              _valor(
                personaActual['nombre'],
              );

          final puesto =
              _valor(
                personaActual['rol'] ??
                integranteRol,
              );

          final nss =
              _valor(
                personaActual['nss'] ??
                integranteNss,
              );

          if (!yaExiste(id, nombre)) {
            nuevos.add({
              'id': id,
              'nombre': nombre,
              'puesto': puesto,
              'nss': nss,
            });
          }
        } else {
          final id = integranteId.isNotEmpty
              ? integranteId
              : integranteCodigo;

          if (!yaExiste(id, integranteNombre)) {
            nuevos.add({
              'id': id,
              'nombre': integranteNombre,
              'puesto': integranteRol,
              'nss': integranteNss,
            });
          }
        }
      }
    }

    // =======================================================
    // 7. RESOLVER ENCARGADO
    //
    // Primero obra.
    // Si no existe, usamos el encargado guardado
    // directamente en la cuadrilla.
    // =======================================================

    if (encargado == null) {
      encargado = _buscarPersona(
        id: cuadrilla['encargadoId'],
        nombre: cuadrilla['encargado'],
      );

      _encargadoResuelto = encargado;
    }

    // =======================================================
    // 8. ASEGURAR QUE EL ENCARGADO ESTÉ EN LA BITÁCORA
    // =======================================================

    if (encargado != null) {
      final idEncargado =
          _idPersona(encargado);

      final nombreEncargado =
          _valor(encargado['nombre']);

      final puestoEncargado =
          _valor(
            encargado['rol'],
          );

      final nssEncargado =
          _valor(
            encargado['nss'],
          );

      if (!yaExiste(
        idEncargado,
        nombreEncargado,
      )) {
        nuevos.insert(0, {
          'id': idEncargado,
          'nombre': nombreEncargado,
          'puesto': puestoEncargado.isNotEmpty
              ? puestoEncargado
              : 'Encargado',
          'nss': nssEncargado,
        });
      }
    }

    // =======================================================
    // 9. SI ENCONTRAMOS PERSONAL, REEMPLAZAR LOS RENGLONES
    //    VACÍOS
    // =======================================================

    if (nuevos.isNotEmpty) {
      _personal
        ..clear()
        ..addAll(nuevos);

      _personas.text =
          nuevos.length.toString();

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _proyecto.dispose();
    _folio.dispose();
    _gerente.dispose();
    _cliente.dispose();
    _ubicacion.dispose();
    _instalador.dispose();
    _fecha.dispose();
    _personas.dispose();
    _contacto.dispose();
    _adicionales.dispose();

    _temperaturaArea.dispose();
    _presionOsmotica.dispose();
    _electricidad.dispose();
    _tipoContaminacion.dispose();
    _temperaturaPiso.dispose();

    _observaciones.dispose();
    _firmaGerente.dispose();
    _firmaSupervisor.dispose();

    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate:
          _fechaSeleccionada ?? ahora,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha == null) return;

    setState(() {
      _fechaSeleccionada = fecha;
      _fecha.text =
          _formatearFecha(fecha);
    });
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  void _agregarAlcance() {
    setState(() {
      _alcances.add({
        'area': '',
        'medida': '',
        'producto': '',
        'cajasBolsa': '',
        'descripcion': '',
      });
    });
  }

  void _agregarProducto() {
    setState(() {
      _productos.add({
        'lote': '',
        'numeroProducto': '',
        'nombreProducto': '',
        'cantidad': '',
        'rendimiento': '',
        'comentarios': '',
      });
    });
  }

  void _agregarPersonal() {
    setState(() {
      _personal.add({
        'id': '',
        'nombre': '',
        'puesto': '',
        'nss': '',
      });

      _personas.text =
          _personal.length.toString();
    });
  }

  void _eliminarAlcance(int index) {
    if (_alcances.length <= 1) return;

    setState(() {
      _alcances.removeAt(index);
    });
  }

  void _eliminarProducto(int index) {
    if (_productos.length <= 1) return;

    setState(() {
      _productos.removeAt(index);
    });
  }

  void _eliminarPersonal(int index) {
    if (_personal.length <= 1) return;

    setState(() {
      // =======================================================
      // SOLO SE ELIMINA DE ESTA BITÁCORA.
      //
      // NO SE MODIFICA:
      // - AppData.personal
      // - AppData.cuadrillas
      // - integrantes
      // - cuadrillaId
      // - usuario
      // =======================================================

      _personal.removeAt(index);

      _personas.text =
          _personal.length.toString();
    });
  }

  // =========================================================
  // GUARDAR BITÁCORA
  // =========================================================

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fecha.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona la fecha de la bitácora.',
          ),
        ),
      );

      return;
    }

    final encargadoId =
        _encargadoResuelto != null
            ? _idPersona(
                _encargadoResuelto!,
              )
            : _valor(
                widget.obra['encargadoId'],
              );

    final cuadrillaId =
        _cuadrillaResuelta != null
            ? _valor(
                _cuadrillaResuelta!['id'],
              )
            : _valor(
                widget.obra['cuadrillaId'],
              );

    final datos =
        <String, dynamic>{
      // -------------------------------------------------------
      // IDENTIDAD DE LA OBRA
      // -------------------------------------------------------

      'obraId':
          _valor(widget.obra['id']),

      'obraFolio':
          _folio.text.trim(),

      'proyecto':
          _proyecto.text.trim(),

      'folio':
          _folio.text.trim(),

      'numeroObra':
          _folio.text.trim(),

      // -------------------------------------------------------
      // GERENTE
      // -------------------------------------------------------

      'gerenteTerritorio':
          _gerente.text.trim(),

      // -------------------------------------------------------
      // RELACIONES
      // -------------------------------------------------------

      'encargadoId':
          encargadoId,

      'cuadrillaId':
          cuadrillaId,

      'encargado':
          _encargadoResuelto != null
              ? _valor(
                  _encargadoResuelto![
                    'nombre'
                  ],
                )
              : _valor(
                  widget.obra['encargado'],
                ),

      // -------------------------------------------------------
      // DATOS GENERALES
      // -------------------------------------------------------

      'cliente':
          _cliente.text.trim(),

      'ubicacion':
          _ubicacion.text.trim(),

      'instalador':
          _instalador.text.trim(),

      'fecha':
          _fecha.text.trim(),

      'numeroPersonas':
          _personas.text.trim(),

      'contacto':
          _contacto.text.trim(),

      'trabajosOriginales':
          _trabajosOriginales,

      'adicionales':
          _adicionales.text.trim(),

      // -------------------------------------------------------
      // RIESGO
      // -------------------------------------------------------

      'temperaturaArea':
          _temperaturaArea.text.trim(),

      'ventilacion':
          _ventilacion,

      'afectaPresionOsmotica':
          _presionOsmotica.text.trim(),

      'condicionSubstrato':
          _condicionSubstrato,

      'electricidadDisponible':
          _electricidad.text.trim(),

      'contaminacionSubstrato':
          _contaminacionSubstrato,

      'tipoContaminacion':
          _tipoContaminacion.text.trim(),

      'temperaturaPiso':
          _temperaturaPiso.text.trim(),

      'areas':
          _areas.toList(),

      'iluminacion':
          _iluminacion.toList(),

      'obstaculosRetirados':
          _obstaculosRetirados,

      // -------------------------------------------------------
      // ALCANCE / PRODUCTOS
      // -------------------------------------------------------

      'alcances':
          _copiarFilas(_alcances),

      'productos':
          _copiarFilas(_productos),

      // -------------------------------------------------------
      // PERSONAL DE ESTE DÍA
      //
      // Aquí se guarda una COPIA de las personas.
      //
      // El ID permite saber exactamente quién trabajó ese día.
      // -------------------------------------------------------

      'personal':
          _copiarFilas(_personal),

      // -------------------------------------------------------
      // OBSERVACIONES / FIRMAS
      // -------------------------------------------------------

      'observaciones':
          _observaciones.text.trim(),

      'firmaGerente':
          _firmaGerente.text.trim(),

      'firmaSupervisor':
          _firmaSupervisor.text.trim(),

      // -------------------------------------------------------
      // ESTADO
      // -------------------------------------------------------

      'estado':
          'Borrador',

      'archivos':
          [],

      'pdfGenerado':
          false,

      'fechaCreacion':
          DateTime.now()
              .toIso8601String(),

      'fechaActualizacion':
          DateTime.now()
              .toIso8601String(),
    };

    AppData.bitacoras.add(datos);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  List<Map<String, String>> _copiarFilas(
    List<Map<String, String>> filas,
  ) {
    return filas
        .map(
          (fila) =>
              Map<String, String>.from(fila),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final movil =
        MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F172A),
        foregroundColor:
            Colors.white,
        elevation: 0,
        title: const Text(
          'Nueva Bitácora de Obra',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            movil ? 12 : 24,
            8,
            movil ? 12 : 24,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _tituloSeccion(
                'DATOS GENERALES',
              ),

              _cajaFormulario(
                _datosGenerales(movil),
              ),

              const SizedBox(height: 18),

              _tituloSeccion(
                'ALCANCE DE INSTALACIÓN DEL DÍA',
              ),

              _cajaFormulario(
                _tablaAlcances(movil),
              ),

              const SizedBox(height: 18),

              _tituloSeccion(
                'ANÁLISIS DE RIESGO POTENCIAL',
              ),

              _cajaFormulario(
                _analisisRiesgo(movil),
              ),

              const SizedBox(height: 18),

              _tituloSeccion(
                'PRODUCTOS DIARIOS INSTALADOS',
              ),

              _cajaFormulario(
                _tablaProductos(movil),
              ),

              const SizedBox(height: 18),

              _tituloSeccion(
                'PERSONAL ASIGNADO A LA OBRA',
              ),

              _cajaFormulario(
                _tablaPersonal(movil),
              ),

              const SizedBox(height: 18),

              _tituloSeccion(
                'OBSERVACIONES EN LA INSTALACIÓN / ACUERDOS CON GERENTE',
              ),

              _cajaFormulario(
                _campoTexto(
                  controller:
                      _observaciones,
                  label:
                      'Observaciones / acuerdos',
                  maxLines: 7,
                ),
              ),

              const SizedBox(height: 18),

              _tituloSeccion('FIRMAS'),

              _firmas(movil),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(
                      context,
                    ),
                    child: const Text(
                      'Cancelar',
                    ),
                  ),

                  const SizedBox(width: 12),

                  FilledButton.icon(
                    onPressed: _guardar,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      'Guardar bitácora',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'FO-DP-OS-07/03  Bitácora de Obra  Rev. 03',
                style: TextStyle(
                  color:
                      Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(
    String texto,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _cajaFormulario(
    Widget child,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(.05),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              Colors.white.withOpacity(.10),
        ),
      ),
      child: child,
    );
  }

  Widget _datosGenerales(
    bool movil,
  ) {
    return Column(
      children: [
        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller: _proyecto,
            label: 'Proyecto',
            obligatorio: true,
          ),
          segundo: _campoTexto(
            controller: _folio,
            label: 'N° de Obra',
            obligatorio: true,
          ),
        ),

        _linea(),

        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller: _gerente,
            label:
                'Gerente de Territorio / Encargado',
          ),
          segundo: _campoTexto(
            controller: _cliente,
            label: 'Cliente',
          ),
        ),

        _linea(),

        _campoTexto(
          controller: _ubicacion,
          label: 'Ubicación',
          maxLines: 2,
        ),

        _linea(),

        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller: _instalador,
            label: 'Instalador',
          ),
          segundo: _campoFecha(),
        ),

        _linea(),

        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller: _personas,
            label: 'N° de Personas',
            keyboardType:
                TextInputType.number,
          ),
          segundo: _campoTexto(
            controller: _contacto,
            label: 'Contacto',
            keyboardType:
                TextInputType.phone,
          ),
        ),

        _linea(),

        _selectorSiNo(
          titulo:
              'Son trabajos contemplados originalmente',
          valor:
              _trabajosOriginales,
          onChanged: (valor) {
            setState(() {
              _trabajosOriginales =
                  valor;
            });
          },
        ),

        const SizedBox(height: 10),

        _campoTexto(
          controller: _adicionales,
          label: 'Adicionales',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _tablaAlcances(
    bool movil,
  ) {
    if (movil) {
      return Column(
        children: [
          ...List.generate(
            _alcances.length,
            (index) =>
                _filaAlcanceMovil(
              _alcances[index],
              index,
            ),
          ),
          _botonAgregar(
            'Agregar área',
            Icons.add,
            _agregarAlcance,
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          color:
              const Color(0xFF111827),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Área',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'm²/m',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Producto',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Caja/Bolsa',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Descripción',
                  style:
                      _encabezadoStyle,
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
        ),

        ...List.generate(
          _alcances.length,
          (index) =>
              _filaAlcanceDesktop(
            _alcances[index],
            index,
          ),
        ),

        Align(
          alignment:
              Alignment.centerLeft,
          child: _botonAgregar(
            'Agregar área',
            Icons.add,
            _agregarAlcance,
          ),
        ),
      ],
    );
  }

  Widget _filaAlcanceDesktop(
    Map<String, String> fila,
    int index,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _celda(
              fila,
              'area',
              'Área',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: _celda(
              fila,
              'medida',
              'm²/m',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'producto',
              'Producto',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'cajasBolsa',
              'Caja/Bolsa',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 3,
            child: _celda(
              fila,
              'descripcion',
              'Descripción',
            ),
          ),

          SizedBox(
            width: 40,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              tooltip: 'Eliminar',
              onPressed: () =>
                  _eliminarAlcance(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaAlcanceMovil(
    Map<String, String> fila,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(8),
      color:
          const Color(0xFF111827),
      child: Column(
        children: [
          _celda(
            fila,
            'area',
            'Área',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'medida',
            'm²/m',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'producto',
            'Producto',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'cajasBolsa',
            'Caja/Bolsa',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'descripcion',
            'Descripción',
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              onPressed: () =>
                  _eliminarAlcance(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analisisRiesgo(
    bool movil,
  ) {
    return Column(
      children: [
        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller:
                _temperaturaArea,
            label:
                'Temperatura de Área',
          ),
          segundo: _selectorSiNo(
            titulo:
                'Ventilación',
            valor:
                _ventilacion,
            onChanged: (valor) {
              setState(() {
                _ventilacion =
                    valor;
              });
            },
          ),
        ),

        _linea(),

        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller:
                _presionOsmotica,
            label:
                'Afecta presión Osmótica',
          ),
          segundo:
              _selectorOpciones(
            titulo:
                'Condición del substrato',
            opciones: const [
              'Buena',
              'Regular',
              'Mala',
            ],
            valor:
                _condicionSubstrato,
            onChanged: (valor) {
              setState(() {
                _condicionSubstrato =
                    valor;
              });
            },
          ),
        ),

        _linea(),

        _filaResponsive(
          movil: movil,
          primero: _campoTexto(
            controller:
                _electricidad,
            label:
                'Electricidad disponible',
          ),
          segundo: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _selectorSiNo(
                titulo:
                    'Contaminación del substrato',
                valor:
                    _contaminacionSubstrato,
                onChanged:
                    (valor) {
                  setState(() {
                    _contaminacionSubstrato =
                        valor;
                  });
                },
              ),

              const SizedBox(
                height: 6,
              ),

              _campoTexto(
                controller:
                    _tipoContaminacion,
                label: 'Tipo',
              ),
            ],
          ),
        ),

        _linea(),

        _campoTexto(
          controller:
              _temperaturaPiso,
          label:
              'Temperatura del Piso',
        ),

        _linea(),

        _grupoChecks(
          titulo: 'Áreas',
          opciones: const [
            'Libres',
            'Húmedas',
            'Con gente',
            'Obstáculos',
          ],
          seleccion:
              _areas,
        ),

        _linea(),

        _grupoChecks(
          titulo:
              'Iluminación',
          opciones: const [
            'No hay',
            'Adecuada',
            'Temporal',
            'Mala',
          ],
          seleccion:
              _iluminacion,
        ),

        _linea(),

        _selectorSiNo(
          titulo:
              'Los obstáculos serán retirados',
          valor:
              _obstaculosRetirados,
          onChanged: (valor) {
            setState(() {
              _obstaculosRetirados =
                  valor;
            });
          },
        ),
      ],
    );
  }

  Widget _tablaProductos(
    bool movil,
  ) {
    if (movil) {
      return Column(
        children: [
          ...List.generate(
            _productos.length,
            (index) =>
                _filaProductoMovil(
              _productos[index],
              index,
            ),
          ),
          _botonAgregar(
            'Agregar producto',
            Icons.add,
            _agregarProducto,
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          color:
              const Color(0xFF111827),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'N° Lote',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'N° Producto',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Nombre',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Cantidad',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rendimiento',
                  style:
                      _encabezadoStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Comentarios',
                  style:
                      _encabezadoStyle,
                ),
              ),
              SizedBox(width: 40),
            ],
          ),
        ),

        ...List.generate(
          _productos.length,
          (index) =>
              _filaProductoDesktop(
            _productos[index],
            index,
          ),
        ),

        Align(
          alignment:
              Alignment.centerLeft,
          child: _botonAgregar(
            'Agregar producto',
            Icons.add,
            _agregarProducto,
          ),
        ),
      ],
    );
  }

  Widget _filaProductoDesktop(
    Map<String, String> fila,
    int index,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'lote',
              'Lote',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'numeroProducto',
              'N° Producto',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 3,
            child: _celda(
              fila,
              'nombreProducto',
              'Nombre',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'cantidad',
              'Cantidad',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'rendimiento',
              'Rendimiento',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 3,
            child: _celda(
              fila,
              'comentarios',
              'Comentarios',
            ),
          ),

          SizedBox(
            width: 40,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              tooltip: 'Eliminar',
              onPressed: () =>
                  _eliminarProducto(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaProductoMovil(
    Map<String, String> fila,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(8),
      color:
          const Color(0xFF111827),
      child: Column(
        children: [
          _celda(
            fila,
            'lote',
            'N° de Lote',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'numeroProducto',
            'N° de Producto',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'nombreProducto',
            'Nombre del Producto',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'cantidad',
            'Cantidad',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'rendimiento',
            'Rendimiento',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'comentarios',
            'Comentarios',
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              onPressed: () =>
                  _eliminarProducto(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablaPersonal(
    bool movil,
  ) {
    return Column(
      children: [
        if (!movil)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            color:
                const Color(0xFF111827),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nombre',
                    style:
                        _encabezadoStyle,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Puesto',
                    style:
                        _encabezadoStyle,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'NSS',
                    style:
                        _encabezadoStyle,
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),

        ...List.generate(
          _personal.length,
          (index) {
            if (movil) {
              return _filaPersonalMovil(
                _personal[index],
                index,
              );
            }

            return _filaPersonalDesktop(
              _personal[index],
              index,
            );
          },
        ),

        Align(
          alignment:
              Alignment.centerLeft,
          child: _botonAgregar(
            'Agregar personal',
            Icons.person_add_alt_1,
            _agregarPersonal,
          ),
        ),
      ],
    );
  }

  Widget _filaPersonalDesktop(
    Map<String, String> fila,
    int index,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _celda(
              fila,
              'nombre',
              'Nombre',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'puesto',
              'Puesto',
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            flex: 2,
            child: _celda(
              fila,
              'nss',
              'NSS',
            ),
          ),

          SizedBox(
            width: 40,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              tooltip: 'Eliminar',
              onPressed: () =>
                  _eliminarPersonal(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaPersonalMovil(
    Map<String, String> fila,
    int index,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
          const EdgeInsets.all(8),
      color:
          const Color(0xFF111827),
      child: Column(
        children: [
          _celda(
            fila,
            'nombre',
            'Nombre',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'puesto',
            'Puesto',
          ),

          const SizedBox(height: 6),

          _celda(
            fila,
            'nss',
            'NSS',
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: IconButton(
              padding:
                  EdgeInsets.zero,
              onPressed: () =>
                  _eliminarPersonal(
                index,
              ),
              icon: const Icon(
                Icons.delete_outline,
                color:
                    Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _firmas(
    bool movil,
  ) {
    if (movil) {
      return Column(
        children: [
          _cajaFormulario(
            _campoTexto(
              controller:
                  _firmaGerente,
              label:
                  'Nombre y Firma Gerente de Territorio',
              maxLines: 2,
            ),
          ),

          const SizedBox(height: 10),

          _cajaFormulario(
            _campoTexto(
              controller:
                  _firmaSupervisor,
              label:
                  'Nombre y Firma Supervisor',
              maxLines: 2,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _cajaFormulario(
            _campoTexto(
              controller:
                  _firmaGerente,
              label:
                  'Nombre y Firma Gerente de Territorio',
              maxLines: 2,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _cajaFormulario(
            _campoTexto(
              controller:
                  _firmaSupervisor,
              label:
                  'Nombre y Firma Supervisor',
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obligatorio = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      validator: obligatorio
          ? (valor) {
              if (valor == null ||
                  valor.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }

              return null;
            }
          : null,
      decoration:
          _decoracionCampo(label),
    );
  }

  Widget _campoFecha() {
    return TextFormField(
      controller: _fecha,
      readOnly: true,
      onTap:
          _seleccionarFecha,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration:
          _decoracionCampo(
        'Fecha',
        icono:
            Icons.calendar_today_outlined,
      ),
    );
  }

  Widget _celda(
    Map<String, String> fila,
    String clave,
    String etiqueta,
  ) {
    return TextFormField(
      initialValue:
          fila[clave] ?? '',
      onChanged: (valor) {
        fila[clave] = valor;
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration:
          _decoracionCampo(
        etiqueta,
      ),
    );
  }

  InputDecoration _decoracionCampo(
    String label, {
    IconData? icono,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(
        color:
            Color(0xFF94A3B8),
        fontSize: 12,
      ),
      prefixIcon: icono != null
          ? Icon(
              icono,
              color:
                  const Color(
                0xFF94A3B8,
              ),
              size: 17,
            )
          : null,
      filled: true,
      fillColor:
          const Color(0xFF111827),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide:
            const BorderSide(
          color:
              Color(0x2238BDF8),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide:
            const BorderSide(
          color:
              Color(0xFF3B82F6),
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(6),
        borderSide:
            const BorderSide(
          color:
              Colors.redAccent,
        ),
      ),
    );
  }

  Widget _selectorSiNo({
    required String titulo,
    required bool? valor,
    required ValueChanged<bool?>
        onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style:
              const TextStyle(
            color:
                Color(0xFFCBD5E1),
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),

        const SizedBox(height: 3),

        Wrap(
          spacing: 8,
          children: [
            _opcionCheck(
              texto: 'Sí',
              seleccionado:
                  valor == true,
              onChanged: (_) {
                onChanged(
                  valor == true
                      ? null
                      : true,
                );
              },
            ),

            _opcionCheck(
              texto: 'No',
              seleccionado:
                  valor == false,
              onChanged: (_) {
                onChanged(
                  valor == false
                      ? null
                      : false,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _selectorOpciones({
    required String titulo,
    required List<String> opciones,
    required String? valor,
    required ValueChanged<String?>
        onChanged,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style:
              const TextStyle(
            color:
                Color(0xFFCBD5E1),
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),

        const SizedBox(height: 3),

        Wrap(
          spacing: 8,
          runSpacing: 2,
          children:
              opciones.map(
            (opcion) {
              return _opcionCheck(
                texto: opcion,
                seleccionado:
                    valor == opcion,
                onChanged: (_) {
                  onChanged(
                    valor == opcion
                        ? null
                        : opcion,
                  );
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _grupoChecks({
    required String titulo,
    required List<String> opciones,
    required Set<String> seleccion,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style:
              const TextStyle(
            color:
                Color(0xFFCBD5E1),
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),

        const SizedBox(height: 3),

        Wrap(
          spacing: 8,
          runSpacing: 2,
          children:
              opciones.map(
            (opcion) {
              final activo =
                  seleccion.contains(
                opcion,
              );

              return _opcionCheck(
                texto: opcion,
                seleccionado:
                    activo,
                onChanged: (_) {
                  setState(() {
                    if (activo) {
                      seleccion.remove(
                        opcion,
                      );
                    } else {
                      seleccion.add(
                        opcion,
                      );
                    }
                  });
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _opcionCheck({
    required String texto,
    required bool seleccionado,
    required ValueChanged<bool?>
        onChanged,
  }) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Checkbox(
          value: seleccionado,
          onChanged: onChanged,
          activeColor:
              const Color(0xFF2563EB),
          checkColor:
              Colors.white,
          visualDensity:
              VisualDensity.compact,
        ),

        Text(
          texto,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _botonAgregar(
    String texto,
    IconData icono,
    VoidCallback funcion,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 4,
      ),
      child: OutlinedButton.icon(
        onPressed: funcion,
        icon: Icon(icono),
        label: Text(texto),
      ),
    );
  }

  Widget _filaResponsive({
    required bool movil,
    required Widget primero,
    required Widget segundo,
  }) {
    if (movil) {
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          primero,
          const SizedBox(
            height: 10,
          ),
          segundo,
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: primero,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: segundo,
        ),
      ],
    );
  }

  Widget _linea() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Divider(
        color:
            Color(0x20FFFFFF),
        height: 1,
      ),
    );
  }
}

const TextStyle _encabezadoStyle =
    TextStyle(
  color: Color(0xFFE2E8F0),
  fontSize: 11,
  fontWeight: FontWeight.w700,
);