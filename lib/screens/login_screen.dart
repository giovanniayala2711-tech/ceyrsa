import 'dart:math';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'inicio_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // =========================================================
  // CONTROLADORES
  // =========================================================

  final TextEditingController _codigoController =
      TextEditingController();

  final FocusNode _codigoFocus = FocusNode();

  late final AnimationController _animacionCtrl;
  late final AnimationController _exitoCtrl;
  late final AnimationController _shakeCtrl;
  late final AnimationController _lavaCtrl;

  // =========================================================
  // ESTADO
  // =========================================================

  String _entrada = '';
  String mensaje = '';

  bool _verificando = false;
  bool _verificado = false;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------
    // ANIMACIÓN DE ENTRADA
    // -------------------------------------------------------

    _animacionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    // -------------------------------------------------------
    // ANIMACIÓN DE ÉXITO
    // -------------------------------------------------------

    _exitoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 700,
      ),
    );

    // -------------------------------------------------------
    // ANIMACIÓN DEL ERROR
    // -------------------------------------------------------

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 450,
      ),
    );

    // -------------------------------------------------------
    // ANIMACIÓN LÁMPARA DE LAVA
    // -------------------------------------------------------

    _lavaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 24,
      ),
    )..repeat();

    // -------------------------------------------------------
    // LISTENER DEL CÓDIGO
    // -------------------------------------------------------

    _codigoController.addListener(
      _alCambiarCodigo,
    );

    // -------------------------------------------------------
    // ANIMACIÓN DE ENTRADA
    // -------------------------------------------------------

    _animacionCtrl.forward();

    // -------------------------------------------------------
    // RECUPERAR EL FOCO
    // -------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _codigoFocus.requestFocus();
        }
      },
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _codigoController.removeListener(
      _alCambiarCodigo,
    );

    _codigoController.dispose();
    _codigoFocus.dispose();

    _animacionCtrl.dispose();
    _exitoCtrl.dispose();
    _shakeCtrl.dispose();
    _lavaCtrl.dispose();

    super.dispose();
  }

  // =========================================================
  // CAMBIO DEL CÓDIGO
  // =========================================================

  void _alCambiarCodigo() {
    if (_verificando || _verificado) {
      return;
    }

    String valorLimpio = _codigoController.text
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (valorLimpio.length > 5) {
      valorLimpio = valorLimpio.substring(0, 5);
    }

    if (_codigoController.text != valorLimpio) {
      _codigoController.value = TextEditingValue(
        text: valorLimpio,
        selection: TextSelection.collapsed(
          offset: valorLimpio.length,
        ),
      );
    }

    if (_entrada != valorLimpio) {
      setState(() {
        _entrada = valorLimpio;

        if (_entrada.isNotEmpty) {
          mensaje = '';
        }
      });
    }

    // -------------------------------------------------------
    // VERIFICACIÓN AUTOMÁTICA
    // -------------------------------------------------------

    if (_entrada.length == 5) {
      _verificarCodigo();
    }
  }

  // =========================================================
  // VERIFICAR CÓDIGO
  // =========================================================

  Future<void> _verificarCodigo() async {
    if (_verificando ||
        _verificado ||
        _entrada.length != 5) {
      return;
    }

    setState(() {
      _verificando = true;
      mensaje = '';
    });

    await Future.delayed(
      const Duration(
        milliseconds: 650,
      ),
    );

    if (!mounted) {
      return;
    }

    final correcto = AuthService.iniciarSesion(
      _entrada,
    );

    // =======================================================
    // CÓDIGO INCORRECTO
    // =======================================================

    if (!correcto) {
      setState(() {
        _verificando = false;
        _verificado = false;
        mensaje = 'Código incorrecto';
      });

      _shakeCtrl.forward(
        from: 0,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 180,
        ),
      );

      if (!mounted) {
        return;
      }

      _codigoController.clear();

      setState(() {
        _entrada = '';
      });

      _codigoFocus.requestFocus();

      return;
    }

    // =======================================================
    // CÓDIGO CORRECTO
    // =======================================================

    _codigoFocus.unfocus();

    setState(() {
      _verificando = false;
      _verificado = true;
      mensaje = '';
    });

    await _exitoCtrl.forward();

    if (!mounted) {
      return;
    }

    await Future.delayed(
      const Duration(
        milliseconds: 250,
      ),
    );

    if (!mounted) {
      return;
    }

    // =======================================================
    // IR A INICIO
    // =======================================================

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 800,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 450,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const InicioScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          final slide = Tween<Offset>(
            begin: const Offset(
              0,
              0.035,
            ),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          final scale = Tween<double>(
            begin: 0.985,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // IDENTIFICADOR DEL USUARIO
  // =========================================================

  String get _identificadorUsuario {
    return AuthService.usuarioActual?['identificador']
            ?.toString() ??
        '';
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF07090D,
      ),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final ancho = constraints.maxWidth;
          final alto = constraints.maxHeight;

          final compacto = ancho < 700;
          final movil = ancho < 500;

          final paddingHorizontal = movil
              ? 22.0
              : compacto
                  ? 40.0
                  : 70.0;

          return SafeArea(
            child: Stack(
              children: [
                // =================================================
                // FONDO LÁMPARA DE LAVA
                // =================================================

                Positioned.fill(
                  child: _fondoLava(
                    ancho,
                    alto,
                  ),
                ),

                // =================================================
                // CONTENIDO
                // =================================================

                Center(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          paddingHorizontal,
                      vertical: movil
                          ? 25
                          : 40,
                    ),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: FadeTransition(
                        opacity:
                            CurvedAnimation(
                          parent:
                              _animacionCtrl,
                          curve:
                              Curves.easeOut,
                        ),
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                            begin:
                                const Offset(
                              0,
                              0.035,
                            ),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent:
                                  _animacionCtrl,
                              curve:
                                  Curves.easeOutCubic,
                            ),
                          ),
                          child:
                              _contenidoLogin(
                            movil,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // =================================================
                // CAMPO OCULTO
                // =================================================

                Positioned(
                  left: 0,
                  top: 0,
                  child: SizedBox(
                    width: 1,
                    height: 1,
                    child: TextField(
                      controller:
                          _codigoController,
                      focusNode:
                          _codigoFocus,
                      autofocus: false,
                      keyboardType:
                          TextInputType.number,
                      textInputAction:
                          TextInputAction.done,
                      maxLength: 5,
                      showCursor: false,
                      cursorColor:
                          Colors.transparent,
                      style:
                          const TextStyle(
                        color:
                            Colors.transparent,
                        fontSize: 1,
                      ),
                      decoration:
                          const InputDecoration(
                        border:
                            InputBorder.none,
                        counterText: '',
                        contentPadding:
                            EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // CONTENIDO LOGIN
  // =========================================================

  Widget _contenidoLogin(
    bool movil,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        // =====================================================
        // LOGO
        // =====================================================

        Container(
          width: movil ? 74 : 84,
          height: movil ? 74 : 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(
                0xFFFF8A00,
              ).withOpacity(
                0.85,
              ),
              width: 2,
            ),
            color: const Color(
              0xFFFF8A00,
            ).withOpacity(
              0.08,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFF8A00,
                ).withOpacity(
                  0.16,
                ),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.engineering_outlined,
            color: const Color(
              0xFFFF8A00,
            ),
            size: movil ? 34 : 40,
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        const Text(
          'CEYRSA',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            color: Colors.white,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        const Text(
          'Sistema de gestión',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white54,
            letterSpacing: 0.3,
          ),
        ),

        const SizedBox(
          height: 46,
        ),

        // =====================================================
        // TÍTULO
        // =====================================================

        const Text(
          'Ingresa tu código',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.w700,
            color: Colors.white,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        const Text(
          'Escribe tu código de acceso de 5 dígitos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white38,
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        // =====================================================
        // CUADROS
        // =====================================================

        GestureDetector(
          behavior:
              HitTestBehavior.opaque,
          onTap: () {
            if (!_verificando &&
                !_verificado) {
              _codigoFocus.requestFocus();
            }
          },
          child: _cuadrosCodigo(
            movil,
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // IDENTIFICADOR DEL USUARIO
        // =====================================================

        AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 350,
          ),
          switchInCurve:
              Curves.easeOutCubic,
          switchOutCurve:
              Curves.easeInCubic,
          transitionBuilder:
              (
            child,
            animation,
          ) {
            final slide =
                Tween<Offset>(
              begin:
                  const Offset(
                0,
                0.25,
              ),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve:
                    Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
          child: _verificado &&
                  _identificadorUsuario
                      .isNotEmpty
              ? Text(
                  _identificadorUsuario,
                  key: const ValueKey(
                    'identificador',
                  ),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing:
                        1.2,
                    color:
                        Color(
                      0xFFFF8A00,
                    ),
                  ),
                )
              : const SizedBox(
                  key: ValueKey(
                    'sinIdentificador',
                  ),
                  height: 18,
                ),
        ),

        const SizedBox(
          height: 18,
        ),

        // =====================================================
        // MENSAJE
        // =====================================================

        SizedBox(
          height: 22,
          child: AnimatedSwitcher(
            duration:
                const Duration(
              milliseconds: 250,
            ),
            child: _verificando
                ? const Row(
                    key: ValueKey(
                      'verificando',
                    ),
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Color(
                            0xFFFF8A00,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Text(
                        'Verificando...',
                        style:
                            TextStyle(
                          fontSize: 13,
                          color:
                              Colors
                                  .white54,
                        ),
                      ),
                    ],
                  )
                : mensaje.isNotEmpty
                    ? Text(
                        mensaje,
                        key:
                            const ValueKey(
                          'error',
                        ),
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Colors.redAccent,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey(
                          'vacio',
                        ),
                      ),
          ),
        ),

        const SizedBox(
          height: 30,
        ),

        // =====================================================
        // ESTADO
        // =====================================================

        AnimatedSwitcher(
          duration:
              const Duration(
            milliseconds: 350,
          ),
          child: _verificado
              ? _indicadorExito()
              : const Text(
                  'El acceso se verificará automáticamente',
                  key: ValueKey(
                    'ayuda',
                  ),
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.white24,
                  ),
                ),
        ),
      ],
    );
  }

  // =========================================================
  // CUADROS DEL CÓDIGO
  // =========================================================

  Widget _cuadrosCodigo(
    bool movil,
  ) {
    final anchoCuadro =
        movil ? 48.0 : 58.0;

    final altoCuadro =
        movil ? 62.0 : 70.0;

    final separacion =
        movil ? 7.0 : 10.0;

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (
        context,
        child,
      ) {
        final valor =
            Curves.easeInOut.transform(
          _shakeCtrl.value,
        );

        final desplazamiento =
            valor <= 0.5
                ? valor * 2
                : (1 - valor) * 2;

        final direccion =
            (_shakeCtrl.value * 8)
                    .round()
                    .isEven
                ? 1
                : -1;

        return Transform.translate(
          offset: Offset(
            _shakeCtrl.isAnimating
                ? desplazamiento *
                    7 *
                    direccion
                : 0,
            0,
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) {
            final activo =
                !_verificado &&
                !_verificando &&
                _codigoFocus.hasFocus &&
                index ==
                    _entrada.length;

            final ocupado =
                index <
                    _entrada.length;

            final mostrarExito =
                _verificado;

            String caracter = '';

            if (ocupado) {
              caracter =
                  _entrada[index];
            }

            return AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              curve:
                  Curves.easeOutCubic,
              width: anchoCuadro,
              height: altoCuadro,
              margin:
                  EdgeInsets.symmetric(
                horizontal:
                    separacion / 2,
              ),
              decoration:
                  BoxDecoration(
                color: mostrarExito
                    ? const Color(
                        0xFFFF8A00,
                      ).withOpacity(
                        0.12,
                      )
                    : activo
                        ? const Color(
                            0xFFFF8A00,
                          ).withOpacity(
                            0.08,
                          )
                        : Colors.white
                            .withOpacity(
                            ocupado
                                ? 0.075
                                : 0.035,
                          ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                border: Border.all(
                  color: mostrarExito
                      ? const Color(
                          0xFFFF8A00,
                        )
                      : activo
                          ? const Color(
                              0xFFFF8A00,
                            )
                          : Colors.white
                              .withOpacity(
                              ocupado
                                  ? 0.22
                                  : 0.09,
                            ),
                  width:
                      activo ||
                              mostrarExito
                          ? 2
                          : 1,
                ),
                boxShadow:
                    activo ||
                            mostrarExito
                        ? [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFFFF8A00,
                              ).withOpacity(
                                0.16,
                              ),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
              ),
              child: Stack(
                alignment:
                    Alignment.center,
                children: [
                  // =========================================
                  // NÚMERO
                  // =========================================

                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 130,
                    ),
                    transitionBuilder:
                        (
                      child,
                      animation,
                    ) {
                      return ScaleTransition(
                        scale: animation,
                        child:
                            FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: mostrarExito
                        ? const Icon(
                            Icons.check_rounded,
                            key: ValueKey(
                              'check',
                            ),
                            color:
                                Color(
                              0xFFFF8A00,
                            ),
                            size: 29,
                          )
                        : caracter.isNotEmpty
                            ? Text(
                                caracter,
                                key:
                                    ValueKey(
                                  caracter,
                                ),
                                style:
                                    TextStyle(
                                  fontSize:
                                      movil
                                          ? 25
                                          : 29,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color:
                                      Colors
                                          .white,
                                ),
                              )
                            : const SizedBox(
                                key:
                                    ValueKey(
                                  'vacio',
                                ),
                              ),
                  ),

                  // =========================================
                  // CURSOR
                  // =========================================

                  if (activo)
                    Positioned(
                      bottom: 14,
                      child:
                          _cursorParpadeante(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // CURSOR
  // =========================================================

  Widget _cursorParpadeante() {
    return const _CursorAnimado(
      color: Color(
        0xFFFF8A00,
      ),
    );
  }

  // =========================================================
  // INDICADOR DE ÉXITO
  // =========================================================

  Widget _indicadorExito() {
    return Row(
      key: const ValueKey(
        'exito',
      ),
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration:
              BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(
              0xFFFF8A00,
            ).withOpacity(
              0.12,
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 15,
            color: Color(
              0xFFFF8A00,
            ),
          ),
        ),
        const SizedBox(
          width: 9,
        ),
        const Text(
          'Acceso autorizado',
          style: TextStyle(
            fontSize: 13,
            color: Color(
              0xFFFF8A00,
            ),
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // FONDO LÁMPARA DE LAVA
  // =========================================================

  Widget _fondoLava(
    double ancho,
    double alto,
  ) {
    return AnimatedBuilder(
      animation: _lavaCtrl,
      builder: (
        context,
        child,
      ) {
        final t =
            _lavaCtrl.value *
                2 *
                pi;

        return Stack(
          clipBehavior:
              Clip.hardEdge,
          children: [
            // =================================================
            // FONDO
            // =================================================

            Positioned.fill(
              child: Container(
                color: const Color(
                  0xFF07090D,
                ),
              ),
            ),

            // =================================================
            // MASA SUPERIOR IZQUIERDA
            // =================================================

            Positioned(
              left: ancho * 0.02 +
                  sin(t * 0.72) *
                      ancho *
                      0.12,
              top: alto * 0.02 +
                  cos(t * 0.53) *
                      alto *
                      0.12,
              child: _masaLava(
                width:
                    ancho * 0.55,
                height:
                    alto * 0.42,
                rotation:
                    sin(t * 0.31) *
                        0.12,
                opacity: 0.055,
                radius1:
                    ancho * 0.40,
                radius2:
                    ancho * 0.28,
                radius3:
                    ancho * 0.48,
                radius4:
                    ancho * 0.32,
              ),
            ),

            // =================================================
            // MASA DERECHA
            // =================================================

            Positioned(
              right: -ancho * 0.20 +
                  cos(t * 0.47) *
                      ancho *
                      0.14,
              top: alto * 0.20 +
                  sin(t * 0.62) *
                      alto *
                      0.17,
              child: _masaLava(
                width:
                    ancho * 0.58,
                height:
                    alto * 0.48,
                rotation:
                    cos(t * 0.28) *
                        0.10,
                opacity: 0.045,
                radius1:
                    ancho * 0.30,
                radius2:
                    ancho * 0.48,
                radius3:
                    ancho * 0.35,
                radius4:
                    ancho * 0.42,
              ),
            ),

            // =================================================
            // MASA INFERIOR IZQUIERDA
            // =================================================

            Positioned(
              left: -ancho * 0.08 +
                  cos(t * 0.40) *
                      ancho *
                      0.16,
              bottom: -alto * 0.13 +
                  sin(t * 0.55) *
                      alto *
                      0.13,
              child: _masaLava(
                width:
                    ancho * 0.62,
                height:
                    alto * 0.43,
                rotation:
                    sin(t * 0.25) *
                        0.13,
                opacity: 0.042,
                radius1:
                    ancho * 0.47,
                radius2:
                    ancho * 0.32,
                radius3:
                    ancho * 0.38,
                radius4:
                    ancho * 0.50,
              ),
            ),

            // =================================================
            // MASA INFERIOR DERECHA
            // =================================================

            Positioned(
              right: -ancho * 0.04 +
                  sin(t * 0.51) *
                      ancho *
                      0.12,
              bottom: -alto * 0.08 +
                  cos(t * 0.44) *
                      alto *
                      0.13,
              child: _masaLava(
                width:
                    ancho * 0.52,
                height:
                    alto * 0.39,
                rotation:
                    cos(t * 0.32) *
                        0.11,
                opacity: 0.035,
                radius1:
                    ancho * 0.35,
                radius2:
                    ancho * 0.48,
                radius3:
                    ancho * 0.42,
                radius4:
                    ancho * 0.30,
              ),
            ),

            // =================================================
            // MASA CENTRAL
            // =================================================

            Positioned(
              left: ancho * 0.25 +
                  sin(t * 0.29) *
                      ancho *
                      0.09,
              top: alto * 0.15 +
                  cos(t * 0.34) *
                      alto *
                      0.08,
              child: _masaLava(
                width:
                    ancho * 0.38,
                height:
                    alto * 0.62,
                rotation:
                    sin(t * 0.20) *
                        0.08,
                opacity: 0.025,
                radius1:
                    ancho * 0.32,
                radius2:
                    ancho * 0.40,
                radius3:
                    ancho * 0.35,
                radius4:
                    ancho * 0.43,
              ),
            ),

            // =================================================
            // BRUMA CENTRAL
            // =================================================

            Positioned(
              left: ancho * 0.15 +
                  cos(t * 0.23) *
                      ancho *
                      0.10,
              top: alto * 0.38 +
                  sin(t * 0.27) *
                      alto *
                      0.10,
              child: Container(
                width:
                    ancho * 0.70,
                height:
                    alto * 0.28,
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    ancho,
                  ),
                  color:
                      const Color(
                    0xFFFF8A00,
                  ).withOpacity(
                    0.012,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // MASA INDIVIDUAL DE LAVA
  // =========================================================

  Widget _masaLava({
    required double width,
    required double height,
    required double rotation,
    required double opacity,
    required double radius1,
    required double radius2,
    required double radius3,
    required double radius4,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.only(
            topLeft:
                Radius.circular(
              radius1,
            ),
            topRight:
                Radius.circular(
              radius2,
            ),
            bottomLeft:
                Radius.circular(
              radius3,
            ),
            bottomRight:
                Radius.circular(
              radius4,
            ),
          ),
          color: const Color(
            0xFFFF7A00,
          ).withOpacity(
            opacity,
          ),
        ),
      ),
    );
  }
}

// ===========================================================
// CURSOR ANIMADO
// ===========================================================

class _CursorAnimado
    extends StatefulWidget {
  final Color color;

  const _CursorAnimado({
    required this.color,
  });

  @override
  State<_CursorAnimado> createState() =>
      _CursorAnimadoState();
}

class _CursorAnimadoState
    extends State<_CursorAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController
      _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 650,
      ),
    )..repeat(
        reverse: true,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return FadeTransition(
      opacity:
          Tween<double>(
        begin: 0.15,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      ),
      child: Container(
        width: 2,
        height: 20,
        decoration:
            BoxDecoration(
          color: widget.color,
          borderRadius:
              BorderRadius.circular(
            2,
          ),
        ),
      ),
    );
  }
}