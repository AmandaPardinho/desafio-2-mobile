import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/endereco_model.dart';
import 'endereco_card.dart';

class ListaEnderecos extends StatelessWidget {
  const ListaEnderecos({
    super.key,
    required this.enderecos,
    required this.onSelecionar,
    this.cepSelecionado,
    this.titulo,
    this.dica = 'Toque no endereço certo para selecionar e traçar a rota.',
    this.mostrarData = false,
    this.rodape,
  });

  final List<EnderecoModel> enderecos;
  final ValueChanged<EnderecoModel> onSelecionar;
  final String? cepSelecionado;
  final String? titulo;
  final String dica;
  final bool mostrarData;
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    final quantidade = enderecos.length;
    final tituloFinal =
        titulo ??
        (quantidade == 1
            ? '1 endereço encontrado'
            : '$quantidade endereços encontrados');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tituloFinal,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.cores.texto,
          ),
        ),
        const SizedBox(height: AppMetrics.spacingXs),
        Text(dica, style: TextStyle(color: context.cores.textoSuave)),
        const SizedBox(height: AppMetrics.spacingSm),
        for (final endereco in enderecos)
          EnderecoCard(
            key: ValueKey(endereco.cep),
            endereco: endereco,
            selecionado: endereco.cep == cepSelecionado,
            mostrarData: mostrarData,
            onTap: () => onSelecionar(endereco),
          ),
        rodape ?? const SizedBox.shrink(),
      ],
    );
  }
}
