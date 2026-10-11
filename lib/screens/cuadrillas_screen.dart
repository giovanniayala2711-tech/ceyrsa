
import 'package:flutter/material.dart';
import 'package:ceyrsa_app/data/app_data.dart';

class CuadrillasScreen extends StatefulWidget {
  const CuadrillasScreen({super.key});

  @override
  State<CuadrillasScreen> createState() => _CuadrillasScreenState();
}

class _CuadrillasScreenState extends State<CuadrillasScreen> {
  final TextEditingController _buscarController =
      TextEditingController();

  String _busqueda = '';

  static const Color _fondo = Color(0xFFF5F5F7);
  static const Color _blanco = Colors.white;
  static const Color _texto = Color(0xFF1D1D1F);
  static const Color _textoSecundario = Color(0xFF6E6E73);
  static const Color _borde = Color(0xFFE5E5EA);
  static const Color _azul = Color(0xFF007AFF);

  @override
  void initState() {
    super.initState();

    _buscarController.addListener(_actualizarBusqueda);
  }

  void _actualizarBusqueda() {
    setState(() {
      _busqueda =
          _buscarController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _buscarController.removeListener(_actualizarBusqueda);
    _buscarController.dispose();
    super.dispose();
  }

  // ============================================================
  // OBRAS ACTIVAS
  // ============================================================

  List<Map<String, dynamic>> get _obrasActivas {
    return AppData.obras.where((obra) {
      final estado =
          obra['estado']?.toString().toLowerCase().trim();

      return estado == 'activa';
    }).toList();
  }

  Map<String, dynamic>? _buscarObra(String? obraId) {
    if (obraId == null || obraId.isEmpty) {
      return null;
    }

    for (final obra in AppData.obras) {
      if (obra['id']?.toString() == obraId) {
        return obra;
      }
    }

    return null;
  }

  bool _obraEstaActiva(String? obraId) {
    final obra = _buscarObra(obraId);

    if (obra == null) {
      return false;
    }

    return obra['estado']?.toString().toLowerCase().trim() ==
        'activa';
  }

  // ============================================================
  // ASIGNACIONES DE UNA OBRA
  // ============================================================

  List<Map<String, dynamic>> _asignacionesDeObra(
    String obraId,
  ) {
    return AppData.cuadrillas.where((asignacion) {
      return asignacion['obraId']?.toString() == obraId;
    }).toList();
  }

  Map<String, dynamic>? _persona(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }

    return AppData.buscarPersonalPorId(id);
  }

  List<Map<String, dynamic>> _integrantes(
    Map<String, dynamic> asignacion,
  ) {
    final ids = List<String>.from(
      asignacion['integrantes'] ?? const [],
    );

    return ids
        .map(_persona)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // ============================================================
  // PERSONAS OCUPADAS
  // ============================================================

  Set<String> _personasOcupadas({
    String? asignacionActualId,
  }) {
    final ocupadas = <String>{};

    for (final asignacion in AppData.cuadrillas) {
      final idAsignacion =
          asignacion['id']?.toString();

      if (asignacionActualId != null &&
          idAsignacion == asignacionActualId) {
        continue;
      }

      final obraId =
          asignacion['obraId']?.toString();

      if (!_obraEstaActiva(obraId)) {
        continue;
      }

      final encargadoId =
          asignacion['encargadoId']?.toString();

      if (encargadoId != null &&
          encargadoId.isNotEmpty) {
        ocupadas.add(encargadoId);
      }

      final integrantes = List<String>.from(
        asignacion['integrantes'] ?? const [],
      );

      ocupadas.addAll(integrantes);
    }

    return ocupadas;
  }

  // ============================================================
  // ENCARGADOS
  // ============================================================

  List<Map<String, dynamic>> get _encargados {
    return AppData.personal.where((persona) {
      final rol =
          persona['rol']?.toString().toLowerCase().trim();

      final estado =
          persona['estado']?.toString().toLowerCase().trim();

      return rol == 'encargado' && estado != 'baja';
    }).toList();
  }

  // ============================================================
  // PERSONAS PERMITIDAS
  // ============================================================

  bool _puedeSerIntegrante(
    Map<String, dynamic> persona,
  ) {
    final rol =
        persona['rol']?.toString().toLowerCase().trim();

    final puesto =
        persona['puesto']?.toString().toLowerCase().trim();

    const rolesPermitidos = {
      'encargado',
      'instalador',
      'medio instalador',
      'ayudante',
    };

    const puestosPermitidos = {
      'encargado',
      'instalador',
      'medio instalador',
      'ayudante',
    };

    return rolesPermitidos.contains(rol) ||
        puestosPermitidos.contains(puesto);
  }

  // ============================================================
  // INICIALES
  // ============================================================

  String _iniciales(
    Map<String, dynamic> persona,
  ) {
    final nombre =
        persona['nombre']?.toString().trim() ?? '';

    if (nombre.isEmpty) {
      return '?';
    }

    final partes = nombre
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (partes.length == 1) {
      return partes.first
          .substring(0, 1)
          .toUpperCase();
    }

    return '${partes.first.substring(0, 1)}'
            '${partes.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _avatar(
    Map<String, dynamic> persona, {
    double size = 38,
    bool borde = true,
  }) {
    final foto =
        persona['foto']?.toString();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE9E9ED),
        border: borde
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
      ),
      child: ClipOval(
        child: foto != null && foto.isNotEmpty
            ? Image.network(
                foto,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      _iniciales(persona),
                      style: TextStyle(
                        fontSize: size * .30,
                        fontWeight:
                            FontWeight.w600,
                        color: _texto,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  _iniciales(persona),
                  style: TextStyle(
                    fontSize: size * .30,
                    fontWeight:
                        FontWeight.w600,
                    color: _texto,
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  // AVATARES APILADOS
  // ============================================================

  Widget _avataresApilados(
    List<Map<String, dynamic>> personas,
  ) {
    const limite = 6;

    final visibles =
        personas.take(limite).toList();

    final restantes =
        personas.length - visibles.length;

    if (visibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      width:
          (visibles.length * 27.0) +
          (restantes > 0 ? 40 : 15),
      child: Stack(
        children: [
          for (int i = 0;
              i < visibles.length;
              i++)
            Positioned(
              left: i * 27,
              top: 1,
              child: _avatar(
                visibles[i],
                size: 40,
              ),
            ),
          if (restantes > 0)
            Positioned(
              left: visibles.length * 27,
              top: 1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE9E9ED),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                alignment:
                    Alignment.center,
                child: Text(
                  '+$restantes',
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                    color: _texto,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // NUEVA ASIGNACIÓN
  // ============================================================

  void _nuevaAsignacion() {
    _abrirFormulario();
  }

  // ============================================================
  // EDITAR ASIGNACIÓN
  // ============================================================

  void _editarAsignacion(
    Map<String, dynamic> asignacion,
  ) {
    _abrirFormulario(
      asignacionExistente: asignacion,
    );
  }

  // ============================================================
  // FORMULARIO
  // ============================================================

  void _abrirFormulario({
    Map<String, dynamic>? asignacionExistente,
  }) {
    String? obraSeleccionada =
        asignacionExistente?['obraId']?.toString();

    String? encargadoSeleccionado =
        asignacionExistente?['encargadoId']?.toString();

    final seleccionados = <String>{
      ...List<String>.from(
        asignacionExistente?['integrantes'] ??
            const [],
      ),
    };

    final idActual =
        asignacionExistente?['id']?.toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final ocupadas =
                _personasOcupadas(
              asignacionActualId:
                  idActual,
            );

            final trabajadores =
                AppData.personal.where(
              (persona) {
                final estado =
                    persona['estado']
                        ?.toString()
                        .toLowerCase()
                        .trim();

                if (estado == 'baja') {
                  return false;
                }

                return _puedeSerIntegrante(
                  persona,
                );
              },
            ).toList();

            return Dialog(
              backgroundColor:
                  Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 24,
              ),
              child: Container(
                width: 900,
                constraints:
                    const BoxConstraints(
                  maxHeight: 760,
                ),
                decoration:
                    BoxDecoration(
                  color: _blanco,
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                  border: Border.all(
                    color: _borde,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black
                              .withOpacity(.10),
                      blurRadius: 35,
                      offset:
                          const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    // ==================================================
                    // ENCABEZADO
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        28,
                        24,
                        20,
                        20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFF0F0F2,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                13,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons
                                  .groups_rounded,
                              color:
                                  _texto,
                              size: 22,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  asignacionExistente ==
                                          null
                                      ? 'Asignar personal'
                                      : 'Editar asignación',
                                  style:
                                      const TextStyle(
                                    fontSize: 21,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color:
                                        _texto,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Text(
                                  'Selecciona el folio, el encargado y el personal asignado.',
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    color:
                                        _textoSecundario,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () =>
                                Navigator.pop(
                              dialogContext,
                            ),
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color: _borde,
                    ),

                    // ==================================================
                    // CONTENIDO
                    // ==================================================

                    Expanded(
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets
                                .all(28),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [

                            const Text(
                              'Obra',
                              style:
                                  TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    _texto,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _dropdownObra(
                              value:
                                  obraSeleccionada,
                              obras:
                                  _obrasActivas,
                              onChanged:
                                  (value) {
                                setDialogState(
                                  () {
                                    obraSeleccionada =
                                        value;
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            const Text(
                              'Encargado',
                              style:
                                  TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    _texto,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            _dropdownEncargado(
                              value:
                                  encargadoSeleccionado,
                              encargados:
                                  _encargados,
                              ocupadas:
                                  ocupadas,
                              onChanged:
                                  (value) {
                                setDialogState(
                                  () {
                                    encargadoSeleccionado =
                                        value;

                                    if (value !=
                                        null) {
                                      seleccionados
                                          .remove(
                                        value,
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            Row(
                              children: [
                                const Text(
                                  'Personal',
                                  style:
                                      TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    color:
                                        _texto,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFF0F0F2,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      8,
                                    ),
                                  ),
                                  child: Text(
                                    '${seleccionados.length}',
                                    style:
                                        const TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      color:
                                          _textoSecundario,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Container(
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFFAFAFB,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      _borde,
                                ),
                              ),
                              child: Column(
                                children: [
                                  _encabezadoTabla(),

                                  const Divider(
                                    height: 1,
                                    color:
                                        _borde,
                                  ),

                                  ...trabajadores
                                      .map(
                                    (
                                      persona,
                                    ) {
                                      final id =
                                          persona[
                                                  'id']
                                              ?.toString();

                                      if (id ==
                                          null ||
                                          id.isEmpty) {
                                        return const SizedBox
                                            .shrink();
                                      }

                                      final esEncargado =
                                          id ==
                                              encargadoSeleccionado;

                                      final estaOcupado =
                                          ocupadas
                                              .contains(
                                        id,
                                      );

                                      final estaSeleccionado =
                                          seleccionados
                                              .contains(
                                        id,
                                      );

                                      final bloqueado =
                                          esEncargado ||
                                              estaOcupado;

                                      return _filaTrabajador(
                                        persona:
                                            persona,
                                        seleccionado:
                                            estaSeleccionado,
                                        bloqueado:
                                            bloqueado,
                                        motivo:
                                            esEncargado
                                                ? 'Encargado seleccionado'
                                                : estaOcupado
                                                    ? 'Ya asignado a otra asignación'
                                                    : null,
                                        onChanged:
                                            bloqueado
                                                ? null
                                                : (value) {
                                                    setDialogState(
                                                      () {
                                                        if (value ==
                                                            true) {
                                                          seleccionados
                                                              .add(
                                                            id,
                                                          );
                                                        } else {
                                                          seleccionados
                                                              .remove(
                                                            id,
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color: _borde,
                    ),

                    // ==================================================
                    // BOTONES
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets
                              .all(20),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(
                              dialogContext,
                            ),
                            child:
                                const Text(
                              'Cancelar',
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          FilledButton(
                            style:
                                FilledButton
                                    .styleFrom(
                              backgroundColor:
                                  _azul,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 22,
                                vertical: 13,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (obraSeleccionada ==
                                      null ||
                                  obraSeleccionada!
                                      .isEmpty) {
                                _mensaje(
                                  'Selecciona una obra.',
                                  error:
                                      true,
                                );
                                return;
                              }

                              if (encargadoSeleccionado ==
                                      null ||
                                  encargadoSeleccionado!
                                      .isEmpty) {
                                _mensaje(
                                  'Selecciona un encargado.',
                                  error:
                                      true,
                                );
                                return;
                              }

                              _guardarAsignacion(
                                asignacionExistente:
                                    asignacionExistente,
                                obraId:
                                    obraSeleccionada!,
                                encargadoId:
                                    encargadoSeleccionado!,
                                integrantes:
                                    seleccionados
                                        .toList(),
                              );

                              Navigator.pop(
                                dialogContext,
                              );

                              _mensaje(
                                asignacionExistente ==
                                        null
                                    ? 'Personal asignado correctamente.'
                                    : 'Asignación actualizada correctamente.',
                              );
                            },
                            child: Text(
                              asignacionExistente ==
                                      null
                                  ? 'Asignar personal'
                                  : 'Guardar cambios',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DROPDOWN OBRA
  // ============================================================

  Widget _dropdownObra({
    required String? value,
    required List<Map<String, dynamic>>
        obras,
    required ValueChanged<String?>
        onChanged,
  }) {
    final existe = obras.any(
      (obra) =>
          obra['id']?.toString() ==
          value,
    );

    return DropdownButtonFormField<String>(
      value: existe ? value : null,
      isExpanded: true,
      decoration:
          InputDecoration(
        filled: true,
        fillColor:
            const Color(0xFFFAFAFB),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _borde,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _borde,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _azul,
          ),
        ),
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      hint: const Text(
        'Selecciona una obra',
      ),
      items: obras.map(
        (obra) {
          final id =
              obra['id']?.toString() ??
                  '';

          final folio =
              obra['folio']?.toString() ??
                  '';

          final nombre =
              obra['nombre']?.toString() ??
                  '';

          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              '$folio  •  $nombre',
              overflow:
                  TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // DROPDOWN ENCARGADO
  // ============================================================

  Widget _dropdownEncargado({
    required String? value,
    required List<Map<String, dynamic>>
        encargados,
    required Set<String> ocupadas,
    required ValueChanged<String?>
        onChanged,
  }) {
    final existe = encargados.any(
      (persona) =>
          persona['id']?.toString() ==
          value,
    );

    final items =
        <DropdownMenuItem<String>>[];

    for (final persona in encargados) {
      final id =
          persona['id']?.toString() ??
              '';

      final nombre =
          persona['nombre']?.toString() ??
              '';

      final ocupado =
          ocupadas.contains(id);

      if (ocupado && id != value) {
        continue;
      }

      items.add(
        DropdownMenuItem<String>(
          value: id,
          child: Row(
            children: [
              _avatar(
                persona,
                size: 30,
                borde: false,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  nombre,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: existe ? value : null,
      isExpanded: true,
      decoration:
          InputDecoration(
        filled: true,
        fillColor:
            const Color(0xFFFAFAFB),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _borde,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _borde,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            13,
          ),
          borderSide:
              const BorderSide(
            color: _azul,
          ),
        ),
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      hint: const Text(
        'Selecciona un encargado',
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  // ============================================================
  // ENCABEZADO DE PERSONAL
  // ============================================================

  Widget _encabezadoTabla() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
          ),
          Expanded(
            flex: 3,
            child: Text(
              'PERSONA',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: .4,
                color:
                    _textoSecundario,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ROL',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: .4,
                color:
                    _textoSecundario,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'PUESTO',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: .4,
                color:
                    _textoSecundario,
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Text(
              'ESTADO',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
                letterSpacing: .4,
                color:
                    _textoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILA DE TRABAJADOR
  // ============================================================

  Widget _filaTrabajador({
    required Map<String, dynamic>
        persona,
    required bool seleccionado,
    required bool bloqueado,
    required String? motivo,
    required ValueChanged<bool?>?
        onChanged,
  }) {
    final rol =
        persona['rol']?.toString() ??
            '';

    final puesto =
        persona['puesto']?.toString() ??
            '';

    final nombre =
        persona['nombre']?.toString() ??
            '';

    return Container(
      decoration:
          BoxDecoration(
        color: bloqueado
            ? const Color(0xFFF3F3F5)
            : seleccionado
                ? const Color(0xFFF0F6FF)
                : Colors.transparent,
      ),
      child: Padding(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: seleccionado,
                onChanged: onChanged,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    5,
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Opacity(
                    opacity:
                        bloqueado ? .55 : 1,
                    child: _avatar(
                      persona,
                      size: 36,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      nombre,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w500,
                        color: bloqueado
                            ? _textoSecundario
                            : _texto,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                rol,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: bloqueado
                      ? _textoSecundario
                      : _texto,
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                puesto,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: bloqueado
                      ? _textoSecundario
                      : _texto,
                ),
              ),
            ),

            SizedBox(
              width: 180,
              child: motivo != null
                  ? Text(
                      motivo,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w500,
                        color:
                            _textoSecundario,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GUARDAR ASIGNACIÓN
  // ============================================================

  void _guardarAsignacion({
    required Map<String, dynamic>?
        asignacionExistente,
    required String obraId,
    required String encargadoId,
    required List<String> integrantes,
  }) {
    if (asignacionExistente == null) {
      final id =
          AppData.siguienteIdCuadrilla();

      AppData.cuadrillas.add({
        'id': id,
        'obraId': obraId,
        'encargadoId':
            encargadoId,
        'integrantes':
            integrantes,
      });
    } else {
      asignacionExistente['obraId'] =
          obraId;

      asignacionExistente[
              'encargadoId'] =
          encargadoId;

      asignacionExistente[
              'integrantes'] =
          integrantes;

      // No utilizamos nombre de asignación.
      asignacionExistente.remove(
        'nombre',
      );
    }

    setState(() {});
  }

  // ============================================================
  // FICHA DE OBRA
  //
  // CÍRCULOS SOLAMENTE A LA DERECHA.
  // SIN DIVISIÓN INTERNA.
  // ============================================================

  Widget _fichaObra(
    Map<String, dynamic> obra,
  ) {
    final obraId =
        obra['id']?.toString() ?? '';

    final asignaciones =
        _asignacionesDeObra(
      obraId,
    );

    final nombre =
        obra['nombre']?.toString() ??
            'Sin nombre';

    final folio =
        obra['folio']?.toString() ??
            'Sin folio';

    final cliente =
        obra['cliente']?.toString() ??
            'Sin cliente';

    final ubicacion =
        obra['ubicacion']?.toString() ??
            obra['direccion']?.toString() ??
            'Sin ubicación';

    final estado =
        obra['estado']?.toString() ??
            'Activa';

    final encargados =
        <Map<String, dynamic>>[];

    final personas =
        <Map<String, dynamic>>[];

    for (final asignacion
        in asignaciones) {
      final encargado = _persona(
        asignacion['encargadoId']
            ?.toString(),
      );

      if (encargado != null) {
        encargados.add(
          encargado,
        );

        personas.add(
          encargado,
        );
      }

      personas.addAll(
        _integrantes(
          asignacion,
        ),
      );
    }

    // Quitar duplicados.
    final idsVistos = <String>{};

    final personasFinales =
        <Map<String, dynamic>>[];

    for (final persona in personas) {
      final id =
          persona['id']?.toString();

      if (id == null ||
          id.isEmpty) {
        continue;
      }

      if (idsVistos.add(id)) {
        personasFinales.add(
          persona,
        );
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        onTap: () => _detalleObra(
          obra,
          asignaciones,
        ),
        child: Container(
          decoration:
              BoxDecoration(
            color: _blanco,
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border:
                Border.all(
              color: _borde,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  .035,
                ),
                blurRadius: 15,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              22,
              20,
              22,
              18,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                // ==================================================
                // INFORMACIÓN PRINCIPAL
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .center,
                  children: [

                    // ----------------------------------------------
                    // INFORMACIÓN DE OBRA
                    // ----------------------------------------------

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFF0F0F2,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                ),
                                child:
                                    Text(
                                  folio,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        11,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    color:
                                        _texto,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFE9F8EF,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                ),
                                child:
                                    Text(
                                  estado,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        10,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                    color:
                                        Color(
                                      0xFF248A4B,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 9,
                          ),

                          Text(
                            nombre,
                            style:
                                const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  _texto,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            cliente,
                            style:
                                const TextStyle(
                              fontSize: 13,
                              color:
                                  _textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ----------------------------------------------
                    // ENCARGADO + CÍRCULOS
                    // ----------------------------------------------

                    Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [

                        if (encargados
                            .isNotEmpty)
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .end,
                            children: [
                              const Text(
                                'ENCARGADO',
                                style:
                                    TextStyle(
                                  fontSize:
                                      9,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  letterSpacing:
                                      .5,
                                  color:
                                      _textoSecundario,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                encargados
                                            .length ==
                                        1
                                    ? encargados
                                            .first[
                                                'nombre']
                                            ?.toString() ??
                                        ''
                                    : '${encargados.length} encargados',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      12,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color:
                                      _texto,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(
                          width: 14,
                        ),

                        if (personasFinales
                            .isNotEmpty)
                          _avataresApilados(
                            personasFinales,
                          ),

                        const SizedBox(
                          width: 8,
                        ),

                        const Icon(
                          Icons
                              .chevron_right_rounded,
                          color:
                              Color(
                            0xFFB0B0B5,
                          ),
                          size: 21,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                  height: 17,
                ),

                // ==================================================
                // UBICACIÓN
                // ==================================================

                Row(
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 16,
                      color:
                          _textoSecundario,
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Expanded(
                      child: Text(
                        ubicacion,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              _textoSecundario,
                        ),
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                    ),

                    const SizedBox(
                      width: 15,
                    ),

                    Text(
                      personasFinales
                              .isEmpty
                          ? 'Sin personal'
                          : '${personasFinales.length} persona${personasFinales.length == 1 ? '' : 's'}',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            _textoSecundario,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DETALLE DE OBRA
  // ============================================================

  void _detalleObra(
    Map<String, dynamic> obra,
    List<Map<String, dynamic>>
        asignaciones,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.all(
            30,
          ),
          child: Container(
            width: 800,
            constraints:
                const BoxConstraints(
              maxHeight: 700,
            ),
            decoration:
                BoxDecoration(
              color: _blanco,
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
              border: Border.all(
                color: _borde,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(.08),
                  blurRadius: 30,
                  offset:
                      const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [

                // ==================================================
                // HEADER
                // ==================================================

                Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    25,
                    22,
                    18,
                    18,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              obra['folio']
                                      ?.toString() ??
                                  'Sin folio',
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    _textoSecundario,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              obra['nombre']
                                      ?.toString() ??
                                  'Sin nombre',
                              style:
                                  const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight
                                        .w700,
                                color:
                                    _texto,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              obra['cliente']
                                      ?.toString() ??
                                  '',
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                color:
                                    _textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(
                          dialogContext,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                  color: _borde,
                ),

                // ==================================================
                // ASIGNACIONES
                // ==================================================

                Expanded(
                  child:
                      asignaciones.isEmpty
                          ? _detalleSinPersonal()
                          : ListView
                              .separated(
                              padding:
                                  const EdgeInsets
                                      .all(
                                24,
                              ),
                              itemCount:
                                  asignaciones
                                      .length,
                              separatorBuilder:
                                  (
                                _,
                                __,
                              ) =>
                                      const Divider(
                                height: 30,
                                color:
                                    _borde,
                              ),
                              itemBuilder:
                                  (
                                _,
                                index,
                              ) {
                                return _detalleAsignacion(
                                  asignaciones[
                                      index],
                                  dialogContext,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETALLE SIN PERSONAL
  // ============================================================

  Widget _detalleSinPersonal() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFF0F0F2),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.groups_outlined,
              size: 28,
              color:
                  _textoSecundario,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            'Sin personal asignado',
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
              color: _texto,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const Text(
            'Esta obra aún no tiene personal asignado.',
            style:
                TextStyle(
              fontSize: 12,
              color:
                  _textoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETALLE DE ASIGNACIÓN
  // ============================================================

  Widget _detalleAsignacion(
    Map<String, dynamic> asignacion,
    BuildContext dialogContext,
  ) {
    final encargado = _persona(
      asignacion['encargadoId']
          ?.toString(),
    );

    final integrantes =
        _integrantes(
      asignacion,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        // ========================================================
        // ENCARGADO
        // ========================================================

        if (encargado != null)
          Row(
            children: [
              _avatar(
                encargado,
                size: 48,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'ENCARGADO',
                      style:
                          TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .w700,
                        letterSpacing:
                            .5,
                        color:
                            _textoSecundario,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      encargado['nombre']
                              ?.toString() ??
                          '',
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w600,
                        color:
                            _texto,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      encargado['puesto']
                              ?.toString() ??
                          '',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            _textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        const SizedBox(
          height: 20,
        ),

        // ========================================================
        // PERSONAL
        // ========================================================

        const Text(
          'PERSONAL',
          style:
              TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w700,
            letterSpacing: .5,
            color:
                _textoSecundario,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        if (integrantes.isEmpty)
          const Text(
            'Sin personal adicional.',
            style:
                TextStyle(
              fontSize: 12,
              color:
                  _textoSecundario,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                integrantes.map(
              (persona) {
                return Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFF7F7F8,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                    border:
                        Border.all(
                      color: _borde,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      _avatar(
                        persona,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        persona['nombre']
                                ?.toString() ??
                            '',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .w500,
                          color:
                              _texto,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),

        const SizedBox(
          height: 20,
        ),

        // ========================================================
        // ACCIONES
        // ========================================================

        Row(
          mainAxisAlignment:
              MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                _editarAsignacion(
                  asignacion,
                );
              },
              icon: const Icon(
                Icons
                    .edit_outlined,
                size: 17,
              ),
              label:
                  const Text(
                'Editar',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    _texto,
                side:
                    const BorderSide(
                  color: _borde,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            OutlinedButton.icon(
              onPressed: () async {
                Navigator.pop(
                  dialogContext,
                );

                await _eliminarAsignacion(
                  asignacion,
                );
              },
              icon: const Icon(
                Icons
                    .delete_outline_rounded,
                size: 17,
              ),
              label:
                  const Text(
                'Eliminar',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    const Color(
                  0xFFFF3B30,
                ),
                side:
                    const BorderSide(
                  color: Color(
                    0xFFFFD5D2,
                  ),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ELIMINAR ASIGNACIÓN
  // ============================================================

  Future<void> _eliminarAsignacion(
    Map<String, dynamic> asignacion,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text(
            'Eliminar asignación',
          ),
          content:
              const Text(
            '¿Quieres eliminar esta asignación de personal?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child:
                  const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFFF3B30,
                ),
              ),
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child:
                  const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final id =
        asignacion['id']?.toString();

    AppData.cuadrillas
        .removeWhere(
      (item) =>
          item['id']?.toString() ==
          id,
    );

    setState(() {});

    _mensaje(
      'Asignación eliminada.',
    );
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mensaje(
    String texto, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: error
            ? const Color(
                0xFFFF3B30,
              )
            : _texto,
        content: Text(texto),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BÚSQUEDA
  // ============================================================

  bool _coincideBusqueda(
    Map<String, dynamic> obra,
  ) {
    if (_busqueda.isEmpty) {
      return true;
    }

    final campos = [
      obra['nombre'],
      obra['folio'],
      obra['cliente'],
      obra['ubicacion'],
      obra['direccion'],
    ];

    for (final campo in campos) {
      if (campo
          .toString()
          .toLowerCase()
          .contains(_busqueda)) {
        return true;
      }
    }

    final obraId =
        obra['id']?.toString();

    if (obraId != null) {
      final asignaciones =
          _asignacionesDeObra(
        obraId,
      );

      for (final asignacion
          in asignaciones) {
        final encargado =
            _persona(
          asignacion[
                  'encargadoId']
              ?.toString(),
        );

        final nombreEncargado =
            encargado?['nombre']
                    ?.toString()
                    .toLowerCase() ??
                '';

        if (nombreEncargado
            .contains(
          _busqueda,
        )) {
          return true;
        }

        for (final integrante
            in _integrantes(
          asignacion,
        )) {
          final nombre =
              integrante['nombre']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          if (nombre.contains(
            _busqueda,
          )) {
            return true;
          }
        }
      }
    }

    return false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final obras =
        _obrasActivas
            .where(
              _coincideBusqueda,
            )
            .toList();

    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: Column(
          children: [

            // ======================================================
            // HEADER
            // ======================================================

            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                30,
                25,
                30,
                20,
              ),
              child: Row(
                children: [

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Cuadrillas',
                          style:
                              TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                _texto,
                            letterSpacing:
                                -.6,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Personal asignado por obra',
                          style:
                              TextStyle(
                            fontSize: 13,
                            color:
                                _textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // BUSCADOR
                  // ==================================================

                  SizedBox(
                    width: 300,
                    height: 42,
                    child:
                        TextField(
                      controller:
                          _buscarController,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Buscar por folio, obra o encargado...',
                        hintStyle:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              _textoSecundario,
                        ),
                        prefixIcon:
                            const Icon(
                          Icons
                              .search_rounded,
                          size: 19,
                          color:
                              _textoSecundario,
                        ),
                        suffixIcon:
                            _busqueda
                                    .isNotEmpty
                                ? IconButton(
                                    onPressed:
                                        () {
                                      _buscarController
                                          .clear();
                                    },
                                    icon:
                                        const Icon(
                                      Icons
                                          .close_rounded,
                                      size: 17,
                                    ),
                                  )
                                : null,
                        filled: true,
                        fillColor:
                            Colors.white,
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                _borde,
                          ),
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                _borde,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            13,
                          ),
                          borderSide:
                              const BorderSide(
                            color:
                                _azul,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  FilledButton.icon(
                    onPressed:
                        _nuevaAsignacion,
                    style:
                        FilledButton
                            .styleFrom(
                      backgroundColor:
                          _texto,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 17,
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    icon:
                        const Icon(
                      Icons
                          .add_rounded,
                      size: 18,
                    ),
                    label:
                        const Text(
                      'Asignar personal',
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // CONTENIDO
            // ======================================================

            Expanded(
              child: obras.isEmpty
                  ? _estadoVacio()
                  : Scrollbar(
                      child:
                          ListView
                              .builder(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          30,
                          5,
                          30,
                          35,
                        ),
                        itemCount:
                            obras.length,
                        itemBuilder:
                            (
                          _,
                          index,
                        ) {
                          return Padding(
                            padding:
                                const EdgeInsets
                                    .only(
                              bottom: 16,
                            ),
                            child:
                                _fichaObra(
                              obras[
                                  index],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget _estadoVacio() {
    final hayObrasActivas =
        _obrasActivas.isNotEmpty;

    return Center(
      child: Container(
        width: 430,
        padding:
            const EdgeInsets.all(
          35,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          border: Border.all(
            color: _borde,
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFF0F0F2),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons
                    .groups_outlined,
                size: 30,
                color:
                    _textoSecundario,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              hayObrasActivas
                  ? 'No encontramos resultados'
                  : 'No hay obras activas',
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
                color: _texto,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              hayObrasActivas
                  ? 'Prueba con otro folio, obra o encargado.'
                  : 'Las asignaciones aparecerán aquí cuando existan obras activas.',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize: 12,
                height: 1.5,
                color:
                    _textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
