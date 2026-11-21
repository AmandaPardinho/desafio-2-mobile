import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/modules/home/service/consulta_exception.dart';
import 'package:fastlocation/src/modules/home/service/rota_service.dart';

import '../../../fakes/fakes_home.dart';

void main() {
  late FakeAbridorDeMapa abridor;

  setUp(() => abridor = FakeAbridorDeMapa());

  test('geocodifica o endereço completo e abre a rota até ele', () async {
    String? enderecoPedido;
    final rota = RotaService(
      geocodificar: (endereco) async {
        enderecoPedido = endereco;
        return [localTeste()];
      },
      abridor: abridor,
    );

    await rota.tracarRota(enderecoTeste());

    expect(enderecoPedido, contains('Avenida Mauro Ramos'));
    expect(enderecoPedido, contains('88020-300'));
    expect(abridor.chamadas.single.latitude, -27.59);
    expect(abridor.chamadas.single.longitude, -48.54);
    expect(abridor.chamadas.single.titulo, 'Avenida Mauro Ramos');
  });

  test('CEP geral sem logradouro usa cidade - UF como título', () async {
    final rota = RotaService(
      geocodificar: geocodificadorFixo([localTeste()]),
      abridor: abridor,
    );

    await rota.tracarRota(enderecoTeste(logradouro: ''));

    expect(abridor.chamadas.single.titulo, 'Florianópolis - SC');
  });

  test('endereço que o geocoding não acha vira RotaException', () async {
    final rota = RotaService(
      geocodificar: geocodificadorFixo([]),
      abridor: abridor,
    );

    expect(rota.tracarRota(enderecoTeste()), throwsA(isA<RotaException>()));
  });

  test('geocoding que lança erro vira RotaException', () async {
    final rota = RotaService(
      geocodificar: (_) async => throw Exception('sem serviço'),
      abridor: abridor,
    );

    await expectLater(
      rota.tracarRota(enderecoTeste()),
      throwsA(isA<RotaException>()),
    );
    expect(abridor.chamadas, isEmpty);
  });

  test('sem app de mapa instalado vira RotaException', () async {
    abridor.temAppDeMapa = false;
    final rota = RotaService(
      geocodificar: geocodificadorFixo([localTeste()]),
      abridor: abridor,
    );

    expect(
      rota.tracarRota(enderecoTeste()),
      throwsA(
        isA<RotaException>().having(
          (e) => e.mensagem,
          'mensagem',
          contains('app de mapas'),
        ),
      ),
    );
  });
}
