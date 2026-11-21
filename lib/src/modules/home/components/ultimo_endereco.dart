import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/endereco_model.dart';
import 'endereco_card.dart';

class UltimoEndereco extends StatelessWidget {
  const UltimoEndereco({
    super.key,
    required this.endereco,
    required this.onTracarRota,
    this.abrindoRota = false,
  });

  final EnderecoModel endereco;
  final VoidCallback onTracarRota;
  final bool abrindoRota;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Último endereço consultado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.cores.texto,
          ),
        ),
        const SizedBox(height: AppMetrics.spacingXs),
        EnderecoCard(endereco: endereco, selecionado: true, mostrarData: true),
        const SizedBox(height: AppMetrics.spacingSm),
        SizedBox(
          height: AppMetrics.buttonHeight,
          child: FilledButton.icon(
            onPressed: abrindoRota ? null : onTracarRota,
            icon: abrindoRota
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.directions),
            label: Text(abrindoRota ? 'Abrindo o mapa...' : 'Traçar rota'),
          ),
        ),
      ],
    );
  }
}
