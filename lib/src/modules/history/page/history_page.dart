import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../http/app_http_client.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/colors/tema_controller.dart';
import '../../../shared/components/botao_tema.dart';
import '../../../shared/components/app_feedback.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../../shared/storage/app_storage.dart';
import '../../home/components/endereco_card.dart';
import '../../home/model/endereco_model.dart';
import '../../home/repositories/historico_repository.dart';
import '../../home/repositories/via_cep_repository.dart';
import '../../home/service/endereco_service.dart';
import '../controller/history_controller.dart';

HistoryController criarHistoryController() {
  return HistoryController(
    EnderecoService(
      ViaCepRepository(AppHttpClient.viaCep()),
      HistoricoRepository(Hive.box<EnderecoModel>(StorageBoxes.historico)),
    ),
  );
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.controller, this.tema});

  final HistoryController? controller;
  final TemaController? tema;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final HistoryController _controller =
      widget.controller ?? criarHistoryController();

  late final ReactionDisposer _reacaoErro;

  @override
  void initState() {
    super.initState();
    _controller.carregar();
    _reacaoErro = reaction<String?>((_) => _controller.erro, _mostrarErro);
  }

  @override
  void dispose() {
    _reacaoErro();
    super.dispose();
  }

  void _mostrarErro(String? mensagem) {
    if (mensagem == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mensagem,
            style: TextStyle(color: context.esquema.onError),
          ),
          backgroundColor: context.esquema.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    _controller.limparErro();
  }

  Future<void> _confirmarLimpeza() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text(
          'Todos os endereços consultados serão apagados deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmou == true) {
      await _controller.limpar();
    }
  }

  Future<void> _consultarDeNovo(EnderecoModel endereco) async {
    final ok = await _controller.consultarDeNovo(endereco);
    if (ok && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de consultas'),
        actions: [
          if (widget.tema case final tema?) BotaoTema(controller: tema),
          Observer(
            builder: (_) => IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Limpar histórico',
              onPressed: _controller.enderecos.isEmpty
                  ? null
                  : _confirmarLimpeza,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Observer(
          builder: (_) {
            if (_controller.vazio) {
              return const AppFeedback(
                icone: Icons.history,
                titulo: 'Nenhuma consulta ainda',
                mensagem:
                    'Os endereços que você consultar aparecem aqui, do mais '
                    'recente para o mais antigo.',
              );
            }

            final enderecos = _controller.enderecos;
            return ListView.builder(
              padding: const EdgeInsets.all(AppMetrics.spacingMd),
              itemCount: enderecos.length + 1,
              itemBuilder: (_, indice) {
                if (indice == 0) {
                  return _Cabecalho(quantidade: enderecos.length);
                }
                final endereco = enderecos[indice - 1];
                return EnderecoCard(
                  key: ValueKey(endereco.cep),
                  endereco: endereco,
                  mostrarData: true,
                  selecionado: indice == 1,
                  onTap: () => _consultarDeNovo(endereco),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final titulo = quantidade == 1
        ? '1 endereço consultado'
        : '$quantidade endereços consultados';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppMetrics.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.cores.texto,
            ),
          ),
          const SizedBox(height: AppMetrics.spacingXs),
          Text(
            'Toque num endereço para voltar à busca com ele selecionado.',
            style: TextStyle(color: context.cores.textoSuave),
          ),
        ],
      ),
    );
  }
}
