import 'package:flutter/material.dart';

class HerramientasScreen extends StatefulWidget {
  const HerramientasScreen({super.key});

  @override
  State<HerramientasScreen> createState() => _HerramientasScreenState();
}

class _HerramientasScreenState extends State<HerramientasScreen> {
  // ===============================================================
  // SISTEMA VISUAL MACOS MODERNO
  // ===============================================================

  static const Color _fondo = Color(0xFFF5F5F7);
  static const Color _superficie = Colors.white;
  static const Color _superficieSuave = Color(0xFFF8F8FA);
  static const Color _texto = Color(0xFF1D1D1F);
  static const Color _secundario = Color(0xFF6E6E73);
  static const Color _terciario = Color(0xFF8E8E93);
  static const Color _borde = Color(0xFFE5E5E7);
  static const Color _azul = Color(0xFF007AFF);
  static const Color _azulSuave = Color(0xFFEAF3FF);
  static const Color _verde = Color(0xFF34C759);
  static const Color _verdeSuave = Color(0xFFEAF8EF);
  static const Color _naranja = Color(0xFFFF9500);
  static const Color _naranjaSuave = Color(0xFFFFF4E5);

  // ===============================================================
  // CATEGORÍAS
  // ===============================================================

  final List<Map<String, dynamic>> _categorias = [];

  // ===============================================================
  // BUSCADOR
  // ===============================================================

  String _busqueda = '';

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final categoriasFiltradas = _categorias.where((categoria) {
      final nombre = categoria['nombre'].toString().toLowerCase();

      return nombre.contains(
        _busqueda.trim().toLowerCase(),
      );
    }).toList();

    return Container(
      color: _fondo,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            30,
            26,
            30,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // ENCABEZADO
              // =====================================================

              _encabezado(),

              const SizedBox(height: 25),

              // =====================================================
              // RESUMEN
              // =====================================================

              _resumen(),

              const SizedBox(height: 20),

              // =====================================================
              // BUSCADOR
              // =====================================================

              _buscador(),

              const SizedBox(height: 18),

              // =====================================================
              // CATEGORÍAS
              // =====================================================

              Expanded(
                child: categoriasFiltradas.isEmpty
                    ? _estadoVacio()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          top: 2,
                        ),
                        itemCount: categoriasFiltradas.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 13),
                        itemBuilder: (context, index) {
                          return _tarjetaCategoria(
                            categoriasFiltradas[index],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ENCABEZADO
  // ===============================================================

  Widget _encabezado() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Herramientas',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w700,
                  color: _texto,
                  letterSpacing: -0.9,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Control y organización de herramientas',
                style: TextStyle(
                  fontSize: 14,
                  color: _secundario,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _botonPrincipal(
          icono: Icons.add,
          texto: 'Nuevo tipo',
          onPressed: _crearTipo,
        ),
      ],
    );
  }

  // ===============================================================
  // RESUMEN
  // ===============================================================

  Widget _resumen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto = constraints.maxWidth < 700;

        final total = _totalGeneral();
        final categorias = _categorias.length;

