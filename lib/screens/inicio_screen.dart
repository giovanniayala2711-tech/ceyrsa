import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'login_screen.dart';
import 'obras_screen.dart';
import 'archivos_screen.dart';
import 'materiales_screen.dart';
import 'herramientas_screen.dart';
import 'usuarios_screen.dart';
import 'cuadrillas_screen.dart';
import 'asistencia_screen.dart';
import 'perfil_screen.dart';
import 'configuracion_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // PALETA
  // ============================================================

  static const Color _fondo = Color(0xFFF5F5F7);
  static const Color _sidebar = Color(0xFFF8F8FA);
  static const Color _blanco = Colors.white;

  static const Color _texto = Color(0xFF1D1D1F);
  static const Color _secundario = Color(0xFF6E6E73);
  static const Color _terciario = Color(0xFF8E8E93);
  static const Color _borde = Color(0xFFE3E3E6);

  static const Color _azul = Color(0xFF007AFF);
  static const Color _verde = Color(0xFF34C759);
  static const Color _naranja = Color(0xFFFF9500);
  static const Color _rojo = Color(0xFFFF3B30);
  static const Color _morado = Color(0xFFAF52DE);

  static final FontWeight _w650 =
      FontWeight.lerp(FontWeight.w600, FontWeight.w700, 0.5)!;

  // ============================================================
  // ESTADO
  // ============================================================

  String seccionSeleccionada = 'Inicio';

  bool _cerrandoSesion = false;

  late final AnimationController _salidaCtrl;

  late final Animation<double> _fadeSalida;
  late final Animation<Offset> _slideSalida;
  late final Animation<double> _scaleSalida;

  // ============================================================
  // DATOS USUARIO
  // ============================================================

  String get _usuarioNombre {
    return AuthService.usuario ?? 'Usuario';
  }

  String get _usuarioRol {
    return AuthService.rol ?? 'Administrador';
  }

  String get _usuarioInicial {
    final nombre = _usuarioNombre.trim();

    if (nombre.isEmpty) {
      return 'U';
    }

    return nombre.substring(0, 1).toUpperCase();
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _salidaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeSalida = CurvedAnimation(
      parent: _salidaCtrl,
      curve: Curves.easeOutCubic,
    );

    _slideSalida = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.025),
    ).animate(
      CurvedAnimation(
        parent: _salidaCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleSalida = Tween<double>(
      begin: 1,
      end: 0.985,
    ).animate(
      CurvedAnimation(
        parent: _salidaCtrl,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _salidaCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // NAVEGACIÓN
  // ============================================================

  void _seleccionarSeccion(String seccion) {
    if (seccion == seccionSeleccionada) return;

    setState(() {
      seccionSeleccionada = seccion;
    });
  }

  Widget _contenidoActual() {
    switch (seccionSeleccionada) {
      case 'Obras':
        return const ObrasScreen();

      case 'Cuadrillas':
        return const CuadrillasScreen();

      case 'Archivos':
        return const ArchivosScreen();

      case 'Asistencia':
        return const AsistenciaScreen();

      case 'Materiales':
        return const MaterialesScreen();

      case 'Herramientas':
        return const HerramientasScreen();

      case 'Usuarios':
        return const UsuariosScreen();

      case 'Perfil':
        return const PerfilScreen();

      case 'Configuración':
        return const ConfiguracionScreen();

      case 'Inicio':
      default:
        return _buildInicio();
    }
  }

  // ============================================================
  // CERRAR SESIÓN
  // ============================================================

  void _confirmarCerrarSesion() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar sesión',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return const _DialogoCerrarSesion();
      },
      transitionBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final curva = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curva,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1.0,
            ).animate(curva),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curva),
              child: child,
            ),
          ),
        );
      },
    ).then((resultado) {
      if (resultado == true && mounted) {
        _cerrarSesion();
      }
    });
  }

  Future<void> _cerrarSesion() async {
    if (_cerrandoSesion) return;

    setState(() {
      _cerrandoSesion = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 180),
    );

    if (!mounted) return;

    await _salidaCtrl.forward();

    AuthService.cerrarSesion();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const LoginScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final curva = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curva,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(curva),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.985,
                  end: 1.0,
                ).animate(curva),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey(seccionSeleccionada),
                    child: _contenidoActual(),
                  ),
                ),
              ),
            ],
          ),
          if (_cerrandoSesion)
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeSalida,
                child: Container(
                  color: _fondo,
                  child: SlideTransition(
                    position: _slideSalida,
                    child: ScaleTransition(
                      scale: _scaleSalida,
                      child: Center(
                        child: _buildCargandoSalida(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SIDEBAR
  // ============================================================

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: _sidebar,
        border: Border(
          right: BorderSide(
            color: _borde,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            // ----------------------------------------------------
            // MARCA
            // ----------------------------------------------------

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: _buildBrand(),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------
            // NAVEGACIÓN
            // ----------------------------------------------------

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Column(
                  children: [
                    _buildSectionLabel('GENERAL'),

                    const SizedBox(height: 6),

                    _buildMenuItem(
                      icon: CupertinoIcons.house_fill,
                      label: 'Inicio',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.building_2_fill,
                      label: 'Obras',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.person_3_fill,
                      label: 'Cuadrillas',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.checkmark_square_fill,
                      label: 'Asistencia',
                    ),

                    const SizedBox(height: 18),

                    _buildSectionLabel('RECURSOS'),

                    const SizedBox(height: 6),

                    _buildMenuItem(
                      icon: CupertinoIcons.cube_box_fill,
                      label: 'Materiales',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.wrench_fill,
                      label: 'Herramientas',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.person_crop_circle_fill,
                      label: 'Usuarios',
                    ),

                    const SizedBox(height: 18),

                    _buildSectionLabel('SISTEMA'),

                    const SizedBox(height: 6),

                    _buildMenuItem(
                      icon: CupertinoIcons.person_fill,
                      label: 'Perfil',
                    ),

                    _buildMenuItem(
                      icon: CupertinoIcons.gear_solid,
                      label: 'Configuración',
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // PERFIL
            // ----------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                5,
                13,
                9,
              ),
              child: _buildProfileCard(),
            ),

            // ----------------------------------------------------
            // CERRAR SESIÓN
            // ----------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                0,
                13,
                14,
              ),
              child: _buildLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _texto,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CEYRSA',
                  style: TextStyle(
                    color: _texto,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gestión de obra',
                  style: TextStyle(
                    color: _secundario,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 13,
            color: _terciario,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: const TextStyle(
            color: _terciario,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
  }) {
    final seleccionado =
        seccionSeleccionada == label;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _seleccionarSeccion(label),
          borderRadius: BorderRadius.circular(11),
          hoverColor: Colors.black.withOpacity(0.035),
          splashColor: Colors.black.withOpacity(0.025),
          highlightColor: Colors.black.withOpacity(0.02),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            height: 42,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: seleccionado
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: seleccionado
                  ? Border.all(
                      color: const Color(0xFFE8E8EB),
                    )
                  : null,
              boxShadow: seleccionado
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.035),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? const Color(0xFFF1F1F3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 17,
                    color: seleccionado
                        ? _texto
                        : _secundario,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: seleccionado
                          ? _texto
                          : _secundario,
                      fontSize: 12.5,
                      fontWeight: seleccionado
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: seleccionado ? 1 : 0,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: _azul,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _seleccionarSeccion('Perfil'),
        borderRadius: BorderRadius.circular(14),
        hoverColor: Colors.black.withOpacity(0.025),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _borde,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _texto,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _usuarioInicial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _usuarioNombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _texto,
                        fontSize: 11.5,
                        fontWeight: _w650,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _usuarioRol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _secundario,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 12,
                color: _terciario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _confirmarCerrarSesion,
        borderRadius: BorderRadius.circular(11),
        hoverColor: _rojo.withOpacity(0.035),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: _borde,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                CupertinoIcons.square_arrow_right,
                size: 17,
                color: _rojo,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: _texto,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 11,
                color: _terciario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INICIO
  // ============================================================

  Widget _buildInicio() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 1000
                ? 28
                : 42,
            vertical: 30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1500,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSessionCard(),
                  const SizedBox(height: 22),
                  _buildKpis(),
                  const SizedBox(height: 24),
                  _buildDashboardColumns(
                    constraints.maxWidth,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Inicio',
                style: TextStyle(
                  color: _texto,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Resumen general de CEYRSA',
                style: TextStyle(
                  color: _secundario,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        _buildSystemPill(),
      ],
    );
  }

  Widget _buildSystemPill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _verde,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          const Text(
            'Sistema activo',
            style: TextStyle(
              color: _secundario,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SESIÓN
  // ============================================================

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              size: 23,
              color: _texto,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sesión actual',
                  style: TextStyle(
                    color: _secundario,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _usuarioNombre,
                  style: TextStyle(
                    color: _texto,
                    fontSize: 16,
                    fontWeight: _w650,
                  ),
                ),
              ],
            ),
          ),
          _buildRolePill(),
        ],
      ),
    );
  }

  Widget _buildRolePill() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _usuarioRol,
        style: TextStyle(
          color: _secundario,
          fontSize: 11,
          fontWeight: _w650,
        ),
      ),
    );
  }

  // ============================================================
  // KPIS
  // ============================================================

  Widget _buildKpis() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;

        double cardWidth;

        if (ancho >= 1150) {
          cardWidth = (ancho - 48) / 4;
        } else if (ancho >= 800) {
          cardWidth = (ancho - 16) / 2;
        } else {
          cardWidth = ancho;
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildKpiCard(
              width: cardWidth,
              icon: CupertinoIcons.building_2_fill,
              titulo: 'Obras activas',
              valor: '3',
              detalle: 'En operación',
              color: _azul,
              onTap: () => _seleccionarSeccion('Obras'),
            ),
            _buildKpiCard(
              width: cardWidth,
              icon: CupertinoIcons.doc_text,
              titulo: 'Bitácoras',
              valor: '18',
              detalle: 'Registradas',
              color: _morado,
              onTap: () => _seleccionarSeccion('Obras'),
            ),
            _buildKpiCard(
              width: cardWidth,
              icon: CupertinoIcons.cube_box_fill,
              titulo: 'Materiales',
              valor: '24',
              detalle: 'En inventario',
              color: _naranja,
              onTap: () => _seleccionarSeccion('Materiales'),
            ),
            _buildKpiCard(
              width: cardWidth,
              icon: CupertinoIcons.person_3_fill,
              titulo: 'Personal',
              valor: '12',
              detalle: 'Registrados',
              color: _verde,
              onTap: () => _seleccionarSeccion('Usuarios'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required double width,
    required IconData icon,
    required String titulo,
    required String valor,
    required String detalle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _blanco,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: _borde,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
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
                        titulo,
                        style: const TextStyle(
                          color: _secundario,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.baseline,
                        textBaseline:
                            TextBaseline.alphabetic,
                        children: [
                          Text(
                            valor,
                            style: const TextStyle(
                              color: _texto,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            detalle,
                            style: const TextStyle(
                              color: _secundario,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COLUMNAS
  // ============================================================

  Widget _buildDashboardColumns(double maxWidth) {
    if (maxWidth < 1000) {
      return Column(
        children: [
          _buildObrasRecientes(),
          const SizedBox(height: 18),
          _buildActividadReciente(),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildObrasRecientes(),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 2,
          child: _buildActividadReciente(),
        ),
      ],
    );
  }

  // ============================================================
  // OBRAS
  // ============================================================

  Widget _buildObrasRecientes() {
    return _buildPanel(
      titulo: 'Obras recientes',
      icono: CupertinoIcons.building_2_fill,
      accion: 'Ver todas',
      onAccion: () {
        _seleccionarSeccion('Obras');
      },
      child: Column(
        children: [
          _buildObraItem(
            nombre: 'Industrial Park Norte',
            estado: 'Activa',
            color: _verde,
          ),
          const Divider(
            height: 1,
            color: _borde,
          ),
          _buildObraItem(
            nombre: 'Plaza Centro',
            estado: 'Activa',
            color: _verde,
          ),
          const Divider(
            height: 1,
            color: _borde,
          ),
          _buildObraItem(
            nombre: 'TRI TEKTURA',
            estado: 'En revisión',
            color: _naranja,
          ),
        ],
      ),
    );
  }

  Widget _buildObraItem({
    required String nombre,
    required String estado,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.building_2_fill,
              size: 17,
              color: _secundario,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _texto,
                fontSize: 13,
                fontWeight: _w650,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusPill(
            texto: estado,
            color: color,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVIDAD
  // ============================================================

  Widget _buildActividadReciente() {
    return _buildPanel(
      titulo: 'Actividad reciente',
      icono: CupertinoIcons.clock,
      accion: 'Ver todas',
      onAccion: () {},
      child: Column(
        children: [
          _buildActividadItem(
            icon: CupertinoIcons.doc_text,
            color: _morado,
            titulo: 'Nueva bitácora registrada',
            detalle: 'Industrial Park Norte',
          ),
          const Divider(
            height: 1,
            color: _borde,
          ),
          _buildActividadItem(
            icon: CupertinoIcons.cube_box,
            color: _naranja,
            titulo: 'Material agregado',
            detalle: 'Sistema epóxico',
          ),
          const Divider(
            height: 1,
            color: _borde,
          ),
          _buildActividadItem(
            icon: CupertinoIcons.person_add,
            color: _azul,
            titulo: 'Nuevo usuario',
            detalle: 'Personal de obra',
          ),
        ],
      ),
    );
  }

  Widget _buildActividadItem({
    required IconData icon,
    required Color color,
    required String titulo,
    required String detalle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _texto,
                    fontSize: 12,
                    fontWeight: _w650,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secundario,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL
  // ============================================================

  Widget _buildPanel({
    required String titulo,
    required IconData icono,
    required String accion,
    required VoidCallback onAccion,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _blanco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borde,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              16,
              14,
              14,
            ),
            child: Row(
              children: [
                Icon(
                  icono,
                  size: 17,
                  color: _secundario,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: _texto,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onAccion,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    accion,
                    style: TextStyle(
                      color: _azul,
                      fontSize: 11,
                      fontWeight: _w650,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: _borde,
          ),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusPill({
    required String texto,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: _w650,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARGANDO SALIDA
  // ============================================================

  Widget _buildCargandoSalida() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borde,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _azul,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Cerrando sesión...',
            style: TextStyle(
              color: _texto,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DIÁLOGO CERRAR SESIÓN
// ============================================================

class _DialogoCerrarSesion extends StatelessWidget {
  const _DialogoCerrarSesion();

  static const Color _texto = Color(0xFF1D1D1F);
  static const Color _secundario = Color(0xFF6E6E73);
  static const Color _borde = Color(0xFFE3E3E6);
  static const Color _rojo = Color(0xFFFF3B30);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 390,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          padding: const EdgeInsets.fromLTRB(
            24,
            23,
            24,
            20,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borde,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _rojo.withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.square_arrow_right,
                  color: _rojo,
                  size: 22,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: _texto,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                '¿Seguro que deseas cerrar tu sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secundario,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _boton(
                      context: context,
                      texto: 'Cancelar',
                      color: _texto,
                      fondo: const Color(0xFFF5F5F7),
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _boton(
                      context: context,
                      texto: 'Cerrar sesión',
                      color: Colors.white,
                      fondo: _rojo,
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boton({
    required BuildContext context,
    required String texto,
    required Color color,
    required Color fondo,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: fondo,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: fondo == Colors.white
                  ? _borde
                  : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}