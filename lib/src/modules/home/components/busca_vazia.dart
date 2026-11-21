import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_feedback.dart';

class BuscaVazia extends StatelessWidget {
  const BuscaVazia.inicial({super.key})
    : icone = Icons.travel_explore,
      titulo = 'Nenhuma consulta ainda',
      mensagem = 'Busque pelo CEP ou pelo endereço para ver o resultado aqui.',
      deErro = false;

  const BuscaVazia.naoEncontrado({super.key, required this.mensagem})
    : icone = Icons.search_off,
      titulo = 'Nenhum endereço encontrado',
      deErro = true;

  final IconData icone;
  final String titulo;
  final String mensagem;
  final bool deErro;

  @override
  Widget build(BuildContext context) {
    return AppFeedback(
      icone: icone,
      titulo: titulo,
      mensagem: mensagem,
      cor: deErro ? context.esquema.error : null,
    );
  }
}
