import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../http/app_http_client.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/colors/tema_controller.dart';
import '../../../shared/components/botao_tema.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../../shared/storage/app_storage.dart';
import '../components/busca_vazia.dart';
import '../components/lista_enderecos.dart';
import '../components/ultimo_endereco.dart';
import '../controller/home_controller.dart';
import '../model/endereco_model.dart';
import '../repositories/historico_repository.dart';
import '../repositories/via_cep_repository.dart';
import '../service/endereco_service.dart';
import '../service/rota_service.dart';

HomeController criarHomeController() {
  return HomeController(
    EnderecoService(
      ViaCepRepository(AppHttpClient.viaCep()),
      HistoricoRepository(Hive.box<EnderecoModel>(StorageBoxes.historico)),
    ),
    RotaService(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller, this.tema});

  final HomeController? controller;
  final TemaController? tema;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller =
      widget.controller ?? criarHomeController();

  final _cep = TextEditingController();
  final _uf = TextEditingController();
  final _cidade = TextEditingController();
  final _logradouro = TextEditingController();

  final _chaveUltimo = GlobalKey();

  late final ReactionDisposer _reacaoErro;

  @override
  void initState() {
    super.initState();
    _controller.carregarUltimo();
    _reacaoErro = reaction<String?>((_) => _controller.erro, _mostrarErro);
  }

  @override
  void dispose() {
    _reacaoErro();
    _cep.dispose();
    _uf.dispose();
    _cidade.dispose();
    _logradouro.dispose();
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

  void _buscar() {
    FocusScope.of(context).unfocus();
    if (_controller.modo == ModoBusca.cep) {
      _controller.consultarCep(_cep.text);
    } else {
      _controller.buscarPorEndereco(
        uf: _uf.text,
        cidade: _cidade.text,
        logradouro: _logradouro.text,
      );
    }
  }

  Future<void> _selecionar(EnderecoModel endereco) async {
    await _controller.selecionarEndereco(endereco);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alvo = _chaveUltimo.currentContext;
      if (alvo == null) return;
      Scrollable.ensureVisible(
        alvo,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
    });
  }

  void _novaConsulta() {
    if (_controller.carregando) return;
    for (final campo in [_cep, _uf, _cidade, _logradouro]) {
      campo.clear();
    }
    _controller.novaConsulta();
  }

  Future<void> _abrirHistorico() async {
    await Navigator.of(context).pushNamed(AppRoutes.history);
    if (!mounted) return;
    _controller.carregarUltimo();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => PopScope(
        canPop: !_controller.temBuscaAtiva,
        onPopInvokedWithResult: (saiu, _) {
          if (!saiu) _novaConsulta();
        },
        child: _tela(),
      ),
    );
  }

  Widget _tela() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastLocation'),
        leading: _controller.temBuscaAtiva && !_controller.carregando
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar para a busca',
                onPressed: _novaConsulta,
              )
            : null,
        actions: [
          if (widget.tema case final tema?) BotaoTema(controller: tema),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de consultas',
            onPressed: _abrirHistorico,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppMetrics.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _formulario(),
              const SizedBox(height: AppMetrics.spacingLg),
              Observer(builder: (_) => _resultado()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
    return Card(
      color: context.esquema.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spacingMd),
        child: Observer(
          builder: (_) {
            final modo = _controller.modo;
            final carregando = _controller.carregando;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<ModoBusca>(
                  segments: const [
                    ButtonSegment(
                      value: ModoBusca.cep,
                      label: Text('Por CEP'),
                      icon: Icon(Icons.pin_drop_outlined),
                    ),
                    ButtonSegment(
                      value: ModoBusca.endereco,
                      label: Text('Por endereço'),
                      icon: Icon(Icons.signpost_outlined),
                    ),
                  ],
                  selected: {modo},
                  onSelectionChanged: carregando
                      ? null
                      : (escolha) => _controller.alterarModo(escolha.first),
                ),
                const SizedBox(height: AppMetrics.spacingMd),
                if (modo == ModoBusca.cep)
                  _campoCep()
                else
                  ..._camposEndereco(),
                const SizedBox(height: AppMetrics.spacingMd),
                SizedBox(
                  height: AppMetrics.buttonHeight,
                  child: FilledButton.icon(
                    onPressed: carregando ? null : _buscar,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar'),
                  ),
                ),
                const SizedBox(height: AppMetrics.spacingSm),
                SizedBox(
                  height: AppMetrics.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: carregando ? null : _novaConsulta,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nova consulta'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _campoCep() {
    return TextField(
      key: const Key('campo-cep'),
      controller: _cep,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.search,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(EnderecoService.tamanhoCep),
      ],
      decoration: const InputDecoration(
        labelText: 'CEP',
        hintText: 'Só os 8 números, ex.: 01001000',
        prefixIcon: Icon(Icons.pin_drop_outlined),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (_) => _buscar(),
    );
  }

  List<Widget> _camposEndereco() {
    return [
      TextField(
        key: const Key('campo-uf'),
        controller: _uf,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
          LengthLimitingTextInputFormatter(2),
          TextInputFormatter.withFunction(
            (_, novo) => novo.copyWith(text: novo.text.toUpperCase()),
          ),
        ],
        decoration: const InputDecoration(
          labelText: 'UF',
          hintText: 'Ex.: SC',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: AppMetrics.spacingSm),
      TextField(
        key: const Key('campo-cidade'),
        controller: _cidade,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Cidade',
          hintText: 'Ex.: Florianópolis',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: AppMetrics.spacingSm),
      TextField(
        key: const Key('campo-logradouro'),
        controller: _logradouro,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          labelText: 'Logradouro',
          hintText: 'Rua, avenida… (pode ser parcial)',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _buscar(),
      ),
    ];
  }

  Widget _resultado() {
    if (_controller.carregando) {
      return const AppLoading(mensagem: 'Consultando o ViaCEP...');
    }

    final ultimo = _controller.ultimoEndereco;
    final ultimoWidget = ultimo == null
        ? null
        : UltimoEndereco(
            key: _chaveUltimo,
            endereco: ultimo,
            abrindoRota: _controller.abrindoRota,
            onTracarRota: _controller.tracarRota,
          );

    final conteudo = switch (_controller.estado) {
      EstadoBusca.naoEncontrado => BuscaVazia.naoEncontrado(
        mensagem: _controller.modo == ModoBusca.cep
            ? 'Esse CEP não existe na base dos Correios. Confira os números.'
            : 'Tente só parte do nome da rua ou confira a cidade e a UF.',
      ),
      EstadoBusca.listaEncontrada => ListaEnderecos(
        enderecos: _controller.resultados.toList(),
        cepSelecionado: ultimo?.cep,
        onSelecionar: _selecionar,
      ),
      _ => ultimoWidget == null ? const BuscaVazia.inicial() : null,
    };

    final recentes = _controller.estado == EstadoBusca.listaEncontrada
        ? const <EnderecoModel>[]
        : _controller.recentes.toList();
    final recentesWidget = recentes.isEmpty
        ? null
        : ListaEnderecos(
            key: const Key('consultas-recentes'),
            titulo: 'Consultas recentes',
            dica: 'Toque para consultar de novo e traçar a rota.',
            enderecos: recentes,
            mostrarData: true,
            onSelecionar: _selecionar,
            rodape: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _abrirHistorico,
                icon: const Icon(Icons.history),
                label: const Text('Ver histórico completo'),
              ),
            ),
          );

    final blocos = [
      conteudo,
      ultimoWidget,
      recentesWidget,
    ].whereType<Widget>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppMetrics.spacingLg,
      children: blocos,
    );
  }
}
