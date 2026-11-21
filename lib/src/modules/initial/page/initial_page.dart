import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  static const Duration duracaoAnimacao = Duration(milliseconds: 1400);
  static const Duration pausaAntesDaHome = Duration(milliseconds: 800);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacidade;
  late final Animation<double> _escala;
  late final Animation<Offset> _deslizeTexto;
  Timer? _timerRedirecionamento;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: InitialPage.duracaoAnimacao,
    );

    _opacidade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );

    _escala = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _deslizeTexto = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
          ),
        );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _timerRedirecionamento = Timer(
          InitialPage.pausaAntesDaHome,
          _irParaHome,
        );
      }
    });

    _controller.forward();
  }

  void _irParaHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _timerRedirecionamento?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.cores.splashFundo,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _opacidade,
                child: ScaleTransition(
                  scale: _escala,
                  child: Icon(
                    Icons.location_on,
                    size: AppMetrics.iconXl,
                    color: context.cores.splashIcone,
                  ),
                ),
              ),
              const SizedBox(height: AppMetrics.spacingMd),
              FadeTransition(
                opacity: _opacidade,
                child: SlideTransition(
                  position: _deslizeTexto,
                  child: const Column(
                    children: [
                      Text(
                        'FastLocation',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.branco,
                        ),
                      ),
                      SizedBox(height: AppMetrics.spacingSm),
                      Text(
                        'Endereço certo, entrega no prazo',
                        style: TextStyle(fontSize: 16, color: AppColors.branco),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
