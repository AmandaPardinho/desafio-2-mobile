import 'package:dio/dio.dart';

import '../model/endereco_model.dart';

class ViaCepRepository {
  ViaCepRepository(this._dio);

  final Dio _dio;

  Future<EnderecoModel?> buscarPorCep(String cep) async {
    final resposta = await _dio.get<dynamic>('$cep/json/');
    final dados = resposta.data;

    if (dados is! Map<String, dynamic> || EnderecoModel.respostaDeErro(dados)) {
      return null;
    }
    return EnderecoModel.fromJson(dados);
  }

  Future<List<EnderecoModel>> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) async {
    final caminho = [
      uf,
      Uri.encodeComponent(cidade),
      Uri.encodeComponent(logradouro),
      'json',
    ].join('/');

    final resposta = await _dio.get<dynamic>('$caminho/');
    final dados = resposta.data;

    if (dados is! List) {
      return [];
    }
    return dados
        .whereType<Map<String, dynamic>>()
        .map(EnderecoModel.fromJson)
        .toList();
  }
}
