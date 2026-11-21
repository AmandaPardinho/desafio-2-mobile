import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/app_widget.dart';
import 'package:fastlocation/src/http/app_http_client.dart';
import 'package:fastlocation/src/modules/history/controller/history_controller.dart';
import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/model/endereco_model.dart';
import 'package:fastlocation/src/modules/home/repositories/historico_repository.dart';
import 'package:fastlocation/src/modules/home/repositories/via_cep_repository.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';
import 'package:fastlocation/src/modules/home/service/rota_service.dart';
import 'package:fastlocation/src/shared/storage/app_storage.dart';

import 'fakes/fake_http_adapter.dart';
import 'fakes/fakes_home.dart';
import 'fixtures/fixtures.dart';

void main() {
  late Box<EnderecoModel> box;
  late FakeHttpAdapter viaCep;
  late FakeAbridorDeMapa mapa;
  final cepSe = fixtureTexto('cep_01001000.json');

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EnderecoModelAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<EnderecoModel>(
      StorageBoxes.historico,
      bytes: Uint8List(0),
    );
    viaCep = FakeHttpAdapter((_) => respostaJson(cepSe));
    mapa = FakeAbridorDeMapa();
  });

  tearDown(() async {
    await Hive.close();
  });

  EnderecoService servico() {
    final dio = AppHttpClient.viaCep()..httpClientAdapter = viaCep;
    return EnderecoService(ViaCepRepository(dio), HistoricoRepository(box));
  }

  AppWidget app() => AppWidget(
    criarHomeController: () => HomeController(
      servico(),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: mapa,
      ),
    ),
    criarHistoryController: () => HistoryController(servico()),
  );

  Future<void> passarSplash(WidgetTester tester) async {
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'splash → busca por CEP → Hive → rota → histórico → app reaberto',
    (tester) async {
      await tester.pumpWidget(app());
      await passarSplash(tester);
      expect(find.byKey(const Key('campo-cep')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('campo-cep')), '01001000');
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();

      expect(
        viaCep.requisicoes.single.toString(),
        'https://viacep.com.br/ws/01001000/json/',
      );
      expect(find.text('Praça da Sé'), findsWidgets);
      expect(box.get('01001000')?.logradouro, 'Praça da Sé');

      await tester.ensureVisible(find.text('Traçar rota'));
      await tester.tap(find.text('Traçar rota'));
      await tester.pumpAndSettle();
      expect(mapa.chamadas.single.titulo, contains('Praça da Sé'));

      await tester.tap(find.byTooltip('Histórico de consultas'));
      await tester.pumpAndSettle();

      expect(find.text('1 endereço consultado'), findsOneWidget);
      expect(find.text('Praça da Sé'), findsOneWidget);

      await tester.tap(find.text('Praça da Sé'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('campo-cep')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());

      await tester.pumpWidget(app());
      await passarSplash(tester);

      expect(find.text('Último endereço consultado'), findsOneWidget);
      expect(find.text('Praça da Sé'), findsWidgets);
      expect(viaCep.requisicoes, hasLength(1));
    },
  );
}
