import 'package:mobx/mobx.dart';

import '../../home/model/endereco_model.dart';
import '../../home/service/consulta_exception.dart';
import '../../home/service/endereco_service.dart';

part 'history_controller.g.dart';

class HistoryController = HistoryControllerBase with _$HistoryController;

abstract class HistoryControllerBase with Store {
  HistoryControllerBase(this._service);

  final EnderecoService _service;

  final ObservableList<EnderecoModel> enderecos = ObservableList();

  @observable
  bool carregado = false;

  @observable
  String? erro;

  @computed
  bool get vazio => carregado && enderecos.isEmpty;

  @action
  void carregar() {
    enderecos
      ..clear()
      ..addAll(_service.historico());
    carregado = true;
  }

  @action
  Future<void> limpar() async {
    try {
      await _service.limparHistorico();
      enderecos.clear();
    } on ConsultaException catch (e) {
      erro = e.mensagem;
    }
  }

  @action
  Future<bool> consultarDeNovo(EnderecoModel endereco) async {
    try {
      await _service.registrarConsulta(endereco);
      return true;
    } on ConsultaException catch (e) {
      erro = e.mensagem;
      return false;
    }
  }

  @action
  void limparErro() {
    erro = null;
  }
}