        if (compacto) {
          return Row(
            children: [
              Expanded(
                child: _resumenGeneral(
                  'Total general',
                  total,
                  Icons.handyman_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _resumenGeneral(
                  'Categorías',
                  categorias,
                  Icons.category_outlined,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            _resumenGeneral(
              'Total general',
              total,
              Icons.handyman_outlined,
            ),
            const SizedBox(width: 13),
            _resumenGeneral(
              'Categorías',
              categorias,
              Icons.category_outlined,
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // BOTÓN PRINCIPAL
  // ===============================================================

  Widget _botonPrincipal({
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: _texto,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 17,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // BUSCADOR
  // ===============================================================

  Widget _buscador() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.018),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (valor) {
          setState(() {
            _busqueda = valor;
          });
        },
        style: const TextStyle(
          fontSize: 14,
          color: _texto,
        ),
        cursorColor: _azul,
        decoration: InputDecoration(
          hintText: 'Buscar categoría...',
          hintStyle: const TextStyle(
            color: _terciario,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 19,
            color: _secundario,
          ),
          suffixIcon: _busqueda.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar',
                  splashRadius: 18,
                  icon: const Icon(
                    Icons.close,
                    size: 17,
                    color: _secundario,
                  ),
                  onPressed: () {
                    setState(() {
                      _busqueda = '';
                    });
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 10,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // RESUMEN GENERAL
  // ===============================================================

  Widget _resumenGeneral(
    String titulo,
    int valor,
    IconData icono,
  ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.018),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _superficieSuave,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icono,
              size: 20,
              color: _texto,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$valor',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: _texto,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                titulo,
                style: const TextStyle(
                  color: _secundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TARJETA CATEGORÍA
  // ===============================================================

  Widget _tarjetaCategoria(
    Map<String, dynamic> categoria,
  ) {
    final nombre = categoria['nombre'].toString();
    final modalidad = categoria['modalidad'].toString();
    final electrica = categoria['electrica'] == true;

    final herramientas =
        categoria['herramientas'] as List<dynamic>;

    int total = 0;
    int almacen = 0;
    int obra = 0;
    int mantenimiento = 0;

    if (modalidad == 'individual') {
      total = herramientas.length;

      for (final elemento in herramientas) {
        final herramienta =
            elemento as Map<String, dynamic>;

        final estado =
            herramienta['estado']?.toString() ?? '';

        if (estado == 'En almacén') {
          almacen++;
        } else if (estado == 'En obra') {
          obra++;
        } else if (estado == 'Mantenimiento') {
          mantenimiento++;
        }
      }
    } else {
      total = _numeroSeguro(
        categoria['cantidadTotal'],
      );

      almacen = _numeroSeguro(
        categoria['cantidadAlmacen'],
      );

      obra = _numeroSeguro(
        categoria['cantidadEnObra'],
      );

      mantenimiento = _numeroSeguro(
        categoria['cantidadMantenimiento'],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: const Color(0xFFF9F9FB),
          splashColor: _azul.withOpacity(0.04),
          highlightColor: _azul.withOpacity(0.025),
          onTap: () {
            _abrirCategoria(categoria);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compacto = constraints.maxWidth < 850;

                if (compacto) {
                  return _tarjetaCategoriaCompacta(
                    categoria,
                    nombre,
                    modalidad,
                    electrica,
                    total,
                    almacen,
                    obra,
                    mantenimiento,
                  );
                }

                return _tarjetaCategoriaAmplia(
                  categoria,
                  nombre,
                  modalidad,
                  electrica,
                  total,
                  almacen,
                  obra,
                  mantenimiento,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TARJETA AMPLIA
  // ===============================================================

  Widget _tarjetaCategoriaAmplia(
    Map<String, dynamic> categoria,
    String nombre,
    String modalidad,
    bool electrica,
    int total,
    int almacen,
    int obra,
    int mantenimiento,
  ) {
    return Row(
      children: [
        _iconoCategoria(electrica),

        const SizedBox(width: 16),

        Expanded(
          child: _informacionCategoria(
            nombre,
            modalidad,
            electrica,
          ),
        ),

        _datoResumen(
          'Total',
          total,
        ),

        const SizedBox(width: 30),

        _datoResumen(
          'Almacén',
          almacen,
        ),

        const SizedBox(width: 30),

        _datoResumen(
          'En obra',
          obra,
        ),

        if (mantenimiento > 0) ...[
          const SizedBox(width: 30),
          _datoResumen(
            'Mantenimiento',
            mantenimiento,
          ),
        ],

        const SizedBox(width: 18),

        _chevron(),
      ],
    );
  }

  // ===============================================================
  // TARJETA COMPACTA
  // ===============================================================

  Widget _tarjetaCategoriaCompacta(
    Map<String, dynamic> categoria,
    String nombre,
    String modalidad,
    bool electrica,
    int total,
    int almacen,
    int obra,
    int mantenimiento,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconoCategoria(electrica),

            const SizedBox(width: 14),

            Expanded(
              child: _informacionCategoria(
                nombre,
                modalidad,
                electrica,
              ),
            ),

            _chevron(),
          ],
        ),

        const SizedBox(height: 18),

        Wrap(
          spacing: 27,
          runSpacing: 13,
          children: [
            _datoResumen(
              'Total',
              total,
            ),
            _datoResumen(
              'Almacén',
              almacen,
            ),
            _datoResumen(
              'En obra',
              obra,
            ),
            if (mantenimiento > 0)
              _datoResumen(
                'Mantenimiento',
                mantenimiento,
              ),
          ],
        ),
      ],
    );
  }

  // ===============================================================
  // CHEVRON
  // ===============================================================

  Widget _chevron() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _superficieSuave,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.chevron_right,
        size: 18,
        color: _secundario,
      ),
    );
  }

  // ===============================================================
  // ICONO CATEGORÍA
  // ===============================================================

  Widget _iconoCategoria(bool electrica) {
    return Container(
      width: 57,
      height: 57,
      decoration: BoxDecoration(
        color: electrica
            ? _naranjaSuave
            : _superficieSuave,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        electrica
            ? Icons.electrical_services_outlined
            : Icons.handyman_outlined,
        size: 27,
        color: electrica
            ? _naranja
            : _texto,
      ),
    );
  }

  // ===============================================================
  // INFORMACIÓN CATEGORÍA
  // ===============================================================

  Widget _informacionCategoria(
    String nombre,
    String modalidad,
    bool electrica,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _texto,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _etiqueta(
              modalidad == 'individual'
                  ? 'Individual'
                  : 'Por cantidad',
            ),
            if (electrica)
              _etiqueta(
                'Eléctrica',
                azul: true,
              ),
          ],
        ),
      ],
    );
  }

  // ===============================================================
  // DATO RESUMEN
  // ===============================================================

  Widget _datoResumen(
    String titulo,
    int cantidad,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$cantidad',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _texto,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 11,
            color: _secundario,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // ETIQUETA
  // ===============================================================

  Widget _etiqueta(
    String texto, {
    bool azul = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: azul ? _azulSuave : _superficieSuave,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: azul ? _azul : _secundario,
        ),
      ),
    );
  }

  // ===============================================================
  // ESTADO VACÍO
  // ===============================================================

  Widget _estadoVacio() {
    final buscando = _busqueda.trim().isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _superficie,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _borde,
                ),
              ),
              child: Icon(
                buscando
                    ? Icons.search_off_rounded
                    : Icons.handyman_outlined,
                size: 34,
                color: _secundario,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              buscando
                  ? 'No se encontraron resultados'
                  : 'No hay categorías de herramientas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _texto,
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              buscando
                  ? 'Prueba con otro nombre de categoría.'
                  : 'Crea un tipo para comenzar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secundario,
                fontSize: 13,
              ),
            ),

            if (!buscando) ...[
              const SizedBox(height: 20),
              _botonPrincipal(
                icono: Icons.add,
                texto: 'Crear primer tipo',
                onPressed: _crearTipo,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // CREAR TIPO
  // ===============================================================

  void _crearTipo() {
    final nombreController = TextEditingController();

    String modalidad = 'individual';
    bool electrica = false;

    _ventanaMac(
      context: context,
      titulo: 'Nuevo tipo de herramienta',
      ancho: 550,
      contenido: StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tituloSeccionDialogo(
                  'Información básica',
                ),

                const SizedBox(height: 12),

                _campoMac(
                  controller: nombreController,
                  label: 'Nombre del tipo',
                  hint:
                      'Ej. Pulidoras, Escobas, Jappower...',
                ),

                const SizedBox(height: 25),

                _tituloSeccionDialogo(
                  'Forma de control',
                ),

                const SizedBox(height: 8),

                _opcionRadio(
                  titulo: 'Individual',
                  subtitulo:
                      'Cada herramienta tendrá su propia ficha.',
                  valor: 'individual',
                  grupo: modalidad,
                  onChanged: (valor) {
                    setDialogState(() {
                      modalidad = valor!;
                    });
                  },
                ),

                _opcionRadio(
                  titulo: 'Por cantidad',
                  subtitulo:
                      'Se controla por número de piezas.',
                  valor: 'cantidad',
                  grupo: modalidad,
                  onChanged: (valor) {
                    setDialogState(() {
                      modalidad = valor!;
                    });
                  },
                ),

                const SizedBox(height: 14),

                Container(
                  height: 1,
                  color: _borde,
                ),

                const SizedBox(height: 18),

                _tituloSeccionDialogo(
                  'Características',
                ),

                const SizedBox(height: 4),

                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeColor: _azul,
                  title: Text(
                    electrica
                        ? 'Herramienta eléctrica'
                        : 'Herramienta no eléctrica',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _texto,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    electrica
                        ? 'Se mostrarán las características eléctricas.'
                        : 'No se mostrarán características eléctricas.',
                    style: const TextStyle(
                      color: _secundario,
                      fontSize: 12,
                    ),
                  ),
                  value: electrica,
                  onChanged: (valor) {
                    setDialogState(() {
                      electrica = valor;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      acciones: [
        _botonDialogo(
          texto: 'Cancelar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        _botonDialogo(
          texto: 'Crear tipo',
          principal: true,
          onPressed: () {
            final nombre =
                nombreController.text.trim();

            if (nombre.isEmpty) {
              return;
            }

            final existe = _categorias.any(
              (categoria) =>
                  categoria['nombre']
                      .toString()
                      .toLowerCase() ==
                  nombre.toLowerCase(),
            );

            if (existe) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Ya existe una categoría con ese nombre.',
                  ),
                ),
              );
              return;
            }

            final nuevaCategoria =
                <String, dynamic>{
              'nombre': nombre,
              'modalidad': modalidad,
              'electrica': electrica,
              'configuracion': {
                'electrica': electrica,
                'serie': modalidad == 'individual',
                'modelo': modalidad == 'individual',
                'marca': true,
                'color': true,
              },
              'herramientas':
                  <Map<String, dynamic>>[],
              'cantidadTotal': 0,
              'cantidadAlmacen': 0,
              'cantidadEnObra': 0,
              'cantidadMantenimiento': 0,
            };

            setState(() {
              _categorias.add(nuevaCategoria);
            });

            Navigator.pop(context);

            _abrirCategoria(nuevaCategoria);
          },
        ),
      ],
    );
  }

  // ===============================================================
  // TÍTULO DE SECCIÓN EN DIÁLOGO
  // ===============================================================

  Widget _tituloSeccionDialogo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _texto,
        letterSpacing: -0.1,
      ),
    );
  }

