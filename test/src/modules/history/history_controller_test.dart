import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fastlocation/src/modules/history/controller/history_controller.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';

import '../../../fakes/fakes_home.dart';

class _HistoricoQuebrado extends FakeHistoricoRepository {
  @override
  Future<void> limpar() async => throw HiveError('box fechada');
}

void main() {
  late FakeHistoricoRepository historico;
  late HistoryController controller;
  final agora = DateTime(2026, 11, 20, 22);

  setUp(() {
    historico = FakeHistoricoRepository();
    controller = HistoryController(
      EnderecoService(FakeViaCepRepository(), historico, relogio: () => agora),
    );
  });

  test('antes de carregar não é considerado vazio', () {
    expect(controller.carregado, isFalse);
    expect(controller.vazio, isFalse);
  });

  test(
    'carregar traz o histórico do mais recente para o mais antigo',
    () async {
      await historico.salvar(
        enderecoTeste(cep: '01001-000', consultadoEm: DateTime(2026, 11, 1)),
      );
      await historico.salvar(
        enderecoTeste(consultadoEm: DateTime(2026, 11, 2)),
      );

      controller.carregar();

      expect(controller.enderecos.map((e) => e.cep), [
        '88020-300',
        '01001-000',
      ]);
      expect(controller.vazio, isFalse);
    },
  );

  test('histórico vazio fica marcado como vazio depois de carregar', () {
    controller.carregar();

    expect(controller.vazio, isTrue);
  });

  test('limpar esvazia a lista e o armazenamento', () async {
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 2)));
    controller.carregar();

    await controller.limpar();

    expect(controller.enderecos, isEmpty);
    expect(historico.listar(), isEmpty);
    expect(controller.vazio, isTrue);
  });

  test('falha ao limpar vira mensagem e mantém a lista', () async {
    final quebrado = _HistoricoQuebrado();
    await quebrado.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 2)));
    final c = HistoryController(
      EnderecoService(FakeViaCepRepository(), quebrado),
    )..carregar();

    await c.limpar();

    expect(c.erro, contains('limpar'));
    expect(c.enderecos, hasLength(1));
  });

  test('consultar de novo sobe o endereço para o topo com data nova', () async {
    await historico.salvar(
      enderecoTeste(cep: '01001-000', consultadoEm: DateTime(2026, 11, 1)),
    );
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 2)));
    controller.carregar();

    final ok = await controller.consultarDeNovo(controller.enderecos.last);

    expect(ok, isTrue);
    expect(historico.ultimo()?.cep, '01001-000');
    expect(historico.ultimo()?.consultadoEm, agora);
  });
}
