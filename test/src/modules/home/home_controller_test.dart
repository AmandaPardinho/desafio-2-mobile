import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/model/endereco_model.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';
import 'package:fastlocation/src/modules/home/service/rota_service.dart';

import '../../../fakes/fakes_home.dart';

void main() {
  group('achados do juiz', testesDoJuiz);

  late FakeViaCepRepository viaCep;
  late FakeHistoricoRepository historico;
  late FakeAbridorDeMapa abridor;
  late HomeController controller;
  var geocodificar = geocodificadorFixo([localTeste()]);

  setUp(() {
    viaCep = FakeViaCepRepository();
    historico = FakeHistoricoRepository();
    abridor = FakeAbridorDeMapa();
    geocodificar = geocodificadorFixo([localTeste()]);
    controller = HomeController(
      EnderecoService(viaCep, historico, relogio: () => DateTime(2026, 11, 20)),
      RotaService(
        geocodificar: (endereco) => geocodificar(endereco),
        abridor: abridor,
      ),
    );
  });

  test('carregarUltimo lê o último endereço salvo', () async {
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 1)));

    controller.carregarUltimo();

    expect(controller.ultimoEndereco?.cep, '88020-300');
  });

  test('passa por carregando e termina em encontrado', () async {
    viaCep.respostaCep = enderecoTeste();
    final estados = <EstadoBusca>[];
    final dispose = reaction((_) => controller.estado, estados.add);

    await controller.consultarCep('88020300');
    dispose();

    expect(estados, [EstadoBusca.carregando, EstadoBusca.encontrado]);
    expect(controller.ultimoEndereco?.cep, '88020-300');
    expect(controller.erro, isNull);
  });

  test(
    'CEP inexistente termina em naoEncontrado sem mexer no último',
    () async {
      await historico.salvar(
        enderecoTeste(cep: '01001-000', consultadoEm: DateTime(2026, 11, 1)),
      );
      controller.carregarUltimo();
      viaCep.respostaCep = null;

      await controller.consultarCep('99999999');

      expect(controller.estado, EstadoBusca.naoEncontrado);
      expect(controller.ultimoEndereco?.cep, '01001-000');
    },
  );

  test('erro de validação vira mensagem em erro e volta ao inicial', () async {
    await controller.consultarCep('123');

    expect(controller.estado, EstadoBusca.inicial);
    expect(controller.erro, contains('8 dígitos'));
  });

  test('erro de rede vira mensagem de conexão', () async {
    viaCep.erro = dioErro(DioErrorType.other);

    await controller.consultarCep('88020300');

    expect(controller.erro, contains('Sem conexão'));
  });

  test('busca por endereço preenche resultados sem trocar o último', () async {
    viaCep.respostaEndereco = [
      enderecoTeste(),
      enderecoTeste(cep: '88020-301'),
    ];

    await controller.buscarPorEndereco(
      uf: 'SC',
      cidade: 'Florianópolis',
      logradouro: 'Mauro Ramos',
    );

    expect(controller.estado, EstadoBusca.listaEncontrada);
    expect(controller.resultados, hasLength(2));
    expect(controller.ultimoEndereco, isNull);
  });

  test('busca por endereço sem resultado termina em naoEncontrado', () async {
    await controller.buscarPorEndereco(
      uf: 'SC',
      cidade: 'Florianópolis',
      logradouro: 'Rua Que Não Existe',
    );

    expect(controller.estado, EstadoBusca.naoEncontrado);
  });

  test('selecionar um resultado vira o último e entra no histórico', () async {
    await controller.selecionarEndereco(enderecoTeste(cep: '88020-301'));

    expect(controller.ultimoEndereco?.cep, '88020-301');
    expect(historico.ultimo()?.cep, '88020-301');
  });

  test(
    'novaConsulta limpa estado, resultados e erro, mas mantém o último',
    () async {
      viaCep.respostaEndereco = [enderecoTeste()];
      await controller.selecionarEndereco(enderecoTeste());
      await controller.buscarPorEndereco(
        uf: 'SC',
        cidade: 'Florianópolis',
        logradouro: 'Mauro Ramos',
      );

      controller.novaConsulta();

      expect(controller.estado, EstadoBusca.inicial);
      expect(controller.resultados, isEmpty);
      expect(controller.ultimoEndereco, isNotNull);
    },
  );

  test('alterarModo troca o modo e começa uma nova consulta', () async {
    viaCep.respostaCep = null;
    await controller.consultarCep('99999999');

    controller.alterarModo(ModoBusca.endereco);

    expect(controller.modo, ModoBusca.endereco);
    expect(controller.estado, EstadoBusca.inicial);
  });

  test('tracarRota abre o mapa com o último endereço', () async {
    await controller.selecionarEndereco(enderecoTeste());

    await controller.tracarRota();

    expect(abridor.chamadas, hasLength(1));
    expect(controller.abrindoRota, isFalse);
  });

  test('tracarRota sem último endereço não faz nada', () async {
    expect(controller.podeTracarRota, isFalse);

    await controller.tracarRota();

    expect(abridor.chamadas, isEmpty);
  });

  test('falha na rota vira mensagem em erro', () async {
    geocodificar = geocodificadorFixo([]);
    await controller.selecionarEndereco(enderecoTeste());

    await controller.tracarRota();

    expect(controller.erro, contains('localizar'));
    expect(controller.abrindoRota, isFalse);
  });
}

