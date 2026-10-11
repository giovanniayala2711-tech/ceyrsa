import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ceyrsa_app/data/app_data.dart';
import 'package:ceyrsa_app/services/auth_service.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  String _busqueda = '';

  String get _usuarioId =>
      AuthService.usuarioActual?['id']?.toString() ?? '';

  bool get _esEncargado =>
      AuthService.usuarioActual?['rol']?.toString().toLowerCase() ==
      'encargado';

  @override
  Widget build(BuildContext context) {
    final jornadas = _obtenerJornadas();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(jornadas.length),
            Expanded(
              child: jornadas.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                      itemCount: jornadas.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _JornadaCard(
                          jornada: jornadas[index],
                          onView: () => _verRegistro(jornadas[index]),
                          onEdit: _esEncargado
                              ? () => _editarJornada(jornadas[index])
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistencia',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Control diario de jornadas y personal',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6E6E73),
                  ),
                ),
              ],
            ),
          ),
          _MacSearchField(
            width: 280,
            onChanged: (value) {
              setState(() {
                _busqueda = value;
              });
            },
          ),
          const SizedBox(width: 10),
          _MacButton(
            icon: CupertinoIcons.add,
            label: 'Nueva jornada',
            onPressed: _esEncargado ? _nuevaJornada : null,
            primary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Container(
        width: 430,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E5EA),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.person_2,
                size: 27,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay jornadas registradas',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Las jornadas de asistencia aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6E6E73),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_JornadaData> _obtenerJornadas() {
    final Map<String, _JornadaData> agrupadas = {};

    for (final registro in AppData.asistencias) {
      final obraId = registro['obraId']?.toString() ?? '';
      final asignacionId = registro['asignacionId']?.toString() ?? '';
      final fecha = registro['fechaTrabajo']?.toString() ?? '';

      if (obraId.isEmpty || fecha.isEmpty) continue;

      final key = '$obraId|$asignacionId|$fecha';

      agrupadas.putIfAbsent(
        key,
        () => _JornadaData(
          obraId: obraId,
          asignacionId: asignacionId,
          fechaTrabajo: fecha,
          registros: [],
        ),
      );

      agrupadas[key]!.registros.add(registro);
    }

    final resultado = agrupadas.values.toList();

    resultado.sort(
      (a, b) => b.fechaTrabajo.compareTo(a.fechaTrabajo),
    );

    if (_busqueda.trim().isEmpty) {
      return resultado;
    }

    final query = _busqueda.trim().toLowerCase();

    return resultado.where((jornada) {
      final obra = AppData.buscarObraPorId(jornada.obraId);
      final asignacion =
          AppData.buscarCuadrillaPorId(jornada.asignacionId);

      final encargado = asignacion == null
          ? null
          : AppData.buscarPersonalPorId(
              asignacion['encargadoId']?.toString() ?? '',
            );

      final texto = [
        obra?['folio'],
        obra?['nombre'],
        obra?['cliente'],
        encargado?['nombre'],
        encargado?['identificador'],
        jornada.fechaTrabajo,
      ].join(' ').toLowerCase();

      return texto.contains(query);
    }).toList();
  }

  Future<void> _nuevaJornada() async {
    if (!_esEncargado) return;

    final creada = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) => _NuevaJornadaWindow(
        usuarioId: _usuarioId,
      ),
    );

    if (creada == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _editarJornada(_JornadaData jornada) async {
    final editada = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) => _EditarJornadaWindow(
        jornada: jornada,
      ),
    );

    if (editada == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _verRegistro(_JornadaData jornada) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) => _RegistroCompletoWindow(
        jornada: jornada,
      ),
    );
  }
}

/* =========================================================
   JORNADA CARD
========================================================= */

class _JornadaCard extends StatelessWidget {
  final _JornadaData jornada;
  final VoidCallback onView;
  final VoidCallback? onEdit;

