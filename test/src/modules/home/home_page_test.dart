import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/modules/home/components/busca_vazia.dart';
import 'package:fastlocation/src/modules/home/components/lista_enderecos.dart';
import 'package:fastlocation/src/modules/home/components/ultimo_endereco.dart';
import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/model/endereco_model.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';
import 'package:fastlocation/src/modules/home/service/rota_service.dart';
import 'package:fastlocation/src/routes/app_routes.dart';

import '../../../fakes/fakes_home.dart';

void main() {
  late FakeViaCepRepository viaCep;
  late FakeHistoricoRepository historico;
  late FakeAbridorDeMapa abridor;
  late HomeController controller;

  setUp(() {
    viaCep = FakeViaCepRepository();
    historico = FakeHistoricoRepository();
    abridor = FakeAbridorDeMapa();
    controller = HomeController(
      EnderecoService(viaCep, historico, relogio: () => DateTime(2026, 11, 20)),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: abridor,
      ),
    );
  });

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(controller: controller),
        routes: {
          AppRoutes.history: (_) =>
              const Scaffold(body: Text('tela histórico')),
        },
      ),
    );
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.ensureVisible(find.text(texto));
    await tester.tap(find.text(texto));
    await tester.pumpAndSettle();
  }

  testWidgets('sem histórico mostra a busca vazia inicial', (tester) async {
    await abrir(tester);

    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);
    expect(find.byType(UltimoEndereco), findsNothing);
  });

  testWidgets('com histórico já abre mostrando o último endereço', (
    tester,
  ) async {
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 1)));

    await abrir(tester);

    expect(find.byType(UltimoEndereco), findsOneWidget);
    expect(find.text('CEP 88020-300'), findsOneWidget);
    expect(find.text('Traçar rota'), findsOneWidget);
  });

  testWidgets('consultar CEP mostra o endereço e o botão de rota', (
    tester,
  ) async {
    viaCep.respostaCep = enderecoTeste();
    await abrir(tester);

    await tester.enterText(find.byKey(const Key('campo-cep')), '88020300');
    await tocar(tester, 'Buscar');

    expect(viaCep.cepsConsultados, ['88020300']);
    expect(find.text('Avenida Mauro Ramos'), findsOneWidget);
    expect(find.text('Traçar rota'), findsOneWidget);
  });

  testWidgets('campo de CEP só aceita 8 números', (tester) async {
    await abrir(tester);

    await tester.enterText(
      find.byKey(const Key('campo-cep')),
      '88a020-3001234',
    );

    final campo = tester.widget<TextField>(find.byKey(const Key('campo-cep')));
    expect(campo.controller!.text, '88020300');
  });

  testWidgets('CEP inexistente mostra o componente de não encontrado', (
    tester,
  ) async {
    viaCep.respostaCep = null;
    await abrir(tester);

    await tester.enterText(find.byKey(const Key('campo-cep')), '99999999');
    await tocar(tester, 'Buscar');

    expect(find.byType(BuscaVazia), findsOneWidget);
    expect(find.text('Nenhum endereço encontrado'), findsOneWidget);
  });

  testWidgets('erro de validação aparece em SnackBar (reaction)', (
    tester,
  ) async {
    await abrir(tester);

    await tester.enterText(find.byKey(const Key('campo-cep')), '123');
    await tocar(tester, 'Buscar');

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('8 dígitos'), findsOneWidget);
    expect(controller.erro, isNull);
  });

  testWidgets('erro de rede aparece em SnackBar', (tester) async {
    viaCep.erro = dioErro(DioErrorType.other);
    await abrir(tester);

    await tester.enterText(find.byKey(const Key('campo-cep')), '88020300');
    await tocar(tester, 'Buscar');

    expect(find.textContaining('Sem conexão'), findsOneWidget);
  });

  testWidgets('busca por endereço lista e o toque seleciona o último', (
    tester,
  ) async {
    viaCep.respostaEndereco = [
      enderecoTeste(),
      enderecoTeste(cep: '88020-301', logradouro: 'Avenida Mauro Ramos B'),
    ];
    await abrir(tester);

    await tocar(tester, 'Por endereço');
    await tester.enterText(find.byKey(const Key('campo-uf')), 'sc');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('campo-uf')))
          .controller!
          .text,
      'SC',
    );
    await tester.enterText(
      find.byKey(const Key('campo-cidade')),
      'Florianópolis',
    );
    await tester.enterText(
      find.byKey(const Key('campo-logradouro')),
      'Mauro Ramos',
    );
    await tocar(tester, 'Buscar');

    expect(find.byType(ListaEnderecos), findsOneWidget);
    expect(find.text('2 endereços encontrados'), findsOneWidget);
    expect(find.byType(UltimoEndereco), findsNothing);

    await tocar(tester, 'Avenida Mauro Ramos B');

    expect(find.byType(UltimoEndereco), findsOneWidget);
    expect(historico.ultimo()?.cep, '88020-301');
    expect(find.text('Traçar rota').hitTestable(), findsOneWidget);
  });

  testWidgets('traçar rota chama o app de mapa', (tester) async {
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 1)));
    await abrir(tester);

    await tocar(tester, 'Traçar rota');

    expect(abridor.chamadas, hasLength(1));
  });

  testWidgets('nova consulta limpa o campo e o resultado', (tester) async {
    viaCep.respostaCep = null;
    await abrir(tester);
    await tester.enterText(find.byKey(const Key('campo-cep')), '99999999');
    await tocar(tester, 'Buscar');

    await tocar(tester, 'Nova consulta');

    final campo = tester.widget<TextField>(find.byKey(const Key('campo-cep')));
    expect(campo.controller!.text, isEmpty);
    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);
  });

  testWidgets('botão de histórico abre a nova página', (tester) async {
    await abrir(tester);

    await tester.tap(find.byTooltip('Histórico de consultas'));
    await tester.pumpAndSettle();

    expect(find.text('tela histórico'), findsOneWidget);
  });

  testWidgets('consultas anteriores aparecem em Consultas recentes', (
    tester,
  ) async {
    await historico.salvar(
      enderecoTeste(
        cep: '01001-000',
        logradouro: 'Praça da Sé',
        consultadoEm: DateTime(2026, 11, 1),
      ),
    );
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 2)));

    await abrir(tester);

    expect(find.text('Consultas recentes'), findsOneWidget);
    expect(find.text('Praça da Sé'), findsOneWidget);
    expect(find.text('Avenida Mauro Ramos'), findsOneWidget);
  });

  testWidgets('tocar numa consulta recente vira o último endereço', (
    tester,
  ) async {
    await historico.salvar(
      enderecoTeste(
        cep: '01001-000',
        logradouro: 'Praça da Sé',
        consultadoEm: DateTime(2026, 11, 1),
      ),
    );
    await historico.salvar(enderecoTeste(consultadoEm: DateTime(2026, 11, 2)));
    await abrir(tester);

    await tocar(tester, 'Praça da Sé');

    expect(controller.ultimoEndereco?.cep, '01001-000');
    expect(controller.recentes.single.cep, '88020-300');
  });

  testWidgets('seta de voltar só aparece com busca na tela e limpa a busca', (
    tester,
  ) async {
    viaCep.respostaCep = null;
    await abrir(tester);
    expect(find.byTooltip('Voltar para a busca'), findsNothing);

    await tester.enterText(find.byKey(const Key('campo-cep')), '99999999');
    await tocar(tester, 'Buscar');
    expect(find.byTooltip('Voltar para a busca'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar para a busca'));
    await tester.pumpAndSettle();

    expect(controller.estado, EstadoBusca.inicial);
    expect(find.byTooltip('Voltar para a busca'), findsNothing);
    final campo = tester.widget<TextField>(find.byKey(const Key('campo-cep')));
    expect(campo.controller!.text, isEmpty);
  });

  testWidgets('voltar do Android com busca na tela limpa em vez de sair', (
    tester,
  ) async {
    viaCep.respostaCep = null;
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/home',
        routes: {
          '/': (_) => const Scaffold(body: Text('tela anterior')),
          '/home': (_) => HomePage(controller: controller),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campo-cep')), '99999999');
    await tocar(tester, 'Buscar');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(controller.estado, EstadoBusca.inicial);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('tela anterior'), findsOneWidget);
  });

  testWidgets('voltar durante a busca não apaga o campo', (tester) async {
    final lento = _ViaCepLentoCep();
    final c = HomeController(
      EnderecoService(lento, historico),
      RotaService(
        geocodificar: geocodificadorFixo([localTeste()]),
        abridor: abridor,
      ),
    );
    await tester.pumpWidget(MaterialApp(home: HomePage(controller: c)));
    await tester.enterText(find.byKey(const Key('campo-cep')), '88020300');
    await tester.tap(find.text('Buscar'));
    await tester.pump();
    expect(c.carregando, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pump();

    final campo = tester.widget<TextField>(find.byKey(const Key('campo-cep')));
    expect(campo.controller!.text, '88020300');

    lento.pendente.complete(enderecoTeste());
    await tester.pumpAndSettle();
    expect(c.estado, EstadoBusca.encontrado);
  });
}

class _ViaCepLentoCep extends FakeViaCepRepository {
  final pendente = Completer<EnderecoModel?>();

  @override
  Future<EnderecoModel?> buscarPorCep(String cep) => pendente.future;
}
