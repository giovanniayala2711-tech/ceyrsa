import 'package:flutter/material.dart';

import '../data/app_data.dart';
import 'bitacoras_screen.dart';
import 'cuadrillas_screen.dart';
import 'asistencia_screen.dart';
import 'archivos_screen.dart';

const Color _fondo = Color(0xFFF5F5F7);
const Color _blanco = Colors.white;
const Color _texto = Color(0xFF1D1D1F);
const Color _secundario = Color(0xFF6E6E73);
const Color _borde = Color(0xFFE5E5EA);
const Color _verde = Color(0xFF248A52);
const Color _verdeFondo = Color(0xFFEAF7EF);
const Color _ambar = Color(0xFF98702A);
const Color _ambarFondo = Color(0xFFFBF4E8);
const Color _rojo = Color(0xFFC43D3D);

class ObrasScreen extends StatefulWidget {
  const ObrasScreen({super.key});

  @override
  State<ObrasScreen> createState() => _ObrasScreenState();
}

class _ObrasScreenState extends State<ObrasScreen> {
  final TextEditingController _busquedaController = TextEditingController();

  String _busqueda = '';
  String _filtroEstado = 'Todas';

  List<Map<String, dynamic>> get _obras => AppData.obras
      .map((obra) => Map<String, dynamic>.from(obra))
      .toList();

  String _valor(Map<String, dynamic> mapa, String campo) {
    final valor = mapa[campo];
    if (valor == null || valor.toString().trim().isEmpty) return '';
    return valor.toString().trim();
  }

  Map<String, dynamic>? _buscarPersona(String? id) {
    if (id == null || id.isEmpty) return null;

    try {
      final persona = AppData.buscarPersonalPorId(id);
      if (persona != null) {
        return Map<String, dynamic>.from(persona);
      }
    } catch (_) {}

    for (final persona in AppData.personal) {
      if (persona['id']?.toString() == id) {
        return Map<String, dynamic>.from(persona);
      }
    }

    return null;
  }

  String _nombreEncargado(Map<String, dynamic> obra) {
    final guardado = _valor(obra, 'encargado');
    if (guardado.isNotEmpty && guardado != 'Sin asignar') return guardado;

    final persona = _buscarPersona(_valor(obra, 'encargadoId'));
    final nombre = persona?['nombre']?.toString().trim() ?? '';

    return nombre.isEmpty ? 'Sin asignar' : nombre;
  }

  Map<String, dynamic>? _encargadoDe(Map<String, dynamic> obra) =>
      _buscarPersona(_valor(obra, 'encargadoId'));

  String _iniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();

