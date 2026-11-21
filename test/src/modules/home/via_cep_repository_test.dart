import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/http/app_http_client.dart';
import 'package:fastlocation/src/modules/home/repositories/via_cep_repository.dart';

import '../../../fakes/fake_http_adapter.dart';
import '../../../fixtures/fixtures.dart';

({ViaCepRepository repo, FakeHttpAdapter adapter}) _montar(
  ResponseBody Function(RequestOptions) responder,
) {
  final dio = AppHttpClient.viaCep();
  final adapter = FakeHttpAdapter(responder);
  dio.httpClientAdapter = adapter;
  return (repo: ViaCepRepository(dio), adapter: adapter);
}

void main() {
  group('buscarPorCep', () {
    test('chama a URL certa e devolve o endereço', () async {
      final m = _montar((_) => respostaJson(fixtureTexto('cep_01001000.json')));

      final endereco = await m.repo.buscarPorCep('01001000');

      expect(
        m.adapter.requisicoes.single.toString(),
        'https://viacep.com.br/ws/01001000/json/',
      );
      expect(endereco?.logradouro, 'Praça da Sé');
    });

    test('CEP inexistente ("erro": "true") devolve null', () async {
      final m = _montar(
        (_) => respostaJson(fixtureTexto('cep_inexistente.json')),
      );

      expect(await m.repo.buscarPorCep('99999999'), isNull);
    });

    test('status 400 propaga DioError', () async {
      final m = _montar((_) => respostaJson('', status: 400));

      expect(() => m.repo.buscarPorCep('123'), throwsA(isA<DioError>()));
    });
  });

  group('buscarPorEndereco', () {
    test('codifica espaço e acento e devolve a lista', () async {
      final m = _montar(
        (_) => respostaJson(
          fixtureTexto('endereco_sc_florianopolis_mauro_ramos.json'),
        ),
      );

      final enderecos = await m.repo.buscarPorEndereco(
        uf: 'SC',
        cidade: 'Florianópolis',
        logradouro: 'Mauro Ramos',
      );

      expect(
        m.adapter.requisicoes.single.toString(),
        'https://viacep.com.br/ws/SC/Florian%C3%B3polis/Mauro%20Ramos/json/',
      );
      expect(enderecos, hasLength(7));
      expect(enderecos.first.cep, '88020-300');
    });

    test('lista vazia da API devolve lista vazia', () async {
      final m = _montar((_) => respostaJson('[]'));

      final enderecos = await m.repo.buscarPorEndereco(
        uf: 'SC',
        cidade: 'Florianópolis',
        logradouro: 'Rua Que Não Existe',
      );

      expect(enderecos, isEmpty);
    });
  });
}
