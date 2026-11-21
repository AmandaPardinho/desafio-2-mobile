import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
// ignore: implementation_imports
import 'package:hive/src/hive_impl.dart';

import 'package:fastlocation/src/modules/home/model/endereco_model.dart';

class _AdapterVersaoAntiga extends TypeAdapter<EnderecoModel> {
  @override
  final int typeId = 0;

  @override
  EnderecoModel read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, EnderecoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.cep)
      ..writeByte(1)
      ..write(obj.logradouro)
      ..writeByte(2)
      ..write(obj.complemento)
      ..writeByte(3)
      ..write(obj.bairro)
      ..writeByte(4)
      ..write(obj.localidade)
      ..writeByte(5)
      ..write(obj.uf)
      ..writeByte(6)
      ..write(obj.ddd)
      ..writeByte(7)
      ..write(obj.consultadoEm);
  }
}

void main() {
  late Directory pasta;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('model_hive_test');
  });

  tearDown(() => pasta.delete(recursive: true));

  HiveInterface instancia(TypeAdapter<EnderecoModel> adapter) {
    return HiveImpl()
      ..init(pasta.path)
      ..registerAdapter(adapter);
  }

  test('ida e volta no Hive preserva todos os campos', () async {
    final hive = instancia(EnderecoModelAdapter());
    final box = await hive.openBox<EnderecoModel>('ida_volta');

    await box.put(
      '01001000',
      EnderecoModel(
        cep: '01001-000',
        logradouro: 'Praça da Sé',
        complemento: 'lado ímpar',
        bairro: 'Sé',
        localidade: 'São Paulo',
        uf: 'SP',
        ddd: '11',
        consultadoEm: DateTime(2026, 11, 20),
        estado: 'São Paulo',
        regiao: 'Sudeste',
        ibge: '3550308',
        gia: '1004',
        siafi: '7107',
      ),
    );
    await box.close();

    final reaberta = await hive.openBox<EnderecoModel>('ida_volta');
    final lido = reaberta.get('01001000')!;
    expect(lido.logradouro, 'Praça da Sé');
    expect(lido.estado, 'São Paulo');
    expect(lido.regiao, 'Sudeste');
    expect(lido.ibge, '3550308');
    expect(lido.consultadoEm, DateTime(2026, 11, 20));
    await hive.close();
  });

  test('registro salvo na versão antiga (8 campos) ainda abre', () async {
    final versaoAntiga = instancia(_AdapterVersaoAntiga());
    final antiga = await versaoAntiga.openBox<EnderecoModel>('legado');
    await antiga.put(
      '88020300',
      EnderecoModel(
        cep: '88020-300',
        logradouro: 'Avenida Mauro Ramos',
        complemento: '',
        bairro: 'Centro',
        localidade: 'Florianópolis',
        uf: 'SC',
        ddd: '48',
        consultadoEm: DateTime(2026, 11, 20),
      ),
    );
    await versaoAntiga.close();

    final versaoNova = instancia(EnderecoModelAdapter());
    final nova = await versaoNova.openBox<EnderecoModel>('legado');
    final lido = nova.get('88020300')!;

    expect(lido.logradouro, 'Avenida Mauro Ramos');
    expect(lido.consultadoEm, DateTime(2026, 11, 20));
    expect(lido.estado, '');
    expect(lido.siafi, '');
    await versaoNova.close();
  });
}
