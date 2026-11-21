import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.mensagem = 'Carregando...'});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.esquema.primary),
            const SizedBox(height: AppMetrics.spacingMd),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.cores.textoSuave),
            ),
          ],
        ),
      ),
    );
  }
}
