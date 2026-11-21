import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/modules/home/service/consulta_exception.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';

import '../../../fakes/fakes_home.dart';

void main() {
  final agora = DateTime(2026, 11, 20, 21, 30);
  late FakeViaCepRepository viaCep;
  late FakeHistoricoRepository historico;
  late EnderecoService service;

  setUp(() {
    viaCep = FakeViaCepRepository();
    historico = FakeHistoricoRepository();
    service = EnderecoService(viaCep, historico, relogio: () => agora);
  });

  Matcher consultaComMensagem(String trecho) => throwsA(
    isA<ConsultaException>().having(
      (e) => e.mensagem,
      'mensagem',
      contains(trecho),
    ),
  );

  group('consultarCep', () {
    test('aceita CEP com hífen e manda só os dígitos para a API', () async {
      viaCep.respostaCep = enderecoTeste();

      await service.consultarCep('88020-300');

      expect(viaCep.cepsConsultados, ['88020300']);
    });

    test('CEP encontrado vai para o histórico com data', () async {
      viaCep.respostaCep = enderecoTeste();

      final endereco = await service.consultarCep('88020300');

      expect(endereco?.consultadoEm, agora);
      expect(historico.ultimo()?.cep, '88020-300');
    });

    test('CEP inexistente devolve null e NÃO entra no histórico', () async {
      viaCep.respostaCep = null;

      expect(await service.consultarCep('99999999'), isNull);
      expect(historico.listar(), isEmpty);
    });

    test('CEP com tamanho errado não chama a API', () async {
      await expectLater(
        service.consultarCep('8802'),
        consultaComMensagem('8 dígitos'),
      );
      expect(viaCep.cepsConsultados, isEmpty);
    });
  });

  group('buscarPorEndereco', () {
    test(
      'limpa espaços, põe UF em maiúscula e não salva no histórico',
      () async {
        viaCep.respostaEndereco = [
          enderecoTeste(),
          enderecoTeste(cep: '88020-301'),
        ];

        final lista = await service.buscarPorEndereco(
          uf: ' sc ',
          cidade: ' Florianópolis ',
          logradouro: ' Mauro Ramos ',
        );

        expect(lista, hasLength(2));
        expect(viaCep.enderecosConsultados.single, {
          'uf': 'SC',
          'cidade': 'Florianópolis',
          'logradouro': 'Mauro Ramos',
        });
        expect(historico.listar(), isEmpty);
      },
    );

    test('UF inválida não chama a API', () async {
      await expectLater(
        service.buscarPorEndereco(
          uf: 'S',
          cidade: 'Floripa',
          logradouro: 'Rua A',
        ),
        consultaComMensagem('UF'),
      );
      expect(viaCep.enderecosConsultados, isEmpty);
    });

    test(
      'cidade ou logradouro com menos de 3 letras não chama a API',
      () async {
        await expectLater(
          service.buscarPorEndereco(
            uf: 'SC',
            cidade: 'Fl',
            logradouro: 'Rua A',
          ),
          consultaComMensagem('3 letras'),
        );
        await expectLater(
          service.buscarPorEndereco(
            uf: 'SC',
            cidade: 'Floripa',
            logradouro: 'Ru',
          ),
          consultaComMensagem('3 letras'),
        );
        expect(viaCep.enderecosConsultados, isEmpty);
      },
    );
  });

  group('logradouro com número da casa', () {
    final casos = {
      'avenida francisco glicerio, 935': 'avenida francisco glicerio',
      'Avenida Francisco Glicério 935': 'Avenida Francisco Glicério',
      'Rua das Flores, nº 12, apto 3': 'Rua das Flores',
      'Rua das Flores n° 12': 'Rua das Flores',
      'Rua das Flores número 12': 'Rua das Flores',
      'Rua 25 de Março': 'Rua 25 de Março',
      'Rua 7 de Setembro, 100': 'Rua 7 de Setembro',
      'Rua XV de Novembro 1500': 'Rua XV de Novembro',
    };

    casos.forEach((digitado, enviado) {
      test('"$digitado" vira "$enviado"', () async {
        await service.buscarPorEndereco(
          uf: 'SP',
          cidade: 'Campinas',
          logradouro: digitado,
        );

        expect(viaCep.enderecosConsultados.single['logradouro'], enviado);
      });
    });

    test('só número não chega à API', () async {
      await expectLater(
        service.buscarPorEndereco(
          uf: 'SP',
          cidade: 'Campinas',
          logradouro: '935',
        ),
        consultaComMensagem('3 letras'),
      );
      expect(viaCep.enderecosConsultados, isEmpty);
    });
  });

  group('erros da API viram mensagens certas', () {
    final casos = {
      dioErro(DioErrorType.other): 'Sem conexão',
      dioErro(DioErrorType.connectTimeout): 'demorou',
      dioErro(DioErrorType.receiveTimeout): 'demorou',
      dioErro(DioErrorType.response, status: 400): 'Consulta inválida',
      dioErro(DioErrorType.response, status: 503): 'indisponível',
    };

    casos.forEach((erro, trecho) {
      test(
        '${erro.type.name} ${erro.response?.statusCode ?? ''} → "$trecho"',
        () {
          viaCep.erro = erro;
          expect(service.consultarCep('88020300'), consultaComMensagem(trecho));
        },
      );
    });
  });

  test('400 na busca por endereço traz a dica de vírgula e número', () async {
    viaCep.erro = dioErro(DioErrorType.response, status: 400);

    await expectLater(
      service.buscarPorEndereco(
        uf: 'SP',
        cidade: 'Campinas',
        logradouro: 'Avenida Francisco Glicério',
      ),
      consultaComMensagem(
        'Consulta inválida. Confira os dados digitados. '
        'Tente novamente sem colocar vírgula e número.',
      ),
    );
  });

  test('400 na busca por CEP não traz a dica de endereço', () async {
    viaCep.erro = dioErro(DioErrorType.response, status: 400);

    await expectLater(
      service.consultarCep('88020300'),
      throwsA(
        isA<ConsultaException>().having(
          (e) => e.mensagem,
          'mensagem',
          isNot(contains('vírgula')),
        ),
      ),
    );
  });

  test('registrarConsulta carimba a data e salva', () async {
    final salvo = await service.registrarConsulta(enderecoTeste());

    expect(salvo.consultadoEm, agora);
    expect(service.ultimoConsultado()?.cep, '88020-300');
  });

  test('limparHistorico esvazia', () async {
    await service.registrarConsulta(enderecoTeste());
    await service.limparHistorico();

    expect(service.historico(), isEmpty);
  });
}
