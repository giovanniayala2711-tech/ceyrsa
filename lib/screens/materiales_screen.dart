import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MaterialesScreen extends StatefulWidget {
  const MaterialesScreen({super.key});

  @override
  State<MaterialesScreen> createState() => _MaterialesScreenState();
}

class _MaterialesScreenState extends State<MaterialesScreen> {
  // =============================================================
  // COLORES — ESTILO macOS / CEYRSA
  // =============================================================

  static const Color fondo = Color(0xFFF5F5F7);
  static const Color panel = Colors.white;
  static const Color borde = Color(0xFFE5E5EA);
  static const Color texto = Color(0xFF1D1D1F);
  static const Color textoSecundario = Color(0xFF6E6E73);

  static const Color azul = Color(0xFF007AFF);
  static const Color verde = Color(0xFF34C759);
  static const Color naranja = Color(0xFFFF9500);
  static const Color rojo = Color(0xFFFF3B30);
  static const Color morado = Color(0xFFAF52DE);

  // =============================================================
  // DATOS
  // =============================================================

  final List<Map<String, dynamic>> materiales = [];

  String busqueda = '';
  String filtroUbicacion = 'Todos';

  // =============================================================
  // FILTRO
  // =============================================================

  List<Map<String, dynamic>> get materialesFiltrados {
    final textoBusqueda = busqueda.toLowerCase().trim();

    return materiales.where((material) {
      final nombre =
          material['nombre']?.toString().toLowerCase() ?? '';

      final cantidad =
          material['cantidad']?.toString().toLowerCase() ?? '';

      final ubicacion =
          material['ubicacion']?.toString().toLowerCase() ?? '';

      final obra =
          material['obra']?.toString().toLowerCase() ?? '';

      final observaciones =
          material['observaciones']?.toString().toLowerCase() ?? '';

      final coincideBusqueda =
          textoBusqueda.isEmpty ||
          nombre.contains(textoBusqueda) ||
          cantidad.contains(textoBusqueda) ||
          ubicacion.contains(textoBusqueda) ||
          obra.contains(textoBusqueda) ||
          observaciones.contains(textoBusqueda);

      final coincideUbicacion =
          filtroUbicacion == 'Todos' ||
          material['ubicacionTipo'] == filtroUbicacion;

      return coincideBusqueda && coincideUbicacion;
    }).toList();
  }

  // =============================================================
  // BUILD
  // =============================================================

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

  // =============================================================
  // BARRA SUPERIOR
  // =============================================================