    if (partes.isEmpty) return '—';
    if (partes.length == 1) return partes.first[0].toUpperCase();

    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return _verde;
      case 'suspendida':
        return _ambar;
      default:
        return _secundario;
    }
  }

  Color _fondoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'activa':
        return _verdeFondo;
      case 'suspendida':
        return _ambarFondo;
      default:
        return const Color(0xFFF0F0F2);
    }
  }

  List<Map<String, dynamic>> get _obrasFiltradas {
    final consulta = _busqueda.trim().toLowerCase();

    return _obras.where((obra) {
      final campos = [
        _valor(obra, 'folio'),
        _valor(obra, 'nombre'),
        _valor(obra, 'cliente'),
        _valor(obra, 'ubicacion'),
        _nombreEncargado(obra),
        _valor(obra, 'gerenteTerritorio'),
      ].join(' ').toLowerCase();

      final coincideTexto = consulta.isEmpty || campos.contains(consulta);
      final estado = _valor(obra, 'estado').toLowerCase();

      final coincideEstado = _filtroEstado == 'Todas' ||
          (_filtroEstado == 'Activas' && estado == 'activa') ||
          (_filtroEstado == 'Suspendidas' && estado == 'suspendida') ||
          (_filtroEstado == 'Finalizadas' && estado == 'finalizada');

      return coincideTexto && coincideEstado;
    }).toList();
  }

  int _contarEstado(String estado) => _obras
      .where(
        (obra) =>
            _valor(obra, 'estado').toLowerCase() == estado.toLowerCase(),
      )
      .length;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF323236),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _abrirFormulario({Map<String, dynamic>? obra}) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FormularioObraDialog(
        obra: obra,
        personal: AppData.personal
            .map((persona) => Map<String, dynamic>.from(persona))
            .toList(),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {});
      _mensaje(
        obra == null
            ? 'Obra creada correctamente.'
            : 'Cambios guardados correctamente.',
      );
    }
  }

  Future<void> _eliminarObra(Map<String, dynamic> obra) async {
    final nombre = _valor(obra, 'nombre');
    final folio = _valor(obra, 'folio');

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _blanco,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _borde),
        ),
        title: const Text(
          'Eliminar obra',
          style: TextStyle(
            color: _texto,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '¿Deseas eliminar "$nombre", folio $folio? Esta acción no se puede deshacer.',
          style: const TextStyle(
            color: _secundario,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: _secundario),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: OutlinedButton.styleFrom(
              foregroundColor: _rojo,
              side: const BorderSide(color: _borde),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    setState(() {
      AppData.obras.removeWhere(
        (elemento) => elemento['id']?.toString() == obra['id']?.toString(),
      );
    });

    _mensaje('Obra eliminada.');
  }

  void _abrirBitacoras(Map<String, dynamic> obra) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BitacorasScreen(obra: obra),
      ),
    );
  }

  void _abrirModulo(Widget pantalla) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => pantalla),
    );
  }

  void _verFicha(Map<String, dynamic> obra) {
    showDialog<void>(
      context: context,
      builder: (_) => _FichaObraDialog(
        obra: obra,
        encargado: _encargadoDe(obra),
        nombreEncargado: _nombreEncargado(obra),
        iniciales: _iniciales,
        colorEstado: _colorEstado(_valor(obra, 'estado')),
        fondoEstado: _fondoEstado(_valor(obra, 'estado')),
        onEditar: () {
          Navigator.of(context).pop();
          _abrirFormulario(obra: obra);
        },
        onBitacoras: () {
          Navigator.of(context).pop();
          _abrirBitacoras(obra);
        },
        onCuadrillas: () {
          Navigator.of(context).pop();
          _abrirModulo(CuadrillasScreen());
        },
        onAsistencia: () {
          Navigator.of(context).pop();
          _abrirModulo(AsistenciaScreen());
        },
        onArchivos: () {
          Navigator.of(context).pop();
          _abrirModulo(ArchivosScreen());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obras = _obrasFiltradas;

    return Scaffold(
      backgroundColor: _fondo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 720;

            return SingleChildScrollView(
              padding: EdgeInsets.all(compacto ? 16 : 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _encabezado(compacto),
                      const SizedBox(height: 25),
                      _resumen(compacto),
                      const SizedBox(height: 22),
                      _buscador(compacto),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Registro de obras',
                              style: TextStyle(
                                color: _texto,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          Text(
                            '${obras.length} ${obras.length == 1 ? 'obra' : 'obras'}',
                            style: const TextStyle(
                              color: _secundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      if (obras.isEmpty)
                        _vacio()
                      else
                        ...obras.map(
                          (obra) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TarjetaObra(
                              obra: obra,
                              encargado: _encargadoDe(obra),
                              nombreEncargado: _nombreEncargado(obra),
                              iniciales: _iniciales,
                              colorEstado:
                                  _colorEstado(_valor(obra, 'estado')),
                              fondoEstado:
                                  _fondoEstado(_valor(obra, 'estado')),
                              compacto: compacto,
                              onTap: () => _verFicha(obra),
                              onEditar: () => _abrirFormulario(obra: obra),
                              onEliminar: () => _eliminarObra(obra),
                              onBitacoras: () => _abrirBitacoras(obra),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado(bool compacto) {
    return Row(
      children: [
        Container(
          width: compacto ? 44 : 48,
          height: compacto ? 44 : 48,
          decoration: BoxDecoration(
            color: _blanco,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _borde),
          ),
          child: const Icon(
            Icons.business_outlined,
            color: _texto,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Obras',
                style: TextStyle(
                  color: _texto,
                  fontSize: compacto ? 25 : 29,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Proyectos, seguimiento y documentación',
                style: TextStyle(color: _secundario, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(compacto ? 'Nueva' : 'Nueva obra'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _texto,
            backgroundColor: _blanco,
            side: const BorderSide(color: _borde),
            padding: EdgeInsets.symmetric(
              horizontal: compacto ? 11 : 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _resumen(bool compacto) {
    final datos = [
      _ResumenDato('Total de obras', _obras.length, Icons.domain_outlined),
      _ResumenDato('Activas', _contarEstado('Activa'), Icons.circle_outlined),
      _ResumenDato(
        'Finalizadas',
        _contarEstado('Finalizada'),
        Icons.check_circle_outline_rounded,
      ),
      _ResumenDato(
        'Suspendidas',
        _contarEstado('Suspendida'),
        Icons.pause_circle_outline_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 1050
            ? 4
            : constraints.maxWidth >= 500
                ? 2
                : 1;
        final ancho =
            (constraints.maxWidth - (columnas - 1) * 11) / columnas;

        return Wrap(
          spacing: 11,
          runSpacing: 11,
          children: datos.map((dato) {
            return SizedBox(
              width: ancho,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _blanco,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: _borde),
                ),
                child: Row(
                  children: [
                    Icon(dato.icono, color: _secundario, size: 21),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dato.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _secundario,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dato.valor.toString(),
                            style: const TextStyle(
                              color: _texto,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buscador(bool compacto) {
    final campo = TextField(
      controller: _busquedaController,
      onChanged: (valor) => setState(() => _busqueda = valor),
      style: const TextStyle(color: _texto, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Buscar folio, proyecto, cliente o encargado',
        hintStyle: const TextStyle(color: _secundario, fontSize: 12),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: _secundario,
        ),
        suffixIcon: _busqueda.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _busquedaController.clear();
                  setState(() => _busqueda = '');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: _secundario,
                  size: 18,
                ),
              ),
        filled: true,
        fillColor: _fondo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFC9C9CE)),
        ),
      ),
    );

    final filtro = DropdownButtonFormField<String>(
      value: _filtroEstado,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: _secundario,
      ),
      decoration: InputDecoration(
        labelText: 'Estado',
        labelStyle: const TextStyle(color: _secundario, fontSize: 11),
        filled: true,
        fillColor: _fondo,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Todas', child: Text('Todas')),
        DropdownMenuItem(value: 'Activas', child: Text('Activas')),
        DropdownMenuItem(value: 'Finalizadas', child: Text('Finalizadas')),
        DropdownMenuItem(value: 'Suspendidas', child: Text('Suspendidas')),
      ],
      onChanged: (valor) {
        if (valor != null) setState(() => _filtroEstado = valor);
      },
    );

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _borde),
      ),
      child: compacto
          ? Column(
              children: [
                campo,
                const SizedBox(height: 9),
                SizedBox(width: double.infinity, child: filtro),
              ],
            )
          : Row(
              children: [
                Expanded(child: campo),
                const SizedBox(width: 11),
                SizedBox(width: 175, child: filtro),
              ],
            ),
    );
  }

  Widget _vacio() {
    final filtrando = _busqueda.isNotEmpty || _filtroEstado != 'Todas';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 42),
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borde),
      ),
      child: Column(
        children: [
          const Icon(Icons.domain_outlined, color: _secundario, size: 34),
          const SizedBox(height: 13),
          Text(
            filtrando ? 'No se encontraron obras' : 'Aún no hay obras',
            style: const TextStyle(
              color: _texto,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtrando
                ? 'Prueba con otra búsqueda o cambia el filtro.'
                : 'Registra una obra para comenzar.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _secundario,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          OutlinedButton(
            onPressed: filtrando
                ? () {
                    _busquedaController.clear();
                    setState(() {
                      _busqueda = '';
                      _filtroEstado = 'Todas';
                    });
                  }
                : () => _abrirFormulario(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _texto,
              side: const BorderSide(color: _borde),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: Text(filtrando ? 'Limpiar filtros' : 'Crear obra'),
          ),
        ],
      ),
    );
  }
}

class _ResumenDato {
  final String titulo;
  final int valor;
  final IconData icono;

  const _ResumenDato(this.titulo, this.valor, this.icono);
}

class _TarjetaObra extends StatelessWidget {
  final Map<String, dynamic> obra;
  final Map<String, dynamic>? encargado;
  final String nombreEncargado;
  final String Function(String) iniciales;
  final Color colorEstado;
  final Color fondoEstado;
  final bool compacto;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onBitacoras;

  const _TarjetaObra({
    required this.obra,
    required this.encargado,
    required this.nombreEncargado,
    required this.iniciales,
    required this.colorEstado,
    required this.fondoEstado,
    required this.compacto,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
    required this.onBitacoras,
  });

  String _dato(String campo) {
    final valor = obra[campo]?.toString().trim() ?? '';
    return valor.isEmpty ? '—' : valor;
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _dato('nombre');
    final cliente = _dato('cliente');
    final folio = _dato('folio');
    final estado = _dato('estado');
    final ubicacion = _dato('ubicacion');

    return Material(
      color: _blanco,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: EdgeInsets.all(compacto ? 15 : 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: _borde),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.018),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Etiqueta(
                        texto: 'Folio $folio',
                        color: const Color(0xFFF0F0F2),
                        textoColor: _texto,
                      ),
                      _Etiqueta(
                        texto: estado,
                        color: fondoEstado,
                        textoColor: colorEstado,
                        mostrarPunto: true,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Ver información de la obra',
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    size: 21,
                    color: _secundario,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    size: 22,
                    color: _secundario,
                  ),
                  color: _blanco,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                    side: const BorderSide(color: _borde),
                  ),
                  onSelected: (opcion) {
                    switch (opcion) {
                      case 'editar':
                        onEditar();
                        break;
                      case 'bitacoras':
                        onBitacoras();
                        break;
                      case 'eliminar':
                        onEliminar();
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: _OpcionMenu(
                        icono: Icons.edit_outlined,
                        texto: 'Editar obra',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'bitacoras',
                      child: _OpcionMenu(
                        icono: Icons.note_alt_outlined,
                        texto: 'Abrir bitácoras',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: _OpcionMenu(
                        icono: Icons.delete_outline_rounded,
                        texto: 'Eliminar obra',
                        peligro: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 11),
            Text(
              nombre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _texto,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cliente == '—' ? 'Cliente sin registrar' : cliente,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _secundario, fontSize: 12),
            ),
            const SizedBox(height: 15),
            const Divider(height: 1, color: _borde),
            const SizedBox(height: 13),
            Wrap(
              spacing: 19,
              runSpacing: 10,
              children: [
                _DatoCompacto(
                  icono: Icons.location_on_outlined,
                  texto: ubicacion,
                ),
                _DatoCompacto(
                  icono: Icons.person_outline_rounded,
                  texto: nombreEncargado,
                ),
                if (_dato('gerenteTerritorio') != '—')
                  _DatoCompacto(
                    icono: Icons.badge_outlined,
                    texto: _dato('gerenteTerritorio'),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _AvatarObra(
                  persona: encargado,
                  nombre: nombreEncargado,
                  iniciales: iniciales,
                  size: 36,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Encargado asignado',
                        style: TextStyle(
                          color: _secundario,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nombreEncargado,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _texto,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compacto) ...[
                  const SizedBox(width: 8),
                  _BotonDiscreto(
                    texto: 'Editar',
                    icono: Icons.edit_outlined,
                    onPressed: onEditar,
                  ),
                  const SizedBox(width: 7),
                  _BotonDiscreto(
                    texto: 'Bitácoras',
                    icono: Icons.note_alt_outlined,
                    onPressed: onBitacoras,
                  ),
                ],
              ],
            ),
            if (compacto) ...[
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _BotonDiscreto(
                      texto: 'Editar',
                      icono: Icons.edit_outlined,
                      onPressed: onEditar,
                      expandido: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BotonDiscreto(
                      texto: 'Bitácoras',
                      icono: Icons.note_alt_outlined,
                      onPressed: onBitacoras,
                      expandido: true,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  final Color textoColor;
  final bool mostrarPunto;

  const _Etiqueta({
    required this.texto,
    required this.color,
    required this.textoColor,
    this.mostrarPunto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mostrarPunto) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: textoColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: TextStyle(
              color: textoColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoCompacto extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _DatoCompacto({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: _secundario),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secundario,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarObra extends StatelessWidget {
  final Map<String, dynamic>? persona;
  final String nombre;
  final String Function(String) iniciales;
  final double size;

  const _AvatarObra({
    required this.persona,
    required this.nombre,
    required this.iniciales,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final foto =
        persona?['foto']?.toString() ?? persona?['fotoUrl']?.toString() ?? '';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F2),
        shape: BoxShape.circle,
        border: Border.all(color: _borde),
      ),
      child: foto.startsWith('http')
          ? Image.network(
              foto,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        iniciales(nombre),
        style: const TextStyle(
          color: _texto,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BotonDiscreto extends StatelessWidget {
  final String texto;
  final IconData icono;
  final VoidCallback onPressed;
  final bool expandido;

  const _BotonDiscreto({
    required this.texto,
    required this.icono,
    required this.onPressed,
    this.expandido = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono, size: 15),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        foregroundColor: _texto,
        backgroundColor: _blanco,
        side: const BorderSide(color: _borde),
        padding: EdgeInsets.symmetric(
          horizontal: expandido ? 8 : 11,
          vertical: 11,
        ),
        minimumSize: Size(expandido ? 0 : 0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OpcionMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool peligro;

  const _OpcionMenu({
    required this.icono,
    required this.texto,
    this.peligro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icono,
          size: 17,
          color: peligro ? _rojo : _texto,
        ),
        const SizedBox(width: 10),
        Text(
          texto,
          style: TextStyle(
            color: peligro ? _rojo : _texto,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FormularioObraDialog extends StatefulWidget {
  final Map<String, dynamic>? obra;
  final List<Map<String, dynamic>> personal;

  const _FormularioObraDialog({
    required this.obra,
    required this.personal,
  });

  @override
  State<_FormularioObraDialog> createState() => _FormularioObraDialogState();
}

class _FormularioObraDialogState extends State<_FormularioObraDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _folioController;
  late final TextEditingController _nombreController;
  late final TextEditingController _clienteController;
  late final TextEditingController _ubicacionController;
  late final TextEditingController _gerenteController;

  String _estado = 'Activa';
  String? _encargadoId;
  bool _guardando = false;

  bool get _editando => widget.obra != null;

  @override
  void initState() {
    super.initState();

    final obra = widget.obra;

    _folioController =
        TextEditingController(text: obra?['folio']?.toString() ?? '');
    _nombreController =
        TextEditingController(text: obra?['nombre']?.toString() ?? '');
    _clienteController =
        TextEditingController(text: obra?['cliente']?.toString() ?? '');
    _ubicacionController =
        TextEditingController(text: obra?['ubicacion']?.toString() ?? '');
    _gerenteController = TextEditingController(
      text: obra?['gerenteTerritorio']?.toString() ?? '',
    );

    final estado = obra?['estado']?.toString() ?? 'Activa';
    if (['Activa', 'Suspendida', 'Finalizada'].contains(estado)) {
      _estado = estado;
    }

    final id = obra?['encargadoId']?.toString();
    if (id != null &&
        widget.personal.any((persona) => persona['id']?.toString() == id)) {
      _encargadoId = id;
    }
  }

  @override
  void dispose() {
    _folioController.dispose();
    _nombreController.dispose();
    _clienteController.dispose();
    _ubicacionController.dispose();
    _gerenteController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _encargados =>
      widget.personal.where((persona) {
        final rol = persona['rol']?.toString().toLowerCase() ?? '';
        final estado = persona['estado']?.toString().toLowerCase() ?? '';
        return rol == 'encargado' && estado != 'baja';
      }).toList();

  String _nombrePersona(Map<String, dynamic> persona) {
    final nombre = persona['nombre']?.toString().trim() ?? '';
    return nombre.isEmpty ? 'Personal sin nombre' : nombre;
  }

  void _guardar() {
    if (_guardando || !_formKey.currentState!.validate()) return;

    final folio = _folioController.text.trim();
    final existente = widget.obra;

    final duplicado = AppData.obras.any((obra) {
      final mismoFolio =
          obra['folio']?.toString().trim().toLowerCase() == folio.toLowerCase();
      final mismaObra = existente != null &&
          obra['id']?.toString() == existente['id']?.toString();
      return mismoFolio && !mismaObra;
    });

    if (duplicado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ese folio ya está registrado en otra obra.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      Map<String, dynamic>? personaSeleccionada;

      for (final persona in _encargados) {
        if (persona['id']?.toString() == _encargadoId) {
          personaSeleccionada = persona;
          break;
        }
      }

      final datos = <String, dynamic>{
        if (existente != null) ...existente,
        'id': existente?['id']?.toString() ??
            'OBR-${DateTime.now().microsecondsSinceEpoch}',
        'folio': folio,
        'nombre': _nombreController.text.trim(),
        'cliente': _clienteController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'estado': _estado,
        'encargadoId': _encargadoId,
        'encargado': personaSeleccionada == null
            ? 'Sin asignar'
            : _nombrePersona(personaSeleccionada),
        'gerenteTerritorio': _gerenteController.text.trim(),
      };

      if (existente == null) {
        AppData.obras.add(datos);
      } else {
        final indice = AppData.obras.indexWhere(
          (obra) => obra['id']?.toString() == existente['id']?.toString(),
        );

        if (indice >= 0) {
          AppData.obras[indice] = datos;
        } else {
          AppData.obras.add(datos);
        }
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la obra: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final ancho = anchoPantalla > 820 ? 740.0 : anchoPantalla - 32;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: ancho,
        constraints: BoxConstraints(
          maxWidth: 740,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: _blanco,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _borde),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 17, 18),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: _fondo,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _borde),
                    ),
                    child: Icon(
                      _editando
                          ? Icons.edit_outlined
                          : Icons.add_business_outlined,
                      color: _texto,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editando ? 'Editar obra' : 'Nueva obra',
                          style: const TextStyle(
                            color: _texto,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _editando
                              ? 'Actualiza los datos del proyecto'
                              : 'Registra un nuevo proyecto de CEYRSA',
                          style: const TextStyle(
                            color: _secundario,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed:
                        _guardando ? null : () => Navigator.pop(context, false),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _secundario,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _borde),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 21, 22, 23),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TituloSeccion(
                        titulo: 'Información del proyecto',
                        subtitulo: 'Datos generales e identificación de la obra.',
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final dosColumnas = constraints.maxWidth >= 500;
                          final anchoCampo = dosColumnas
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              SizedBox(
                                width: anchoCampo,
                                child: _campo(
                                  controller: _folioController,
                                  etiqueta: 'Folio de obra',
                                  ayuda: 'Ej. 45872',
                                  icono: Icons.tag_outlined,
                                  obligatorio: true,
                                ),
                              ),
                              SizedBox(
                                width: anchoCampo,
                                child: _campo(
                                  controller: _nombreController,
                                  etiqueta: 'Nombre del proyecto',
                                  ayuda: 'Nombre de la obra',
                                  icono: Icons.domain_outlined,
                                  obligatorio: true,
                                ),
                              ),
                              SizedBox(
                                width: anchoCampo,
                                child: _campo(
                                  controller: _clienteController,
                                  etiqueta: 'Cliente',
                                  ayuda: 'Nombre del cliente',
                                  icono: Icons.business_outlined,
                                  obligatorio: true,
                                ),
                              ),
                              SizedBox(
                                width: anchoCampo,
                                child: _campo(
                                  controller: _ubicacionController,
                                  etiqueta: 'Ubicación',
                                  ayuda: 'Dirección o zona de la obra',
                                  icono: Icons.location_on_outlined,
                                  obligatorio: true,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 25),
                      const _TituloSeccion(
                        titulo: 'Asignación y seguimiento',
                        subtitulo: 'Responsable, gerencia y estado actual.',
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final dosColumnas = constraints.maxWidth >= 500;
                          final anchoCampo = dosColumnas
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 14,
                            children: [
                              SizedBox(
                                width: anchoCampo,
                                child: DropdownButtonFormField<String?>(
                                  value: _encargadoId,
                                  isExpanded: true,
                                  decoration: _decoracion(
                                    'Encargado asignado',
                                    Icons.person_outline_rounded,
                                  ),
                                  hint: const Text(
                                    'Seleccionar encargado',
                                    style: TextStyle(
                                      color: _secundario,
                                      fontSize: 12,
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Sin asignar'),
                                    ),
                                    ..._encargados.map((persona) {
                                      final id =
                                          persona['id']?.toString() ?? '';
                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          _nombrePersona(persona),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (valor) {
                                    setState(() => _encargadoId = valor);
                                  },
                                ),
                              ),
                              SizedBox(
                                width: anchoCampo,
                                child: DropdownButtonFormField<String>(
                                  value: _estado,
                                  isExpanded: true,
                                  decoration: _decoracion(
                                    'Estado de la obra',
                                    Icons.circle_outlined,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Activa',
                                      child: Text('Activa'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Suspendida',
                                      child: Text('Suspendida'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Finalizada',
                                      child: Text('Finalizada'),
                                    ),
                                  ],
                                  onChanged: (valor) {
                                    if (valor != null) {
                                      setState(() => _estado = valor);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: constraints.maxWidth,
                                child: _campo(
                                  controller: _gerenteController,
                                  etiqueta: 'Gerente de territorio',
                                  ayuda: 'Nombre del gerente responsable',
                                  icono: Icons.badge_outlined,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: _borde),
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 13, 19, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _guardando ? null : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      foregroundColor: _secundario,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _texto,
                      backgroundColor: _blanco,
                      side: const BorderSide(color: _borde),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: _texto,
                            ),
                          )
                        : Text(_editando ? 'Guardar cambios' : 'Crear obra'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required String ayuda,
    required IconData icono,
    bool obligatorio = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: _texto, fontSize: 12),
      validator: obligatorio
          ? (valor) => valor == null || valor.trim().isEmpty
              ? 'Este campo es obligatorio'
              : null
          : null,
      decoration: _decoracion(etiqueta, icono).copyWith(
        hintText: ayuda,
        hintStyle: const TextStyle(
          color: Color(0xFF9A9AA0),
          fontSize: 11,
        ),
        errorMaxLines: 2,
      ),
    );
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: _secundario, fontSize: 11),
      prefixIcon: Icon(icono, size: 18, color: _secundario),
      filled: true,
      fillColor: const Color(0xFFFAFAFB),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB9B9C0)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojo),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _rojo),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const _TituloSeccion({
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: _texto,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitulo,
          style: const TextStyle(
            color: _secundario,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _FichaObraDialog extends StatelessWidget {
  final Map<String, dynamic> obra;
  final Map<String, dynamic>? encargado;
  final String nombreEncargado;
  final String Function(String) iniciales;
  final Color colorEstado;
  final Color fondoEstado;
  final VoidCallback onEditar;
  final VoidCallback onBitacoras;
  final VoidCallback onCuadrillas;
  final VoidCallback onAsistencia;
  final VoidCallback onArchivos;

  const _FichaObraDialog({
    required this.obra,
    required this.encargado,
    required this.nombreEncargado,
    required this.iniciales,
    required this.colorEstado,
    required this.fondoEstado,
    required this.onEditar,
    required this.onBitacoras,
    required this.onCuadrillas,
    required this.onAsistencia,
    required this.onArchivos,
  });

  String _dato(String campo) {
    final valor = obra[campo]?.toString().trim() ?? '';
    return valor.isEmpty ? '—' : valor;
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: anchoPantalla > 700 ? 610 : anchoPantalla - 32,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: _blanco,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _borde),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 19, 15, 18),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: _fondo,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _borde),
                    ),
                    child: const Icon(
                      Icons.business_outlined,
                      color: _texto,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ficha de obra',
                          style: TextStyle(
                            color: _texto,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Folio ${_dato('folio')}',
                          style: const TextStyle(
                            color: _secundario,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _secundario,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _borde),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Etiqueta(
                          texto: _dato('estado'),
                          color: fondoEstado,
                          textoColor: colorEstado,
                          mostrarPunto: true,
                        ),
                        _Etiqueta(
                          texto: 'Folio ${_dato('folio')}',
                          color: _fondo,
                          textoColor: _texto,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _dato('nombre'),
                      style: const TextStyle(
                        color: _texto,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _dato('cliente'),
                      style: const TextStyle(
                        color: _secundario,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 21),
                    const Divider(height: 1, color: _borde),
                    const SizedBox(height: 18),
                    const Text(
                      'Información del proyecto',
                      style: TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 17),
                    _FilaFicha(
                      icono: Icons.tag_outlined,
                      titulo: 'Folio',
                      valor: _dato('folio'),
                    ),
                    _FilaFicha(
                      icono: Icons.business_outlined,
                      titulo: 'Cliente',
                      valor: _dato('cliente'),
                    ),
                    _FilaFicha(
                      icono: Icons.location_on_outlined,
                      titulo: 'Ubicación',
                      valor: _dato('ubicacion'),
                    ),
                    _FilaFicha(
                      icono: Icons.badge_outlined,
                      titulo: 'Gerente de territorio',
                      valor: _dato('gerenteTerritorio'),
                    ),
                    const SizedBox(height: 5),
                    const Divider(height: 1, color: _borde),
                    const SizedBox(height: 18),
                    const Text(
                      'Responsable asignado',
                      style: TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        _AvatarObra(
                          persona: encargado,
                          nombre: nombreEncargado,
                          iniciales: iniciales,
                          size: 42,
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreEncargado,
                                style: const TextStyle(
                                  color: _texto,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Encargado de obra',
                                style: TextStyle(
                                  color: _secundario,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 21),
                    const Divider(height: 1, color: _borde),
                    const SizedBox(height: 17),
                    const Text(
                      'Espacio de trabajo',
                      style: TextStyle(
                        color: _texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Accede a los módulos de trabajo.',
                      style: TextStyle(
                        color: _secundario,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 13),
                    _AccesoTrabajo(
                      icono: Icons.note_alt_outlined,
                      titulo: 'Bitácoras',
                      descripcion: 'Registros y seguimiento de esta obra',
                      onTap: onBitacoras,
                    ),
                    const SizedBox(height: 9),
                    _AccesoTrabajo(
                      icono: Icons.groups_outlined,
                      titulo: 'Cuadrillas',
                      descripcion: 'Personal y organización de cuadrillas',
                      onTap: onCuadrillas,
                    ),
                    const SizedBox(height: 9),
                    _AccesoTrabajo(
                      icono: Icons.fact_check_outlined,
                      titulo: 'Mi asistencia',
                      descripcion: 'Consultar el módulo de asistencia',
                      onTap: onAsistencia,
                    ),
                    const SizedBox(height: 9),
                    _AccesoTrabajo(
                      icono: Icons.folder_open_outlined,
                      titulo: 'Archivos',
                      descripcion: 'Consultar documentos y archivos',
                      onTap: onArchivos,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: _borde),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: _secundario,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 7),
                  OutlinedButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Editar obra'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _texto,
                      side: const BorderSide(color: _borde),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccesoTrabajo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _AccesoTrabajo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _blanco,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(color: _borde),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Icon(icono, color: _secundario, size: 21),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: _texto,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        color: _secundario,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _secundario,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaFicha extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _FilaFicha({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: _secundario, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 145,
            child: Text(
              titulo,
              style: const TextStyle(
                color: _secundario,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: _texto,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}