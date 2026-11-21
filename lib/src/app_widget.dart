import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import 'modules/history/controller/history_controller.dart';
import 'modules/history/page/history_page.dart';
import 'modules/home/controller/home_controller.dart';
import 'modules/home/page/home_page.dart';
import 'modules/initial/page/initial_page.dart';
import 'routes/app_routes.dart';
import 'shared/colors/app_colors.dart';
import 'shared/colors/tema_controller.dart';
import 'shared/storage/preferencias_repository.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({
    super.key,
    this.tema,
    this.criarHomeController,
    this.criarHistoryController,
  });

  final TemaController? tema;
  final HomeController Function()? criarHomeController;
  final HistoryController Function()? criarHistoryController;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final TemaController _tema =
      widget.tema ?? (TemaController(PreferenciasEmMemoria())..carregar());

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: 'FastLocation',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const _RolagemSemEsticar(),
        theme: AppTheme.claro,
        darkTheme: AppTheme.escuro,
        themeMode: _tema.modo,
        initialRoute: AppRoutes.initial,
        routes: {
          AppRoutes.initial: (_) => const InitialPage(),
          AppRoutes.home: (_) => HomePage(
            controller: widget.criarHomeController?.call(),
            tema: _tema,
          ),
          AppRoutes.history: (_) => HistoryPage(
            controller: widget.criarHistoryController?.call(),
            tema: _tema,
          ),
        },
      ),
    );
  }
}

class _RolagemSemEsticar extends MaterialScrollBehavior {
  const _RolagemSemEsticar();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: context.cores.destaque,
      child: child,
    );
  }
}