  const _JornadaCard({
    required this.jornada,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final obra = AppData.buscarObraPorId(jornada.obraId);
    final asignacion =
        AppData.buscarCuadrillaPorId(jornada.asignacionId);

    final encargado = asignacion == null
        ? null
        : AppData.buscarPersonalPorId(
            asignacion['encargadoId']?.toString() ?? '',
          );

    final trabajadores = jornada.registros.length;

    final totalHoras = jornada.registros.fold<double>(
      0,
      (sum, registro) =>
          sum + _toDouble(registro['horasTrabajadas']),
    );

    final totalExtra = jornada.registros.fold<double>(
      0,
      (sum, registro) =>
          sum + _toDouble(registro['horasExtra']),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        child: Row(
          children: [
            _FechaCard(
              fecha: jornada.fechaTrabajo,
            ),
            const SizedBox(width: 17),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _FolioPill(
                        folio: obra?['folio']?.toString() ?? '—',
                      ),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          obra?['nombre']?.toString() ?? 'Obra',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.person_fill,
                        size: 13,
                        color: Color(0xFF8E8E93),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        encargado?['nombre']?.toString() ?? 'Sin encargado',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6E6E73),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _StatItem(
              icon: CupertinoIcons.person_2,
              value: '$trabajadores',
              label: 'Personal',
            ),
            const SizedBox(width: 25),
            _StatItem(
              icon: CupertinoIcons.clock,
              value: _formatHours(totalHoras),
              label: 'Horas',
            ),
            const SizedBox(width: 25),
            _StatItem(
              icon: CupertinoIcons.plus_circle,
              value: _formatHours(totalExtra),
              label: 'Extra',
            ),
            const SizedBox(width: 22),
            _MacSmallButton(
              icon: CupertinoIcons.eye,
              label: 'Ver registro',
              onPressed: onView,
            ),
            const SizedBox(width: 7),
            _MacIconButton(
              icon: CupertinoIcons.pencil,
              tooltip: 'Editar',
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FechaCard extends StatelessWidget {
  final String fecha;

  const _FechaCard({
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(fecha);

    final dia = date == null
        ? '—'
        : date.day.toString().padLeft(2, '0');

    final mes = date == null
        ? ''
        : _mesCorto(date.month);

    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dia,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mes,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolioPill extends StatelessWidget {
  final String folio;

  const _FolioPill({
    required this.folio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        'Folio $folio',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF007AFF),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF8E8E93),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   NUEVA JORNADA
========================================================= */

class _NuevaJornadaWindow extends StatefulWidget {
  final String usuarioId;

  const _NuevaJornadaWindow({
    required this.usuarioId,
  });

  @override
  State<_NuevaJornadaWindow> createState() =>
      _NuevaJornadaWindowState();
}

class _NuevaJornadaWindowState extends State<_NuevaJornadaWindow> {
  String? _obraId;
  String? _asignacionId;
  DateTime _fecha = DateTime.now();

  final Map<String, String> _entradas = {};
  final Map<String, String> _salidas = {};

  String? _error;

  List<Map<String, dynamic>> get _obrasActivas {
    final ids = <String>{};

    for (final asignacion in AppData.cuadrillas) {
      final encargadoId =
          asignacion['encargadoId']?.toString() ?? '';

      if (encargadoId != widget.usuarioId) continue;

      final obraId =
          asignacion['obraId']?.toString() ?? '';

      final obra = AppData.buscarObraPorId(obraId);

      if (obra == null) continue;

      if (obra['estado']?.toString().toLowerCase() != 'activa') {
        continue;
      }

      ids.add(obraId);
    }

    return AppData.obras
        .where((obra) => ids.contains(obra['id']?.toString()))
        .toList();
  }

  List<Map<String, dynamic>> get _asignaciones {
    if (_obraId == null) return [];

    return AppData.cuadrillas.where((asignacion) {
      return asignacion['obraId']?.toString() == _obraId &&
          asignacion['encargadoId']?.toString() == widget.usuarioId;
    }).toList();
  }

  Map<String, dynamic>? get _asignacionActual {
    if (_asignacionId == null) return null;

    return AppData.buscarCuadrillaPorId(_asignacionId!);
  }

  List<Map<String, dynamic>> get _personal {
    final asignacion = _asignacionActual;

    if (asignacion == null) return [];

    final integrantes = asignacion['integrantes'];

    if (integrantes is! List) return [];

    final result = <Map<String, dynamic>>[];

    for (final item in integrantes) {
      String? id;

      if (item is String) {
        id = item;
      } else if (item is Map) {
        id = item['id']?.toString();
      }

      if (id == null) continue;

      final persona = AppData.buscarPersonalPorId(id);

      if (persona != null) {
        result.add(persona);
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();

    if (_obrasActivas.length == 1) {
      _obraId = _obrasActivas.first['id']?.toString();

      if (_asignaciones.length == 1) {
        _asignacionId = _asignaciones.first['id']?.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final obra = _obraId == null
        ? null
        : AppData.buscarObraPorId(_obraId!);

    final asignacion = _asignacionActual;

    final encargado = asignacion == null
        ? null
        : AppData.buscarPersonalPorId(
            asignacion['encargadoId']?.toString() ?? '',
          );

    return _MacWindow(
      width: 1080,
      title: 'Nueva jornada',
      subtitle: 'Registro de asistencia',
      onClose: () => Navigator.pop(context, false),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MacButton(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(width: 8),
          _MacButton(
            icon: CupertinoIcons.checkmark,
            label: 'Guardar jornada',
            primary: true,
            onPressed: _guardar,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WindowTopInfo(
            icon: CupertinoIcons.calendar,
            title: 'Registro de jornada',
            description:
                'Selecciona la obra y registra los horarios del personal.',
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _MacSelectField(
                  label: 'Obra',
                  value: _obraId,
                  placeholder: 'Seleccionar obra',
                  items: _obrasActivas.map((obra) {
                    final id = obra['id']?.toString() ?? '';
                    final folio = obra['folio']?.toString() ?? '';
                    final nombre = obra['nombre']?.toString() ?? '';

                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        'Folio $folio  ·  $nombre',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _obraId = value;
                      _asignacionId = null;
                      _entradas.clear();
                      _salidas.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 210,
                child: _MacDateField(
                  label: 'Fecha de trabajo',
                  value: _fecha,
                  onChanged: (date) {
                    if (date == null) return;
                    setState(() {
                      _fecha = date;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_obraId != null)
            Row(
              children: [
                Expanded(
                  child: _MacSelectField(
                    label: 'Encargado',
                    value: _asignacionId,
                    placeholder: 'Seleccionar encargado',
                    items: _asignaciones.map((asignacion) {
                      final id =
                          asignacion['id']?.toString() ?? '';

                      final persona =
                          AppData.buscarPersonalPorId(
                        asignacion['encargadoId']?.toString() ?? '',
                      );

                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(
                          persona?['nombre']?.toString() ??
                              'Encargado',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _asignacionId = value;
                        _entradas.clear();
                        _salidas.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _InfoField(
                    label: 'Obra seleccionada',
                    value: obra?['nombre']?.toString() ?? '—',
                  ),
                ),
              ],
            ),
          if (encargado != null) ...[
            const SizedBox(height: 14),
            _SelectedEncargado(
              persona: encargado,
            ),
          ],
          const SizedBox(height: 22),
          const _SectionTitle(
            title: 'Personal',
            subtitle: 'Entrada y salida de cada trabajador',
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _personal.isEmpty
                ? _EmptyInline(
                    text: _obraId == null
                        ? 'Selecciona una obra para continuar.'
                        : 'Selecciona el encargado para mostrar el personal.',
                  )
                : ListView.separated(
                    itemCount: _personal.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final persona = _personal[index];

                      final id =
                          persona['id']?.toString() ?? '';

                      final entrada =
                          _entradas[id] ?? '07:00';

                      final salida =
                          _salidas[id] ?? '17:00';

                      return _HorarioEditRow(
                        persona: persona,
                        entrada: entrada,
                        salida: salida,
                        onEntrada: () =>
                            _seleccionarHora(id, true),
                        onSalida: () =>
                            _seleccionarHora(id, false),
                      );
                    },
                  ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(text: _error!),
          ],
        ],
      ),
    );
  }

  Future<void> _seleccionarHora(
    String personaId,
    bool entrada,
  ) async {
    final actual = entrada
        ? (_entradas[personaId] ?? '07:00')
        : (_salidas[personaId] ?? '17:00');

    final parts = actual.split(':');

    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final result = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    final value =
        '${result.hour.toString().padLeft(2, '0')}:'
        '${result.minute.toString().padLeft(2, '0')}';

    setState(() {
      if (entrada) {
        _entradas[personaId] = value;
      } else {
        _salidas[personaId] = value;
      }
    });
  }

  void _guardar() {
    setState(() {
      _error = null;
    });

    if (_obraId == null || _asignacionId == null) {
      setState(() {
        _error = 'Selecciona la obra y el encargado.';
      });
      return;
    }

    if (_personal.isEmpty) {
      setState(() {
        _error = 'No hay personal asignado para esta jornada.';
      });
      return;
    }

    final fechaTrabajo = _fechaFormato(_fecha);

    int creados = 0;

    for (final persona in _personal) {
      final personaId =
          persona['id']?.toString() ?? '';

      final entrada =
          _entradas[personaId] ?? '07:00';

      final salida =
          _salidas[personaId] ?? '17:00';

      final yaExiste = AppData.asistencias.any((registro) {
        return registro['fechaTrabajo']?.toString() ==
                fechaTrabajo &&
            registro['obraId']?.toString() == _obraId &&
            registro['asignacionId']?.toString() ==
                _asignacionId &&
            registro['personalId']?.toString() == personaId;
      });

      if (yaExiste) continue;

      final horas = _calcularHoras(
        entrada,
        salida,
      );

      AppData.asistencias.add({
        'id': AppData.siguienteIdAsistencia(),
        'fechaTrabajo': fechaTrabajo,
        'fechaRegistro': DateTime.now().toIso8601String(),
        'obraId': _obraId,
        'asignacionId': _asignacionId,
        'encargadoId': widget.usuarioId,
        'personalId': personaId,
        'nombre': persona['nombre']?.toString() ?? '',
        'puesto': persona['puesto']?.toString() ?? '',
        'nss': persona['nss']?.toString() ?? '',
        'foto': persona['foto']?.toString() ?? '',
        'entrada': entrada,
        'salida': salida,
        'horasTrabajadas': horas.trabajadas,
        'horasExtra': horas.extra,
      });

      creados++;
    }

    if (creados == 0) {
      setState(() {
        _error =
            'Todos los registros de esta jornada ya existen.';
      });
      return;
    }

    Navigator.pop(context, true);
  }
}

/* =========================================================
   EDITAR JORNADA
========================================================= */

class _EditarJornadaWindow extends StatefulWidget {
  final _JornadaData jornada;

  const _EditarJornadaWindow({
    required this.jornada,
  });

  @override
  State<_EditarJornadaWindow> createState() =>
      _EditarJornadaWindowState();
}

class _EditarJornadaWindowState
    extends State<_EditarJornadaWindow> {
  late DateTime _fecha;

  final Map<String, String> _entradas = {};
  final Map<String, String> _salidas = {};

  String? _error;

  @override
  void initState() {
    super.initState();

    _fecha = DateTime.tryParse(
          widget.jornada.fechaTrabajo,
        ) ??
        DateTime.now();

    for (final registro in widget.jornada.registros) {
      final id =
          registro['personalId']?.toString() ?? '';

      if (id.isEmpty) continue;

      _entradas[id] =
          registro['entrada']?.toString() ?? '07:00';

      _salidas[id] =
          registro['salida']?.toString() ?? '17:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final obra =
        AppData.buscarObraPorId(widget.jornada.obraId);

    final asignacion =
        AppData.buscarCuadrillaPorId(
      widget.jornada.asignacionId,
    );

    final encargado = asignacion == null
        ? null
        : AppData.buscarPersonalPorId(
            asignacion['encargadoId']?.toString() ?? '',
          );

    return _MacWindow(
      width: 1120,
      title: 'Editar jornada',
      subtitle:
          'Folio ${obra?['folio']?.toString() ?? '—'}',
      onClose: () => Navigator.pop(context, false),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MacButton(
            label: 'Cancelar',
            onPressed: () => Navigator.pop(context, false),
          ),
          const SizedBox(width: 8),
          _MacButton(
            icon: CupertinoIcons.checkmark,
            label: 'Guardar cambios',
            primary: true,
            onPressed: _guardar,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoField(
                  label: 'Obra',
                  value: obra?['nombre']?.toString() ?? '—',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoField(
                  label: 'Encargado',
                  value: encargado?['nombre']?.toString() ?? '—',
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 210,
                child: _MacDateField(
                  label: 'Fecha de trabajo',
                  value: _fecha,
                  onChanged: (date) {
                    if (date == null) return;
                    setState(() {
                      _fecha = date;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _TableHeader(
            editable: true,
          ),
          const SizedBox(height: 7),
          Expanded(
            child: ListView.separated(
              itemCount: widget.jornada.registros.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final registro =
                    widget.jornada.registros[index];

                final id =
                    registro['personalId']?.toString() ?? '';

                final persona = AppData.buscarPersonalPorId(id);

                return _EditarRegistroRow(
                  registro: registro,
                  persona: persona,
                  entrada: _entradas[id] ?? '07:00',
                  salida: _salidas[id] ?? '17:00',
                  onEntrada: () =>
                      _seleccionarHora(id, true),
                  onSalida: () =>
                      _seleccionarHora(id, false),
                );
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(text: _error!),
          ],
        ],
      ),
    );
  }

  Future<void> _seleccionarHora(
    String id,
    bool entrada,
  ) async {
    final actual = entrada
        ? (_entradas[id] ?? '07:00')
        : (_salidas[id] ?? '17:00');

    final parts = actual.split(':');

    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 7,
      minute: int.tryParse(
            parts.length > 1 ? parts[1] : '0',
          ) ??
          0,
    );

    final result = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (result == null) return;

    final value =
        '${result.hour.toString().padLeft(2, '0')}:'
        '${result.minute.toString().padLeft(2, '0')}';

    setState(() {
      if (entrada) {
        _entradas[id] = value;
      } else {
        _salidas[id] = value;
      }
    });
  }

  void _guardar() {
    setState(() {
      _error = null;
    });

    final nuevaFecha = _fechaFormato(_fecha);

    final ids = widget.jornada.registros
        .map((e) => e['personalId']?.toString())
        .whereType<String>()
        .toSet();

    for (final registro in AppData.asistencias) {
      final mismoPersonal =
          ids.contains(registro['personalId']?.toString());

      if (!mismoPersonal) continue;

      final mismoTrabajo =
          registro['obraId']?.toString() ==
              widget.jornada.obraId &&
          registro['asignacionId']?.toString() ==
              widget.jornada.asignacionId;

      if (!mismoTrabajo) continue;

      final mismoId =
          widget.jornada.registros.any(
        (original) =>
            original['id']?.toString() ==
            registro['id']?.toString(),
      );

      if (!mismoId &&
          registro['fechaTrabajo']?.toString() ==
              nuevaFecha) {
        setState(() {
          _error =
              'Ya existe una jornada para uno de los trabajadores en esa fecha.';
        });
        return;
      }
    }

    for (final registro in AppData.asistencias) {
      final pertenece = widget.jornada.registros.any(
        (original) =>
            original['id']?.toString() ==
            registro['id']?.toString(),
      );

      if (!pertenece) continue;

      final id =
          registro['personalId']?.toString() ?? '';

      final entrada =
          _entradas[id] ??
              registro['entrada']?.toString() ??
              '07:00';

      final salida =
          _salidas[id] ??
              registro['salida']?.toString() ??
              '17:00';

      final horas = _calcularHoras(
        entrada,
        salida,
      );

      registro['fechaTrabajo'] = nuevaFecha;
      registro['entrada'] = entrada;
      registro['salida'] = salida;
      registro['horasTrabajadas'] = horas.trabajadas;
      registro['horasExtra'] = horas.extra;
    }

    Navigator.pop(context, true);
  }
}

/* =========================================================
   REGISTRO COMPLETO
========================================================= */

class _RegistroCompletoWindow extends StatelessWidget {
  final _JornadaData jornada;

  const _RegistroCompletoWindow({
    required this.jornada,
  });

  @override
  Widget build(BuildContext context) {
    final obra =
        AppData.buscarObraPorId(jornada.obraId);

    final asignacion =
        AppData.buscarCuadrillaPorId(
      jornada.asignacionId,
    );

    final encargado = asignacion == null
        ? null
        : AppData.buscarPersonalPorId(
            asignacion['encargadoId']?.toString() ?? '',
          );

    final totalTrabajadas =
        jornada.registros.fold<double>(
      0,
      (sum, registro) =>
          sum + _toDouble(registro['horasTrabajadas']),
    );

    final totalExtra =
        jornada.registros.fold<double>(
      0,
      (sum, registro) =>
          sum + _toDouble(registro['horasExtra']),
    );

    return _MacWindow(
      width: 1260,
      title: 'Registro de asistencia',
      subtitle:
          'Folio ${obra?['folio']?.toString() ?? '—'}',
      onClose: () => Navigator.pop(context),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _MacButton(
            label: 'Cerrar',
            primary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _WindowInfoBlock(
                  label: 'Obra',
                  value: obra?['nombre']?.toString() ?? '—',
                  icon: CupertinoIcons.building_2_fill,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WindowInfoBlock(
                  label: 'Encargado',
                  value:
                      encargado?['nombre']?.toString() ?? '—',
                  icon: CupertinoIcons.person_fill,
                ),
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                value: '${jornada.registros.length}',
                label: 'Personal',
              ),
              const SizedBox(width: 10),
              _SummaryCard(
                value: _formatHours(totalTrabajadas),
                label: 'Horas',
              ),
              const SizedBox(width: 10),
              _SummaryCard(
                value: _formatHours(totalExtra),
                label: 'Extra',
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Text(
                'Detalle de la jornada',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const Spacer(),
              Text(
                _fechaCompleta(jornada.fechaTrabajo),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6E6E73),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const _TableHeader(
            editable: false,
          ),
          const SizedBox(height: 7),
          Expanded(
            child: ListView.separated(
              itemCount: jornada.registros.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 5),
              itemBuilder: (context, index) {
                return _RegistroDetalleRow(
                  registro: jornada.registros[index],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _FechaRegistro(
            registro: jornada.registros.isEmpty
                ? null
                : jornada.registros.first,
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   MAC WINDOW
========================================================= */

class _MacWindow extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Widget child;
  final Widget footer;

  const _MacWindow({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.child,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final dialogWidth =
        width.clamp(720.0, screen.width - 48);

    final dialogHeight =
        (screen.height - 70).clamp(540.0, 900.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFDCDCE1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 45,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _MacWindowBar(
              title: title,
              subtitle: subtitle,
              onClose: onClose,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  18,
                ),
                child: child,
              ),
            ),
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FA),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5EA),
                  ),
                ),
              ),
              child: footer,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacWindowBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _MacWindowBar({
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5EA),
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              _WindowDot(
                color: const Color(0xFFFF5F57),
                onTap: onClose,
              ),
              const SizedBox(width: 7),
              const _WindowDot(
                color: Color(0xFFFFBD2E),
              ),
              const SizedBox(width: 7),
              const _WindowDot(
                color: Color(0xFF28C840),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 70),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  const _WindowDot({
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (onTap == null) return dot;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: dot,
      ),
    );
  }
}

/* =========================================================
   ROWS
========================================================= */

class _HorarioEditRow extends StatelessWidget {
  final Map<String, dynamic> persona;
  final String entrada;
  final String salida;
  final VoidCallback onEntrada;
  final VoidCallback onSalida;

  const _HorarioEditRow({
    required this.persona,
    required this.entrada,
    required this.salida,
    required this.onEntrada,
    required this.onSalida,
  });

  @override
  Widget build(BuildContext context) {
    final horas = _calcularHoras(entrada, salida);

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8ED),
        ),
      ),
      child: Row(
        children: [
          _Avatar(
            persona: persona,
            size: 38,
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 3,
            child: _PersonaName(
              persona: persona,
            ),
          ),
          Expanded(
            flex: 2,
            child: _PuestoCell(
              persona: persona,
            ),
          ),
          Expanded(
            child: _HorarioButton(
              value: entrada,
              onPressed: onEntrada,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _HorarioButton(
              value: salida,
              onPressed: onSalida,
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 76,
            child: _HourValue(
              value: _formatHours(horas.trabajadas),
            ),
          ),
          SizedBox(
            width: 65,
            child: _HourValue(
              value: _formatHours(horas.extra),
              extra: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditarRegistroRow extends StatelessWidget {
  final Map<String, dynamic> registro;
  final Map<String, dynamic>? persona;
  final String entrada;
  final String salida;
  final VoidCallback onEntrada;
  final VoidCallback onSalida;

  const _EditarRegistroRow({
    required this.registro,
    required this.persona,
    required this.entrada,
    required this.salida,
    required this.onEntrada,
    required this.onSalida,
  });

  @override
  Widget build(BuildContext context) {
    final datosPersona = persona ??
        {
          'nombre': registro['nombre']?.toString() ?? '',
          'puesto': registro['puesto']?.toString() ?? '',
          'nss': registro['nss']?.toString() ?? '',
          'foto': registro['foto']?.toString() ?? '',
        };

    final horas = _calcularHoras(
      entrada,
      salida,
    );

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
        ),
      ),
      child: Row(
        children: [
          _Avatar(
            persona: datosPersona,
            size: 38,
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 3,
            child: _PersonaName(
              persona: datosPersona,
            ),
          ),
          Expanded(
            flex: 2,
            child: _PuestoCell(
              persona: datosPersona,
            ),
          ),
          Expanded(
            child: _HorarioButton(
              value: entrada,
              onPressed: onEntrada,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _HorarioButton(
              value: salida,
              onPressed: onSalida,
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 76,
            child: _HourValue(
              value: _formatHours(horas.trabajadas),
            ),
          ),
          SizedBox(
            width: 65,
            child: _HourValue(
              value: _formatHours(horas.extra),
              extra: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroDetalleRow extends StatelessWidget {
  final Map<String, dynamic> registro;

  const _RegistroDetalleRow({
    required this.registro,
  });

  @override
  Widget build(BuildContext context) {
    final horasTrabajadas =
        _toDouble(registro['horasTrabajadas']);

    final horasExtra =
        _toDouble(registro['horasExtra']);

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8E8ED),
        ),
      ),
      child: Row(
        children: [
          _Avatar(
            persona: registro,
            size: 38,
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 3,
            child: _PersonaName(
              persona: registro,
            ),
          ),
          Expanded(
            flex: 2,
            child: _PuestoCell(
              persona: registro,
            ),
          ),
          Expanded(
            child: _TimeCell(
              value: registro['entrada']?.toString() ?? '—',
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: _TimeCell(
              value: registro['salida']?.toString() ?? '—',
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 76,
            child: _HourValue(
              value: _formatHours(horasTrabajadas),
            ),
          ),
          SizedBox(
            width: 65,
            child: _HourValue(
              value: _formatHours(horasExtra),
              extra: true,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   TABLE HEADER
========================================================= */

class _TableHeader extends StatelessWidget {
  final bool editable;

  const _TableHeader({
    required this.editable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Row(
        children: [
          const SizedBox(width: 49),
          const Expanded(
            flex: 3,
            child: Text(
              'PERSONAL',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'PUESTO',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'ENTRADA',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(
            width: 7,
          ),
          const Expanded(
            child: Text(
              'SALIDA',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 18),
          const SizedBox(
            width: 76,
            child: Text(
              'HORAS',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(
            width: 65,
            child: Text(
              'EXTRA',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorarioButton extends StatelessWidget {
  final String value;
  final VoidCallback onPressed;

  const _HorarioButton({
    required this.value,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: const Color(0xFFDCDCE1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.clock,
                size: 14,
                color: Color(0xFF007AFF),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  final String value;

  const _TimeCell({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE1E1E6),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1D1F),
        ),
      ),
    );
  }
}

class _HourValue extends StatelessWidget {
  final String value;
  final bool extra;

  const _HourValue({
    required this.value,
    this.extra = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: extra
            ? const Color(0xFFFF9500)
            : const Color(0xFF1D1D1F),
      ),
    );
  }
}

class _PersonaName extends StatelessWidget {
  final Map<String, dynamic> persona;

  const _PersonaName({
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          persona['nombre']?.toString() ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          persona['nss']?.toString().isNotEmpty == true
              ? 'NSS ${persona['nss']}'
              : persona['identificador']?.toString() ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _PuestoCell extends StatelessWidget {
  final Map<String, dynamic> persona;

  const _PuestoCell({
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      persona['puesto']?.toString() ??
          persona['rol']?.toString() ??
          '—',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11.5,
        color: Color(0xFF6E6E73),
      ),
    );
  }
}

/* =========================================================
   COMMON FIELDS
========================================================= */

class _MacSearchField extends StatelessWidget {
  final double width;
  final ValueChanged<String> onChanged;

  const _MacSearchField({
    required this.width,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF1D1D1F),
        ),
        decoration: InputDecoration(
          hintText: 'Buscar jornada...',
          hintStyle: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF8E8E93),
          ),
          prefixIcon: const Icon(
            CupertinoIcons.search,
            size: 16,
            color: Color(0xFF8E8E93),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE1E1E6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE1E1E6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFB8D8FF),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _MacSelectField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        icon: const Icon(
          CupertinoIcons.chevron_down,
          size: 14,
          color: Color(0xFF8E8E93),
        ),
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF1D1D1F),
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF8E8E93),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE1E1E6),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE1E1E6),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime?> onChanged;

  const _MacDateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: SizedBox(
        height: 42,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            onChanged(picked);
          },
          child: Container(
            width: double.infinity,
            height: 42,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFE1E1E6),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  size: 15,
                  color: Color(0xFF007AFF),
                ),
                const SizedBox(width: 8),
                Text(
                  _fechaCorta(_fechaFormato(value)),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;

  const _InfoField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE5E5EA),
          ),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF1D1D1F),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6E6E73),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/* =========================================================
   INFO / SUMMARY
========================================================= */

class _WindowTopInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WindowTopInfo({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF007AFF),
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF6E6E73),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WindowInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _WindowInfoBlock({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF8E8E93),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1F),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _SelectedEncargado extends StatelessWidget {
  final Map<String, dynamic> persona;

  const _SelectedEncargado({
    required this.persona,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD5E8FF),
        ),
      ),
      child: Row(
        children: [
          _Avatar(
            persona: persona,
            size: 34,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              persona['nombre']?.toString() ?? '—',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D1D1F),
              ),
            ),
          ),
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 18,
            color: Color(0xFF007AFF),
          ),
          const SizedBox(width: 6),
          const Text(
            'Encargado',
            style: TextStyle(
              fontSize: 10.5,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _FechaRegistro extends StatelessWidget {
  final Map<String, dynamic>? registro;

  const _FechaRegistro({
    required this.registro,
  });

  @override
  Widget build(BuildContext context) {
    if (registro == null) {
      return const SizedBox.shrink();
    }

    final fecha =
        registro!['fechaRegistro']?.toString() ?? '';

    return Row(
      children: [
        const Icon(
          CupertinoIcons.info_circle,
          size: 14,
          color: Color(0xFF8E8E93),
        ),
        const SizedBox(width: 6),
        Text(
          'Registro creado: ${_fechaHora(fecha)}',
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String text;

  const _EmptyInline({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;

  const _ErrorBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFD7D7),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 15,
            color: Color(0xFFFF3B30),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFFB3261E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================================================
   AVATAR
========================================================= */

class _Avatar extends StatelessWidget {
  final Map<String, dynamic> persona;
  final double size;

  const _Avatar({
    required this.persona,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final foto = persona['foto']?.toString() ?? '';

    if (foto.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          foto,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _fallback();
          },
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E5EA),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * .52,
        color: const Color(0xFF8E8E93),
      ),
    );
  }
}

/* =========================================================
   BUTTONS
========================================================= */

class _MacButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  const _MacButton({
    this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      height: 36,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          decoration: BoxDecoration(
            color: disabled
                ? const Color(0xFFE5E5EA)
                : primary
                    ? const Color(0xFF007AFF)
                    : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: primary
                  ? const Color(0xFF007AFF)
                  : const Color(0xFFDCDCE1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: disabled
                      ? const Color(0xFF8E8E93)
                      : primary
                          ? Colors.white
                          : const Color(0xFF1D1D1F),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: disabled
                      ? const Color(0xFF8E8E93)
                      : primary
                          ? Colors.white
                          : const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacSmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MacSmallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFE1E1E6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: const Color(0xFF007AFF),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _MacIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: onPressed == null
                  ? const Color(0xFFF0F0F2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0xFFE0E0E5),
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color: onPressed == null
                  ? const Color(0xFFB0B0B5)
                  : const Color(0xFF6E6E73),
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================================================
   DATA
========================================================= */

class _JornadaData {
  final String obraId;
  final String asignacionId;
  final String fechaTrabajo;
  final List<Map<String, dynamic>> registros;

  _JornadaData({
    required this.obraId,
    required this.asignacionId,
    required this.fechaTrabajo,
    required this.registros,
  });
}

class _HorasCalculadas {
  final double trabajadas;
  final double extra;

  const _HorasCalculadas({
    required this.trabajadas,
    required this.extra,
  });
}

/* =========================================================
   HELPERS
========================================================= */

_HorasCalculadas _calcularHoras(
  String entrada,
  String salida,
) {
  final e = _minutos(entrada);
  final s = _minutos(salida);

  if (e == null || s == null) {
    return const _HorasCalculadas(
      trabajadas: 0,
      extra: 0,
    );
  }

  int diferencia = s - e;

  if (diferencia < 0) {
    diferencia += 24 * 60;
  }

  final horas = diferencia / 60.0;

  return _HorasCalculadas(
    trabajadas: horas > 10 ? 10 : horas,
    extra: horas > 10 ? horas - 10 : 0,
  );
}

int? _minutos(String value) {
  final parts = value.split(':');

  if (parts.length < 2) return null;

  final hora = int.tryParse(parts[0]);
  final minuto = int.tryParse(parts[1]);

  if (hora == null || minuto == null) return null;

  if (hora < 0 ||
      hora > 23 ||
      minuto < 0 ||
      minuto > 59) {
    return null;
  }

  return hora * 60 + minuto;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}

String _formatHours(double value) {
  if (value <= 0) return '0 h';

  if (value == value.roundToDouble()) {
    return '${value.toInt()} h';
  }

  return '${value.toStringAsFixed(1)} h';
}

String _fechaFormato(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String _fechaCorta(String fecha) {
  final date = DateTime.tryParse(fecha);

  if (date == null) return fecha;

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _fechaCompleta(String fecha) {
  final date = DateTime.tryParse(fecha);

  if (date == null) return fecha;

  return '${date.day} de ${_mesLargo(date.month)} de ${date.year}';
}

String _fechaHora(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) return value;

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year} · '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _mesCorto(int month) {
  const meses = [
    '',
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  return meses[month];
}

String _mesLargo(int month) {
  const meses = [
    '',
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  return meses[month];
}