  Widget _barraSuperior() {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          bottom: BorderSide(
            color: borde,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: azul.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: azul,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Materiales',
              style: TextStyle(
                color: texto,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: verde.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 7,
                    color: verde,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sincronizado',
                    style: TextStyle(
                      color: verde,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  // =============================================================
  // CONTENIDO
  // =============================================================

  Widget _contenido() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _encabezado(),
          const SizedBox(height: 22),
          _resumen(),
          const SizedBox(height: 22),
          _barraBusqueda(),
          const SizedBox(height: 14),
          _filtros(),
          const SizedBox(height: 18),
          _encabezadoLista(),
          const SizedBox(height: 12),
          Expanded(
            child: materialesFiltrados.isEmpty
                ? _estadoVacio()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: materialesFiltrados.length,
                    itemBuilder: (context, index) {
                      return _tarjetaMaterial(
                        materialesFiltrados[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ENCABEZADO
  // =============================================================

  Widget _encabezado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materiales',
                style: TextStyle(
                  color: texto,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Control de materiales, existencias y sobrantes de CEYRSA',
                style: TextStyle(
                  color: textoSecundario,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        _botonPrincipal(
          icono: Icons.add,
          texto: 'Nuevo material',
          onPressed: _nuevoMaterial,
        ),
      ],
    );
  }

  // =============================================================
  // RESUMEN
  // =============================================================

  Widget _resumen() {
    final total = materiales.length;

    final almacen = materiales.where(
      (m) => m['ubicacionTipo'] == 'Almacén',
    ).length;

    final obra = materiales.where(
      (m) => m['ubicacionTipo'] == 'Obra',
    ).length;

    final observaciones = materiales.where(
      (m) =>
          (m['observaciones']?.toString() ?? '').trim().isNotEmpty,
    ).length;

    return Row(
      children: [
        Expanded(
          child: _tarjetaResumen(
            icono: Icons.inventory_2_outlined,
            color: azul,
            titulo: 'Materiales',
            valor: '$total',
            detalle: 'Registrados',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tarjetaResumen(
            icono: Icons.warehouse_outlined,
            color: verde,
            titulo: 'Almacén',
            valor: '$almacen',
            detalle: 'En CEYRSA',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tarjetaResumen(
            icono: Icons.location_on_outlined,
            color: naranja,
            titulo: 'En obra',
            valor: '$obra',
            detalle: 'Asignados',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _tarjetaResumen(
            icono: Icons.notes_outlined,
            color: morado,
            titulo: 'Con notas',
            valor: '$observaciones',
            detalle: 'Observaciones',
          ),
        ),
      ],
    );
  }

  Widget _tarjetaResumen({
    required IconData icono,
    required Color color,
    required String titulo,
    required String valor,
    required String detalle,
  }) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borde),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: textoSecundario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      valor,
                      style: const TextStyle(
                        color: texto,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        detalle,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textoSecundario,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BUSCADOR
  // =============================================================

  Widget _barraBusqueda() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: borde),
      ),
      child: TextField(
        onChanged: (valor) {
          setState(() {
            busqueda = valor;
          });
        },
        style: const TextStyle(
          color: texto,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: textoSecundario,
            size: 20,
          ),
          hintText:
              'Buscar por nombre, cantidad, ubicación u obra...',
          hintStyle: TextStyle(
            color: textoSecundario,
            fontSize: 14,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FILTROS
  // =============================================================

  Widget _filtros() {
    return Row(
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            color: textoSecundario,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        _filtro('Todos', Icons.apps_outlined),
        const SizedBox(width: 7),
        _filtro('Almacén', Icons.warehouse_outlined),
        const SizedBox(width: 7),
        _filtro('Obra', Icons.location_on_outlined),
        const Spacer(),
        Text(
          '${materialesFiltrados.length} material(es)',
          style: const TextStyle(
            color: textoSecundario,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _filtro(String textoFiltro, IconData icono) {
    final seleccionado = filtroUbicacion == textoFiltro;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        setState(() {
          filtroUbicacion = textoFiltro;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: seleccionado
              ? azul.withValues(alpha: .10)
              : panel,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: seleccionado
                ? azul.withValues(alpha: .30)
                : borde,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 15,
              color: seleccionado
                  ? azul
                  : textoSecundario,
            ),
            const SizedBox(width: 6),
            Text(
              textoFiltro == 'Almacén'
                  ? 'Almacén CEYRSA'
                  : textoFiltro == 'Obra'
                      ? 'En obra'
                      : 'Todos',
              style: TextStyle(
                color: seleccionado
                    ? azul
                    : textoSecundario,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // ENCABEZADO LISTA
  // =============================================================

  Widget _encabezadoLista() {
    return Row(
      children: [
        const Text(
          'Inventario',
          style: TextStyle(
            color: texto,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFF2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${materialesFiltrados.length}',
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // TARJETA MATERIAL
  // =============================================================

  Widget _tarjetaMaterial(
    Map<String, dynamic> material,
  ) {
    final bool estaEnAlmacen =
        material['ubicacionTipo'] == 'Almacén';

    final Color color =
        estaEnAlmacen ? verde : naranja;

    final IconData icono =
        estaEnAlmacen
            ? Icons.warehouse_outlined
            : Icons.location_on_outlined;

    final String nombre =
        material['nombre']?.toString() ?? 'Sin nombre';

    final String cantidad =
        material['cantidad']?.toString() ?? '';

    final String ubicacion =
        material['ubicacion']?.toString() ?? '';

    final String obra =
        material['obra']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borde),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _verMaterial(material),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icono,
                    color: color,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 14),
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
                                color: texto,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          _chipUbicacion(
                            estaEnAlmacen
                                ? 'Almacén'
                                : 'En obra',
                            color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: textoSecundario,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Cantidad: $cantidad',
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 18),
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: textoSecundario,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              ubicacion.isEmpty
                                  ? 'Sin ubicación'
                                  : ubicacion,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textoSecundario,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!estaEnAlmacen &&
                          obra.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 14,
                              color: textoSecundario,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                'Obra: $obra',
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: textoSecundario,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 19,
                    color: textoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipUbicacion(
    String textoChip,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        textoChip,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =============================================================
  // ESTADO VACÍO
  // =============================================================

  Widget _estadoVacio() {
    final hayFiltros =
        busqueda.trim().isNotEmpty ||
        filtroUbicacion != 'Todos';

    return Center(
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(34),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borde),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: azul.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 32,
                color: azul,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hayFiltros
                  ? 'No se encontraron materiales'
                  : 'No hay materiales registrados',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: texto,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              hayFiltros
                  ? 'Prueba con otra búsqueda o cambia los filtros.'
                  : 'Agrega un material para comenzar a llevar el control.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textoSecundario,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            if (!hayFiltros)
              _botonPrincipal(
                icono: Icons.add,
                texto: 'Agregar material',
                onPressed: _nuevoMaterial,
              )
            else
              _botonSecundario(
                texto: 'Limpiar filtros',
                icono: Icons.filter_alt_off_outlined,
                onPressed: () {
                  setState(() {
                    busqueda = '';
                    filtroUbicacion = 'Todos';
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // NUEVO MATERIAL
  // =============================================================

  void _nuevoMaterial() {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final ubicacionController = TextEditingController();
    final obraController = TextEditingController();
    final observacionesController = TextEditingController();

    String ubicacionTipo = 'Almacén';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _ventanaMac(
              titulo: 'Nuevo material',
              subtitulo:
                  'Registrar material en el inventario de CEYRSA',
              icono: Icons.inventory_2_outlined,
              colorIcono: azul,
              contenido: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _tituloSeccion(
                      icono: Icons.inventory_2_outlined,
                      titulo: 'Información del material',
                      subtitulo:
                          'Datos básicos del material',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller: nombreController,
                      label: 'Nombre del material',
                      hint: 'Ej. Hojuela gris',
                      icono: Icons.label_outline,
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller: cantidadController,
                            label: 'Cantidad',
                            hint: 'Ej. 3 cajas',
                            icono:
                                Icons.numbers_outlined,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: _dropdownMac(
                            valor: ubicacionTipo,
                            label: 'Ubicación',
                            icono:
                                Icons.location_on_outlined,
                            items: const [
                              DropdownMenuItem(
                                value: 'Almacén',
                                child:
                                    Text('Almacén CEYRSA'),
                              ),
                              DropdownMenuItem(
                                value: 'Obra',
                                child:
                                    Text('En obra'),
                              ),
                            ],
                            onChanged: (valor) {
                              if (valor == null) return;

                              setDialogState(() {
                                ubicacionTipo = valor;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _tituloSeccion(
                      icono: Icons.place_outlined,
                      titulo: 'Ubicación',
                      subtitulo:
                          'Indica dónde se encuentra físicamente',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller: ubicacionController,
                      label: 'Ubicación física',
                      hint: ubicacionTipo == 'Almacén'
                          ? 'Ej. Almacén CEYRSA'
                          : 'Ej. Industrial Park Norte',
                      icono: Icons.place_outlined,
                    ),
                    if (ubicacionTipo == 'Obra') ...[
                      const SizedBox(height: 13),
                      _campoMac(
                        controller: obraController,
                        label: 'Obra / referencia',
                        hint: 'Ej. Industrial Park Norte',
                        icono:
                            Icons.business_outlined,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _tituloSeccion(
                      icono: Icons.notes_outlined,
                      titulo: 'Observaciones',
                      subtitulo:
                          'Información adicional del material',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller: observacionesController,
                      label: 'Observaciones',
                      hint:
                          'Información adicional...',
                      icono: Icons.notes_outlined,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              acciones: [
                _botonSecundario(
                  texto: 'Cancelar',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                _botonPrincipal(
                  icono: Icons.check,
                  texto: 'Crear material',
                  onPressed: () {
                    if (nombreController.text
                        .trim()
                        .isEmpty) {
                      _mostrarAviso(
                        'Escribe el nombre del material.',
                      );
                      return;
                    }

                    materiales.add({
                      'nombre':
                          nombreController.text.trim(),
                      'cantidad':
                          cantidadController.text.trim(),
                      'ubicacionTipo':
                          ubicacionTipo,
                      'ubicacion':
                          ubicacionController.text
                              .trim(),
                      'obra':
                          obraController.text.trim(),
                      'observaciones':
                          observacionesController
                              .text
                              .trim(),
                    });

                    Navigator.pop(context);

                    setState(() {});

                    _mostrarSnack(
                      'Material agregado correctamente.',
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

  // =============================================================
  // VER MATERIAL
  // =============================================================

  void _verMaterial(
    Map<String, dynamic> material,
  ) {
    final bool estaEnAlmacen =
        material['ubicacionTipo'] == 'Almacén';

    final Color color =
        estaEnAlmacen ? verde : naranja;

    showDialog(
      context: context,
      builder: (context) {
        return _ventanaMac(
          titulo:
              material['nombre']?.toString() ??
                  'Material',
          subtitulo:
              'Información y ubicación del material',
          icono: estaEnAlmacen
              ? Icons.warehouse_outlined
              : Icons.location_on_outlined,
          colorIcono: color,
          contenido: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .07),
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          color.withValues(alpha: .16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              color.withValues(alpha: .12),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          estaEnAlmacen
                              ? Icons
                                  .warehouse_outlined
                              : Icons
                                  .location_on_outlined,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              estaEnAlmacen
                                  ? 'ALMACÉN CEYRSA'
                                  : 'EN OBRA',
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w700,
                                letterSpacing: .3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              material['cantidad']
                                      ?.toString() ??
                                  'Sin cantidad',
                              style: const TextStyle(
                                color: texto,
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _tituloSeccion(
                  icono: Icons.info_outline,
                  titulo: 'Información',
                  subtitulo:
                      'Datos registrados del material',
                ),
                const SizedBox(height: 14),
                _filaDato(
                  'Nombre',
                  material['nombre']
                          ?.toString() ??
                      '',
                  Icons.label_outline,
                ),
                _filaDato(
                  'Cantidad',
                  material['cantidad']
                          ?.toString() ??
                      '',
                  Icons.numbers_outlined,
                ),
                _filaDato(
                  'Ubicación',
                  material['ubicacion']
                          ?.toString() ??
                      '',
                  Icons.place_outlined,
                ),
                if (!estaEnAlmacen)
                  _filaDato(
                    'Obra / referencia',
                    material['obra']
                            ?.toString() ??
                        '',
                    Icons.business_outlined,
                  ),
                _filaDato(
                  'Observaciones',
                  material['observaciones']
                          ?.toString() ??
                      '',
                  Icons.notes_outlined,
                ),
              ],
            ),
          ),
          acciones: [
            _botonSecundario(
              texto: 'Cerrar',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            _botonSecundario(
              texto: 'Editar',
              icono: Icons.edit_outlined,
              onPressed: () {
                Navigator.pop(context);
                _editarMaterial(material);
              },
            ),
            _botonSecundario(
              texto: 'PDF',
              icono: Icons.picture_as_pdf_outlined,
              onPressed: () {
                _generarPdfMaterial(material);
              },
            ),
            _botonPeligro(
              texto: 'Eliminar',
              icono: Icons.delete_outline,
              onPressed: () {
                Navigator.pop(context);
                _eliminarMaterial(material);
              },
            ),
          ],
        );
      },
    );
  }

  // =============================================================
  // PDF DEL MATERIAL
  // =============================================================

  Future<void> _generarPdfMaterial(
    Map<String, dynamic> material,
  ) async {
    final pdf = pw.Document();

    final nombre =
        material['nombre']?.toString().trim().isNotEmpty == true
            ? material['nombre'].toString()
            : 'Sin nombre';

    final cantidad =
        material['cantidad']?.toString() ?? 'Sin cantidad';

    final ubicacionTipo =
        material['ubicacionTipo']?.toString() ?? 'Sin ubicación';

    final ubicacion =
        material['ubicacion']?.toString().trim().isNotEmpty == true
            ? material['ubicacion'].toString()
            : 'Sin ubicación';

    final obra =
        material['obra']?.toString().trim().isNotEmpty == true
            ? material['obra'].toString()
            : 'No aplica';

    final observaciones =
        material['observaciones']?.toString().trim().isNotEmpty == true
            ? material['observaciones'].toString()
            : 'Sin observaciones';

    final ahora = DateTime.now();

    final fecha =
        '${ahora.day.toString().padLeft(2, '0')}/'
        '${ahora.month.toString().padLeft(2, '0')}/'
        '${ahora.year}';

    final hora =
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CEYRSA',
                        style: pw.TextStyle(
                          fontSize: 25,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'CONTROL DE MATERIALES',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey700,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding:
                        const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                      ),
                      borderRadius:
                          pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      ubicacionTipo.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 28),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      nombre,
                      style: pw.TextStyle(
                        fontSize: 19,
                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 7),
                    pw.Text(
                      'Cantidad registrada: $cantidad',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              pw.Text(
                'INFORMACIÓN DEL MATERIAL',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: .7,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.2),
                  1: pw.FlexColumnWidth(3),
                },
                children: [
                  _filaPdf('Nombre', nombre),
                  _filaPdf('Cantidad', cantidad),
                  _filaPdf(
                    'Tipo de ubicación',
                    ubicacionTipo,
                  ),
                  _filaPdf(
                    'Ubicación física',
                    ubicacion,
                  ),
                  _filaPdf(
                    'Obra / referencia',
                    obra,
                  ),
                  _filaPdf(
                    'Observaciones',
                    observaciones,
                  ),
                ],
              ),

              pw.Spacer(),

              pw.Divider(
                color: PdfColors.grey400,
              ),

              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Documento generado por CEYRSA',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    '$fecha  $hora',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'CEYRSA_Material_${_nombreArchivo(nombre)}.pdf',
    );
  }

  pw.TableRow _filaPdf(
    String titulo,
    String valor,
  ) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(9),
          color: PdfColors.grey100,
          child: pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(9),
          child: pw.Text(
            valor,
            style: const pw.TextStyle(
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  String _nombreArchivo(String nombre) {
    return nombre
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(' ', '_');
  }

  // =============================================================
  // EDITAR MATERIAL
  // =============================================================

  void _editarMaterial(
    Map<String, dynamic> material,
  ) {
    final nombreController = TextEditingController(
      text: material['nombre']?.toString() ?? '',
    );

    final cantidadController = TextEditingController(
      text: material['cantidad']?.toString() ?? '',
    );

    final ubicacionController = TextEditingController(
      text: material['ubicacion']?.toString() ?? '',
    );

    final obraController = TextEditingController(
      text: material['obra']?.toString() ?? '',
    );

    final observacionesController =
        TextEditingController(
      text:
          material['observaciones']?.toString() ?? '',
    );

    String ubicacionTipo =
        material['ubicacionTipo']?.toString() ??
            'Almacén';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return _ventanaMac(
              titulo: 'Editar material',
              subtitulo:
                  'Modificar información del material',
              icono: Icons.edit_outlined,
              colorIcono: azul,
              contenido: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _tituloSeccion(
                      icono: Icons.inventory_2_outlined,
                      titulo: 'Información del material',
                      subtitulo:
                          'Actualiza los datos registrados',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller: nombreController,
                      label: 'Nombre del material',
                      hint: 'Ej. Hojuela gris',
                      icono: Icons.label_outline,
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _campoMac(
                            controller:
                                cantidadController,
                            label: 'Cantidad',
                            hint: 'Ej. 3 cajas',
                            icono:
                                Icons.numbers_outlined,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: _dropdownMac(
                            valor: ubicacionTipo,
                            label: 'Ubicación',
                            icono:
                                Icons.location_on_outlined,
                            items: const [
                              DropdownMenuItem(
                                value: 'Almacén',
                                child:
                                    Text('Almacén CEYRSA'),
                              ),
                              DropdownMenuItem(
                                value: 'Obra',
                                child:
                                    Text('En obra'),
                              ),
                            ],
                            onChanged: (valor) {
                              if (valor == null) return;

                              setDialogState(() {
                                ubicacionTipo = valor;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _tituloSeccion(
                      icono: Icons.place_outlined,
                      titulo: 'Ubicación',
                      subtitulo:
                          'Dónde se encuentra actualmente',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller:
                          ubicacionController,
                      label: 'Ubicación física',
                      hint: ubicacionTipo == 'Almacén'
                          ? 'Ej. Almacén CEYRSA'
                          : 'Ej. Industrial Park Norte',
                      icono: Icons.place_outlined,
                    ),
                    if (ubicacionTipo == 'Obra') ...[
                      const SizedBox(height: 13),
                      _campoMac(
                        controller:
                            obraController,
                        label: 'Obra / referencia',
                        hint:
                            'Ej. Industrial Park Norte',
                        icono:
                            Icons.business_outlined,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _tituloSeccion(
                      icono: Icons.notes_outlined,
                      titulo: 'Observaciones',
                      subtitulo:
                          'Notas adicionales',
                    ),
                    const SizedBox(height: 16),
                    _campoMac(
                      controller:
                          observacionesController,
                      label: 'Observaciones',
                      hint:
                          'Información adicional...',
                      icono: Icons.notes_outlined,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              acciones: [
                _botonSecundario(
                  texto: 'Cancelar',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                _botonPrincipal(
                  icono: Icons.save_outlined,
                  texto: 'Guardar cambios',
                  onPressed: () {
                    if (nombreController.text
                        .trim()
                        .isEmpty) {
                      _mostrarAviso(
                        'Escribe el nombre del material.',
                      );
                      return;
                    }

                    material['nombre'] =
                        nombreController.text.trim();

                    material['cantidad'] =
                        cantidadController.text.trim();

                    material['ubicacionTipo'] =
                        ubicacionTipo;

                    material['ubicacion'] =
                        ubicacionController.text.trim();

                    material['obra'] =
                        obraController.text.trim();

                    material['observaciones'] =
                        observacionesController
                            .text
                            .trim();

                    Navigator.pop(context);

                    setState(() {});

                    _mostrarSnack(
                      'Material actualizado correctamente.',
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

  // =============================================================
  // ELIMINAR
  // =============================================================

  void _eliminarMaterial(
    Map<String, dynamic> material,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _ventanaMac(
          titulo: 'Eliminar material',
          subtitulo:
              'Esta acción no se puede deshacer',
          icono: Icons.delete_outline,
          colorIcono: rojo,
          contenido: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: rojo.withValues(alpha: .07),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: rojo.withValues(alpha: .16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: rojo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¿Seguro que deseas eliminar '
                          '"${material['nombre']}"?',
                          style: const TextStyle(
                            color: texto,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'El material desaparecerá de la lista actual.',
                  style: TextStyle(
                    color: textoSecundario,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          acciones: [
            _botonSecundario(
              texto: 'Cancelar',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            _botonPeligro(
              texto: 'Eliminar material',
              icono: Icons.delete_outline,
              onPressed: () {
                setState(() {
                  materiales.remove(material);
                });

                Navigator.pop(context);

                _mostrarSnack(
                  'Material eliminado.',
                );
              },
            ),
          ],
        );
      },
    );
  }

  // =============================================================
  // VENTANA macOS
  // CORREGIDA PARA EVITAR OVERFLOW NEGRO/AMARILLO
  // =============================================================

  Widget _ventanaMac({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color colorIcono,
    required Widget contenido,
    required List<Widget> acciones,
  }) {
    final altoPantalla =
        MediaQuery.of(context).size.height;

    final altoDisponible =
        (altoPantalla - 36).clamp(320.0, 900.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 18,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: altoDisponible,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borde),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .16),
                blurRadius: 35,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -------------------------------------------------
              // HEADER
              // -------------------------------------------------

              Container(
                height: 76,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: borde,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _trafficLight(
                      const Color(0xFFFF5F57),
                    ),
                    const SizedBox(width: 7),
                    _trafficLight(
                      const Color(0xFFFFBD2E),
                    ),
                    const SizedBox(width: 7),
                    _trafficLight(
                      const Color(0xFF28C840),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            colorIcono.withValues(alpha: .10),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icono,
                        color: colorIcono,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: texto,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitulo,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textoSecundario,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 19,
                        color: textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------
              // CONTENIDO
              // -------------------------------------------------

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    22,
                    24,
                    10,
                  ),
                  child: contenido,
                ),
              ),

              // -------------------------------------------------
              // FOOTER
              // -------------------------------------------------

              Container(
                constraints: const BoxConstraints(
                  minHeight: 72,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFBFBFC),
                  border: Border(
                    top: BorderSide(
                      color: borde,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: acciones
                        .map(
                          (accion) => Padding(
                            padding:
                                const EdgeInsets.only(
                              left: 9,
                            ),
                            child: accion,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SECCIÓN
  // =============================================================

  Widget _tituloSeccion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: azul.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icono,
            size: 16,
            color: azul,
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
                  color: texto,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textoSecundario,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // CAMPO
  // =============================================================

  Widget _campoMac({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icono,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: texto,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          child: Icon(
            icono,
            size: 18,
            color: textoSecundario,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(
          minWidth: 42,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        labelStyle: const TextStyle(
          color: textoSecundario,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9A9AA0),
          fontSize: 12,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borde,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: azul,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // DROPDOWN
  // =============================================================

  Widget _dropdownMac({
    required String valor,
    required String label,
    required IconData icono,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(
        color: texto,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          child: Icon(
            icono,
            size: 18,
            color: textoSecundario,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(
          minWidth: 42,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        labelStyle: const TextStyle(
          color: textoSecundario,
          fontSize: 12,
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borde,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: borde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: azul,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  // =============================================================
  // FILA DATO
  // =============================================================

  Widget _filaDato(
    String titulo,
    String valor,
    IconData icono,
  ) {
    final textoFinal =
        valor.trim().isEmpty
            ? 'Sin información'
            : valor;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borde),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: azul.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              size: 16,
              color: azul,
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
                    color: textoSecundario,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  textoFinal,
                  style: const TextStyle(
                    color: texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTONES
  // =============================================================

  Widget _botonPrincipal({
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icono,
        size: 17,
      ),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _botonSecundario({
    required String texto,
    IconData? icono,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icono == null
          ? const SizedBox.shrink()
          : Icon(
              icono,
              size: 16,
            ),
      label: Text(texto),
      style: OutlinedButton.styleFrom(
        foregroundColor: textoSecundario,
        backgroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        side: const BorderSide(
          color: borde,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _botonPeligro({
    required String texto,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icono,
        size: 16,
      ),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        backgroundColor: rojo,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =============================================================
  // TRAFFIC LIGHT
  // =============================================================

  Widget _trafficLight(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // =============================================================
  // MENSAJES
  // =============================================================

  void _mostrarAviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarSnack(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}