  // ===============================================================
  // RADIO
  // ===============================================================

  Widget _opcionRadio({
    required String titulo,
    required String subtitulo,
    required String valor,
    required String grupo,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: grupo == valor
            ? _azulSuave
            : _superficieSuave,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: grupo == valor
              ? _azul.withOpacity(0.25)
              : _borde,
        ),
      ),
      child: RadioListTile<String>(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 1,
        ),
        activeColor: _azul,
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _texto,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(
            color: _secundario,
            fontSize: 12,
          ),
        ),
        value: valor,
        groupValue: grupo,
        onChanged: onChanged,
      ),
    );
  }

  // ===============================================================
  // ABRIR CATEGORÍA
  // ===============================================================

  void _abrirCategoria(
    Map<String, dynamic> categoria,
  ) {
    if (categoria['modalidad'] == 'individual') {
      _mostrarHerramientasIndividuales(categoria);
    } else {
      _mostrarControlCantidad(categoria);
    }
  }

  // ===============================================================
  // CATEGORÍA INDIVIDUAL
  // ===============================================================

  void _mostrarHerramientasIndividuales(
    Map<String, dynamic> categoria,
  ) {
    final herramientas =
        categoria['herramientas'] as List<dynamic>;

    _ventanaMac(
      context: context,
      titulo:
          '${categoria['nombre']} (${herramientas.length})',
      ancho: 920,
      alto: 620,
      contenido: StatefulBuilder(
        builder: (context, setDialogState) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Herramientas registradas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _texto,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${herramientas.length} registrada${herramientas.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _secundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _botonPrincipal(
                    icono: Icons.add,
                    texto: 'Agregar',
                    onPressed: () {
                      Navigator.pop(context);

                      _agregarHerramienta(
                        categoria,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Expanded(
                child: herramientas.isEmpty
                    ? _estadoVacioHerramientas()
                    : GridView.builder(
                        physics:
                            const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.only(
                          bottom: 8,
                          top: 2,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 270,
                          mainAxisExtent: 178,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: herramientas.length,
                        itemBuilder:
                            (context, index) {
                          return _tarjetaHerramienta(
                            categoria,
                            herramientas[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      acciones: [
        _botonDialogo(
          texto: 'Cerrar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ===============================================================
  // ESTADO VACÍO DE HERRAMIENTAS
  // ===============================================================

  Widget _estadoVacioHerramientas() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _superficieSuave,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.handyman_outlined,
              size: 29,
              color: _secundario,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No hay herramientas registradas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _texto,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Agrega la primera herramienta para comenzar.',
            style: TextStyle(
              fontSize: 12,
              color: _secundario,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TARJETA DE HERRAMIENTA
  // ===============================================================

  Widget _tarjetaHerramienta(
    Map<String, dynamic> categoria,
    dynamic elemento,
  ) {
    final herramienta =
        elemento as Map<String, dynamic>;

    final marca =
        herramienta['marca']?.toString() ?? '';

    final modelo =
        herramienta['modelo']?.toString() ?? '';

    final serie =
        herramienta['serie']?.toString() ?? '';

    final estado =
        herramienta['estado']?.toString() ??
            'En almacén';

    final electrica =
        herramienta['electrica'] == true;

    return Container(
      decoration: BoxDecoration(
        color: _superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.018),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          hoverColor: const Color(0xFFF9F9FB),
          onTap: () {
            _verHerramienta(
              categoria,
              herramienta,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: electrica
                            ? _naranjaSuave
                            : _superficieSuave,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Icon(
                        electrica
                            ? Icons
                                .electrical_services_outlined
                            : Icons
                                .handyman_outlined,
                        size: 18,
                        color: electrica
                            ? _naranja
                            : _texto,
                      ),
                    ),

                    const Spacer(),

                    _estadoPequeno(estado),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  marca.isEmpty
                      ? categoria['nombre'].toString()
                      : marca,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _texto,
                  ),
                ),

                if (modelo.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    modelo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secundario,
                      fontSize: 12,
                    ),
                  ),
                ],

                const Spacer(),

                if (serie.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.tag,
                        size: 12,
                        color: _terciario,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          serie,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _secundario,
                          ),
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

  // ===============================================================
  // ESTADO PEQUEÑO
  // ===============================================================

  Widget _estadoPequeno(
    String estado,
  ) {
    Color fondo = _superficieSuave;
    Color texto = _secundario;

    if (estado == 'En almacén') {
      fondo = _verdeSuave;
      texto = _verde;
    } else if (estado == 'En obra') {
      fondo = _azulSuave;
      texto = _azul;
    } else if (estado == 'Mantenimiento') {
      fondo = _naranjaSuave;
      texto = _naranja;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
      ),
    );
  }

  // ===============================================================
  // AGREGAR HERRAMIENTA
  // ===============================================================

  void _agregarHerramienta(
    Map<String, dynamic> categoria,
  ) {
    final nombreController =
        TextEditingController();

    final marcaController =
        TextEditingController();

    final modeloController =
        TextEditingController();

    final serieController =
        TextEditingController();

    final colorController =
        TextEditingController();

    String estado = 'En almacén';
    String alimentacion = '110 V';

    final electrica =
        categoria['electrica'] == true;

    _ventanaMac(
      context: context,
      titulo:
          'Agregar a ${categoria['nombre']}',
      ancho: 630,
      contenido: StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoMac(
                  controller: nombreController,
                  label: 'Identificación',
                  hint: 'Ej. Pulidora #01',
                ),

                const SizedBox(height: 12),

                _campoMac(
                  controller: marcaController,
                  label: 'Marca',
                ),

                const SizedBox(height: 12),

                _campoMac(
                  controller: modeloController,
                  label: 'Modelo',
                ),

                const SizedBox(height: 12),

                _campoMac(
                  controller: serieController,
                  label: 'Número de serie',
                  hint: 'Opcional',
                ),

                const SizedBox(height: 12),

                _campoMac(
                  controller: colorController,
                  label: 'Color',
                ),

                if (electrica) ...[
                  const SizedBox(height: 12),

                  _dropdownMac(
                    label: 'Alimentación',
                    valor: alimentacion,
                    opciones: const [
                      '110 V',
                      '220 V',
                      'Batería',
                    ],
                    onChanged: (valor) {
                      setDialogState(() {
                        alimentacion = valor!;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 12),

                _dropdownMac(
                  label: 'Estado',
                  valor: estado,
                  opciones: const [
                    'En almacén',
                    'En obra',
                    'Mantenimiento',
                  ],
                  onChanged: (valor) {
                    setDialogState(() {
                      estado = valor!;
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      acciones: [
        _botonDialogo(
          texto: 'Cancelar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        _botonDialogo(
          texto: 'Guardar',
          principal: true,
          onPressed: () {
            final herramienta =
                <String, dynamic>{
              'nombre':
                  nombreController.text.trim(),
              'marca':
                  marcaController.text.trim(),
              'modelo':
                  modeloController.text.trim(),
              'serie':
                  serieController.text.trim(),
              'color':
                  colorController.text.trim(),
              'estado': estado,
              'electrica': electrica,
              'alimentacion':
                  electrica
                      ? alimentacion
                      : null,
              'accesorios': <dynamic>[],
              'movimientos': <dynamic>[],
              'incidencias': <dynamic>[],
            };

            setState(() {
              final lista =
                  categoria['herramientas']
                      as List<dynamic>;

              lista.add(herramienta);
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  'Herramienta agregada correctamente.',
                ),
              ),
            );

            _mostrarHerramientasIndividuales(
              categoria,
            );
          },
        ),
      ],
    );
  }

  // ===============================================================
  // VER HERRAMIENTA
  // ===============================================================

  void _verHerramienta(
    Map<String, dynamic> categoria,
    Map<String, dynamic> herramienta,
  ) {
    final electrica =
        herramienta['electrica'] == true;

    _ventanaMac(
      context: context,
      titulo:
          herramienta['nombre']
                      ?.toString()
                      .isNotEmpty ==
                  true
              ? herramienta['nombre'].toString()
              : categoria['nombre'].toString(),
      ancho: 610,
      contenido: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _dato(
              'Categoría',
              categoria['nombre'],
            ),
            _dato(
              'Marca',
              herramienta['marca'],
            ),
            _dato(
              'Modelo',
              herramienta['modelo'],
            ),
            _dato(
              'Serie',
              herramienta['serie'],
            ),
            _dato(
              'Color',
              herramienta['color'],
            ),
            _dato(
              'Estado',
              herramienta['estado'],
            ),

            if (electrica) ...[
              const Divider(height: 28),
              _dato(
                'Alimentación',
                herramienta['alimentacion'],
              ),
            ],

            const Divider(height: 28),

            _seccionInformativa(
              icono: Icons.inventory_2_outlined,
              titulo: 'Accesorios',
              texto:
                  'Esta sección se desarrollará posteriormente.',
            ),

            const SizedBox(height: 20),

            _seccionInformativa(
              icono: Icons.swap_horiz_rounded,
              titulo: 'Movimientos',
              texto:
                  'Aquí se registrarán salidas, regresos y asignaciones.',
            ),

            const SizedBox(height: 20),

            _seccionInformativa(
              icono: Icons.warning_amber_rounded,
              titulo: 'Incidencias',
              texto:
                  'Aquí se registrarán daños, reparaciones y mantenimiento.',
            ),
          ],
        ),
      ),
      acciones: [
        _botonDialogo(
          texto: 'Cerrar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ===============================================================
  // SECCIÓN INFORMATIVA
  // ===============================================================

  Widget _seccionInformativa({
    required IconData icono,
    required String titulo,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _superficieSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 18,
            color: _secundario,
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
                    fontWeight: FontWeight.w700,
                    color: _texto,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  texto,
                  style: const TextStyle(
                    color: _secundario,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CONTROL POR CANTIDAD
  // ===============================================================

  void _mostrarControlCantidad(
    Map<String, dynamic> categoria,
  ) {
    final totalController =
        TextEditingController(
      text: _numeroSeguro(
        categoria['cantidadTotal'],
      ).toString(),
    );

    final almacenController =
        TextEditingController(
      text: _numeroSeguro(
        categoria['cantidadAlmacen'],
      ).toString(),
    );

    final obraController =
        TextEditingController(
      text: _numeroSeguro(
        categoria['cantidadEnObra'],
      ).toString(),
    );

    final mantenimientoController =
        TextEditingController(
      text: _numeroSeguro(
        categoria['cantidadMantenimiento'],
      ).toString(),
    );

    _ventanaMac(
      context: context,
      titulo: categoria['nombre'].toString(),
      ancho: 530,
      contenido: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campoNumero(
              'Cantidad total',
              totalController,
            ),
            const SizedBox(height: 12),
            _campoNumero(
              'En almacén',
              almacenController,
            ),
            const SizedBox(height: 12),
            _campoNumero(
              'En obra',
              obraController,
            ),
            const SizedBox(height: 12),
            _campoNumero(
              'En mantenimiento',
              mantenimientoController,
            ),
          ],
        ),
      ),
      acciones: [
        _botonDialogo(
          texto: 'Cerrar',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        _botonDialogo(
          texto: 'Guardar',
          principal: true,
          onPressed: () {
            setState(() {
              categoria['cantidadTotal'] =
                  int.tryParse(
                        totalController.text.trim(),
                      ) ??
                      0;

              categoria['cantidadAlmacen'] =
                  int.tryParse(
                        almacenController.text.trim(),
                      ) ??
                      0;

              categoria['cantidadEnObra'] =
                  int.tryParse(
                        obraController.text.trim(),
                      ) ??
                      0;

              categoria[
                      'cantidadMantenimiento'] =
                  int.tryParse(
                        mantenimientoController
                            .text
                            .trim(),
                      ) ??
                      0;
            });

            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // ===============================================================
  // CAMPO MAC
  // ===============================================================

  Widget _campoMac({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: _texto,
        fontSize: 14,
      ),
      cursorColor: _azul,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _secundario,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          color: _terciario,
          fontSize: 13,
        ),
        filled: true,
        fillColor: _superficieSuave,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _borde,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _borde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _azul,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // DROPDOWN MAC
  // ===============================================================

  Widget _dropdownMac({
    required String label,
    required String valor,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: valor,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 19,
        color: _secundario,
      ),
      style: const TextStyle(
        color: _texto,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: _secundario,
          fontSize: 13,
        ),
        filled: true,
        fillColor: _superficieSuave,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _borde,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _borde,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: _azul,
            width: 1.2,
          ),
        ),
      ),
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(
            opcion,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ===============================================================
  // CAMPO NUMÉRICO
  // ===============================================================

  Widget _campoNumero(
    String titulo,
    TextEditingController controller,
  ) {
    return _campoMac(
      controller: controller,
      label: titulo,
    );
  }

  // ===============================================================
  // DATO
  // ===============================================================

  Widget _dato(
    String titulo,
    dynamic valor,
  ) {
    final texto = valor?.toString() ?? '';

    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 13,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _secundario,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: _texto,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // VENTANA MAC MODERNA
  // ===============================================================

  void _ventanaMac({
    required BuildContext context,
    required String titulo,
    required Widget contenido,
    required List<Widget> acciones,
    double ancho = 600,
    double? alto,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.28),
      builder: (dialogContext) {
        final media =
            MediaQuery.of(dialogContext);

        final maxWidth =
            media.size.width - 40;

        final maxHeight =
            media.size.height - 48;

        final anchoFinal = ancho.clamp(
          320.0,
          maxWidth,
        );

        // Siempre damos una altura máxima controlada.
        // Esto evita problemas con Expanded dentro de
        // Column cuando el diálogo no tiene altura fija.
        final altoDeseado =
            alto ?? (media.size.height * 0.72);

        final altoFinal = altoDeseado.clamp(
          260.0,
          maxHeight,
        );

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            width: anchoFinal,
            height: altoFinal,
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              minHeight: 260,
            ),
            decoration: BoxDecoration(
              color: _superficie,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: _borde,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.16),
                  blurRadius: 38,
                  spreadRadius: 0,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // =================================================
                // BARRA SUPERIOR
                // =================================================

                Container(
                  height: 58,
                  padding:
                      const EdgeInsets.only(
                    left: 18,
                    right: 9,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: _superficie,
                    border: Border(
                      bottom: BorderSide(
                        color: _borde,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Indicadores estilo ventana Mac
                      Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          _puntoVentana(
                            _ColorVentana.rojo,
                          ),
                          const SizedBox(width: 6),
                          _puntoVentana(
                            _ColorVentana.amarillo,
                          ),
                          const SizedBox(width: 6),
                          _puntoVentana(
                            _ColorVentana.verde,
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Text(
                          titulo,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                            color: _texto,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),

                      IconButton(
                        tooltip: 'Cerrar',
                        splashRadius: 19,
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                        color: _secundario,
                      ),
                    ],
                  ),
                ),

                // =================================================
                // CONTENIDO
                // =================================================

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(20),
                    child: contenido,
                  ),
                ),

                // =================================================
                // PIE
                // =================================================

                Container(
                  constraints:
                      const BoxConstraints(
                    minHeight: 64,
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    12,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: _superficie,
                    border: Border(
                      top: BorderSide(
                        color: _borde,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child:
                            SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal,
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: acciones
                                .map(
                                  (widget) =>
                                      Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      left: 8,
                                    ),
                                    child: widget,
                                  ),
                                )
                                .toList(),
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
      },
    );
  }

  // ===============================================================
  // PUNTO VENTANA
  // ===============================================================

  Widget _puntoVentana(
    _ColorVentana tipo,
  ) {
    Color color;

    switch (tipo) {
      case _ColorVentana.rojo:
        color = const Color(0xFFFF5F57);
        break;
      case _ColorVentana.amarillo:
        color = const Color(0xFFFFBD2E);
        break;
      case _ColorVentana.verde:
        color = const Color(0xFF28C840);
        break;
    }

    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // ===============================================================
  // BOTONES DE DIÁLOGO
  // ===============================================================

  Widget _botonDialogo({
    required String texto,
    required VoidCallback onPressed,
    bool principal = false,
  }) {
    if (principal) {
      return Material(
        color: _texto,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: _superficieSuave,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          child: Text(
            texto,
            style: const TextStyle(
              color: _texto,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TOTAL GENERAL
  // ===============================================================

  int _totalGeneral() {
    int total = 0;

    for (final categoria in _categorias) {
      final modalidad =
          categoria['modalidad']?.toString() ??
              'individual';

      if (modalidad == 'individual') {
        final herramientas =
            categoria['herramientas']
                as List<dynamic>;

        total += herramientas.length;
      } else {
        total += int.tryParse(
              categoria['cantidadTotal']
                      ?.toString() ??
                  '0',
            ) ??
            0;
      }
    }

    return total;
  }

  // ===============================================================
  // CONVERTIR A INT
  // ===============================================================

  int _numeroSeguro(
    dynamic valor,
  ) {
    if (valor is int) {
      return valor;
    }

    return int.tryParse(
          valor?.toString() ?? '0',
        ) ??
        0;
  }
}

// ===============================================================
// ENUM PARA LOS INDICADORES DE VENTANA
// ===============================================================

enum _ColorVentana {
  rojo,
  amarillo,
  verde,
}