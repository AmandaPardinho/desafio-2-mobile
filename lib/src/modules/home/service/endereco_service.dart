import 'package:dio/dio.dart';

import '../model/endereco_model.dart';
import '../repositories/historico_repository.dart';
import '../repositories/via_cep_repository.dart';
import 'consulta_exception.dart';

class EnderecoService {
  EnderecoService(this._viaCep, this._historico, {DateTime Function()? relogio})
    : _relogio = relogio ?? DateTime.now;

  final ViaCepRepository _viaCep;
  final HistoricoRepository _historico;
  final DateTime Function() _relogio;

  static const int tamanhoCep = 8;
  static const int minimoLetras = 3;

  static const String dicaEndereco =
      'Tente novamente sem colocar vírgula e número.';

  static final RegExp _naoDigito = RegExp(r'\D');
  static final RegExp _uf = RegExp(r'^[A-Za-z]{2}$');
  static final RegExp _numeroNoFim = RegExp(
    r'(?:^|\s+)(?:n[º°o.]?|n[uú]mero)?\s*\d+[a-z]?$',
    caseSensitive: false,
  );

  static String limparLogradouro(String logradouro) {
    final semComplemento = logradouro.split(',').first.trim();
    return semComplemento.replaceFirst(_numeroNoFim, '').trim();
  }

  Future<EnderecoModel?> consultarCep(String cep) async {
    final digitos = cep.replaceAll(_naoDigito, '');
    if (digitos.length != tamanhoCep) {
      throw const ConsultaException('Informe um CEP com 8 dígitos.');
    }

    final endereco = await _executar(() => _viaCep.buscarPorCep(digitos));
    if (endereco == null) {
      return null;
    }
    return registrarConsulta(endereco);
  }

  Future<List<EnderecoModel>> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) async {
    final ufLimpa = uf.trim();
    final cidadeLimpa = cidade.trim();
    final logradouroLimpo = limparLogradouro(logradouro);

    if (!_uf.hasMatch(ufLimpa)) {
      throw const ConsultaException('Informe a UF com 2 letras, como SC.');
    }
    if (cidadeLimpa.length < minimoLetras ||
        logradouroLimpo.length < minimoLetras) {
      throw const ConsultaException(
        'Cidade e logradouro precisam ter pelo menos 3 letras.',
      );
    }

    return _executar(
      () => _viaCep.buscarPorEndereco(
        uf: ufLimpa.toUpperCase(),
        cidade: cidadeLimpa,
        logradouro: logradouroLimpo,
      ),
      dicaConsultaInvalida: dicaEndereco,
    );
  }

  Future<EnderecoModel> registrarConsulta(EnderecoModel endereco) async {
    final consultado = endereco.consultadoAgora(_relogio());
    try {
      await _historico.salvar(consultado);
    } catch (_) {
      throw const ConsultaException(
        'Não foi possível salvar o endereço no histórico.',
      );
    }
    return consultado;
  }

  List<EnderecoModel> historico() => _historico.listar();

  EnderecoModel? ultimoConsultado() => _historico.ultimo();

  Future<void> limparHistorico() async {
    try {
      await _historico.limpar();
    } catch (_) {
      throw const ConsultaException('Não foi possível limpar o histórico.');
    }
  }

  Future<T> _executar<T>(
    Future<T> Function() chamada, {
    String? dicaConsultaInvalida,
  }) async {
    try {
      return await chamada();
    } on DioError catch (erro) {
      throw ConsultaException(_mensagemDe(erro, dicaConsultaInvalida));
    }
  }

  String _mensagemDe(DioError erro, String? dicaConsultaInvalida) {
    switch (erro.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return 'O ViaCEP demorou para responder. Tente de novo.';
      case DioErrorType.response:
        if (erro.response?.statusCode == 400) {
          const base = 'Consulta inválida. Confira os dados digitados.';
          return dicaConsultaInvalida == null
              ? base
              : '$base $dicaConsultaInvalida';
        }
        return 'O ViaCEP está indisponível no momento. Tente mais tarde.';
      case DioErrorType.cancel:
        return 'A consulta foi cancelada.';
      case DioErrorType.other:
        return 'Sem conexão com a internet. Verifique a rede e tente de novo.';
    }
  }
}