class _ViaCepLento extends FakeViaCepRepository {
  final pendente = Completer<List<EnderecoModel>>();

  @override
  Future<List<EnderecoModel>> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) => pendente.future;
}

class _HistoricoQuebrado extends FakeHistoricoRepository {
  @override
  Future<void> salvar(EnderecoModel endereco) async =>
      throw HiveError('box fechada');
}

class _AbridorQuebrado extends FakeAbridorDeMapa {
  @override
  Future<bool> abrirRota({
    required double latitude,
    required double longitude,
    required String titulo,
  }) async => throw PlatformException(code: 'falhou');
}

void testesDoJuiz() {
  test('não troca de modo nem limpa durante uma busca em andamento', () async {
    final lento = _ViaCepLento();
    final c = HomeController(
      EnderecoService(lento, FakeHistoricoRepository()),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: FakeAbridorDeMapa(),
      ),
    );

    c.alterarModo(ModoBusca.endereco);
    final busca = c.buscarPorEndereco(
      uf: 'SC',
      cidade: 'Florianópolis',
      logradouro: 'Mauro Ramos',
    );
    c.alterarModo(ModoBusca.cep);
    c.novaConsulta();
    lento.pendente.complete([enderecoTeste()]);
    await busca;

    expect(c.modo, ModoBusca.endereco);
    expect(c.estado, EstadoBusca.listaEncontrada);
  });

  test('falha ao salvar no histórico vira mensagem em erro', () async {
    final viaCep = FakeViaCepRepository()..respostaCep = enderecoTeste();
    final c = HomeController(
      EnderecoService(viaCep, _HistoricoQuebrado()),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: FakeAbridorDeMapa(),
      ),
    );

    await c.consultarCep('88020300');
    expect(c.erro, contains('histórico'));

    c.limparErro();
    await c.selecionarEndereco(enderecoTeste());
    expect(c.erro, contains('histórico'));
  });

  test('falha do app de mapa vira mensagem em erro', () async {
    final historico = FakeHistoricoRepository();
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 1)));
    final c = HomeController(
      EnderecoService(FakeViaCepRepository(), historico),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: _AbridorQuebrado(),
      ),
    )..carregarUltimo();

    await c.tracarRota();

    expect(c.erro, contains('mapa'));
    expect(c.abrindoRota, isFalse);
  });
}
