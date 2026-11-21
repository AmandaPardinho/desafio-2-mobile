import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fastlocation/src/modules/home/model/endereco_model.dart';
import 'package:fastlocation/src/modules/home/repositories/historico_repository.dart';

EnderecoModel _endereco(String cep, {DateTime? em, String rua = 'Rua A'}) {
  return EnderecoModel(
    cep: cep,
    logradouro: rua,
    complemento: '',
    bairro: 'Centro',
    localidade: 'Florianópolis',
    uf: 'SC',
    ddd: '48',
    consultadoEm: em,
  );
}

void main() {
  late Directory pasta;
  late Box<EnderecoModel> box;
  late HistoricoRepository repo;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EnderecoModelAdapter());
    }
  });

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('historico_test');
    Hive.init(pasta.path);
    box = await Hive.openBox<EnderecoModel>('historico_teste');
    repo = HistoricoRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await pasta.delete(recursive: true);
  });

  test('começa vazio e sem último', () {
    expect(repo.listar(), isEmpty);
    expect(repo.ultimo(), isNull);
  });

  test('lista do mais recente para o mais antigo', () async {
    await repo.salvar(_endereco('88000-001', em: DateTime(2026, 11, 1)));
    await repo.salvar(_endereco('88000-003', em: DateTime(2026, 11, 3)));
    await repo.salvar(_endereco('88000-002', em: DateTime(2026, 11, 2)));

    expect(repo.listar().map((e) => e.cep), [
      '88000-003',
      '88000-002',
      '88000-001',
    ]);
    expect(repo.ultimo()?.cep, '88000-003');
  });

  test(
    'consultar o mesmo CEP de novo não duplica e sobe para o topo',
    () async {
      await repo.salvar(_endereco('88000-001', em: DateTime(2026, 11, 1)));
      await repo.salvar(_endereco('88000-002', em: DateTime(2026, 11, 2)));
      await repo.salvar(
        _endereco('88000-001', em: DateTime(2026, 11, 3), rua: 'Rua Nova'),
      );

      final lista = repo.listar();
      expect(lista, hasLength(2));
      expect(lista.first.cep, '88000-001');
      expect(lista.first.logradouro, 'Rua Nova');
    },
  );

  test('persiste no disco: fechar e reabrir a box mantém os dados', () async {
    await repo.salvar(_endereco('88000-001', em: DateTime(2026, 11, 1)));
    await box.close();

    box = await Hive.openBox<EnderecoModel>('historico_teste');
    repo = HistoricoRepository(box);

    expect(repo.ultimo()?.cep, '88000-001');
    expect(repo.ultimo()?.consultadoEm, DateTime(2026, 11, 1));
  });

  test('limpar apaga tudo', () async {
    await repo.salvar(_endereco('88000-001', em: DateTime(2026, 11, 1)));
    await repo.limpar();

    expect(repo.listar(), isEmpty);
  });
}
