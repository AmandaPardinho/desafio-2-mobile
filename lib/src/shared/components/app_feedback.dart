import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

class AppFeedback extends StatelessWidget {
  const AppFeedback({
    super.key,
    required this.icone,
    required this.titulo,
    this.mensagem,
    this.cor,
  });

  final IconData icone;
  final String titulo;
  final String? mensagem;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icone,
              size: AppMetrics.iconLg,
              color: cor ?? cores.textoSuave,
            ),
            const SizedBox(height: AppMetrics.spacingMd),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cores.texto,
              ),
            ),
            if (mensagem != null) ...[
              const SizedBox(height: AppMetrics.spacingSm),
              Text(
                mensagem!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cores.textoSuave),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
