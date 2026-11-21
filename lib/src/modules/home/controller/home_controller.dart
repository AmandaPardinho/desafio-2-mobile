import 'package:mobx/mobx.dart';

import '../model/endereco_model.dart';
import '../service/consulta_exception.dart';
import '../service/endereco_service.dart';
import '../service/rota_service.dart';

part 'home_controller.g.dart';

enum ModoBusca { cep, endereco }

enum EstadoBusca {
  inicial,
  carregando,
  encontrado,
  listaEncontrada,
  naoEncontrado,
}

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  HomeControllerBase(this._service, this._rota);

  final EnderecoService _service;
  final RotaService _rota;

  @observable
  ModoBusca modo = ModoBusca.cep;

  @observable
  EstadoBusca estado = EstadoBusca.inicial;

  @observable
  EnderecoModel? ultimoEndereco;

  final ObservableList<EnderecoModel> resultados = ObservableList();

  final ObservableList<EnderecoModel> recentes = ObservableList();

  static const int limiteRecentes = 5;

  @observable
  String? erro;

  @observable
  bool abrindoRota = false;

  @computed
  bool get carregando => estado == EstadoBusca.carregando;

  @computed
  bool get temBuscaAtiva => estado != EstadoBusca.inicial;

  @computed
  bool get podeTracarRota => ultimoEndereco != null && !abrindoRota;

  @action
  void carregarUltimo() {
    final historico = _service.historico();
    ultimoEndereco = historico.isEmpty ? null : historico.first;
    recentes
      ..clear()
      ..addAll(historico.skip(1).take(limiteRecentes));
  }

  @action
  void alterarModo(ModoBusca novoModo) {
    if (carregando) return;
    modo = novoModo;
    novaConsulta();
  }

  @action
  void novaConsulta() {
    if (carregando) return;
    estado = EstadoBusca.inicial;
    resultados.clear();
    erro = null;
  }

  @action
  void limparErro() {
    erro = null;
  }

  @action
  Future<void> consultarCep(String cep) async {
    if (carregando) return;
    estado = EstadoBusca.carregando;
    resultados.clear();

    try {
      final endereco = await _service.consultarCep(cep);
      if (endereco == null) {
        estado = EstadoBusca.naoEncontrado;
      } else {
        carregarUltimo();
        estado = EstadoBusca.encontrado;
      }
    } on ConsultaException catch (e) {
      estado = EstadoBusca.inicial;
      erro = e.mensagem;
    }
  }

  @action
  Future<void> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) async {
    if (carregando) return;
    estado = EstadoBusca.carregando;
    resultados.clear();

    try {
      final encontrados = await _service.buscarPorEndereco(
        uf: uf,
        cidade: cidade,
        logradouro: logradouro,
      );
      if (encontrados.isEmpty) {
        estado = EstadoBusca.naoEncontrado;
      } else {
        resultados.addAll(encontrados);
        estado = EstadoBusca.listaEncontrada;
      }
    } on ConsultaException catch (e) {
      estado = EstadoBusca.inicial;
      erro = e.mensagem;
    }
  }

  @action
  Future<void> selecionarEndereco(EnderecoModel endereco) async {
    try {
      await _service.registrarConsulta(endereco);
      carregarUltimo();
    } on ConsultaException catch (e) {
      erro = e.mensagem;
    }
  }

  @action
  Future<void> tracarRota() async {
    final destino = ultimoEndereco;
    if (destino == null || abrindoRota) return;

    abrindoRota = true;
    try {
      await _rota.tracarRota(destino);
    } on RotaException catch (e) {
      erro = e.mensagem;
    } finally {
      abrindoRota = false;
    }
  }
}
