import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/modules/history/controller/history_controller.dart';
import 'package:fastlocation/src/modules/history/page/history_page.dart';
import 'package:fastlocation/src/modules/home/components/endereco_card.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';

import '../../../fakes/fakes_home.dart';

void main() {
  late FakeHistoricoRepository historico;
  late HistoryController controller;

  setUp(() {
    historico = FakeHistoricoRepository();
    controller = HistoryController(
      EnderecoService(
        FakeViaCepRepository(),
        historico,
        relogio: () => DateTime(2026, 11, 20, 22),
      ),
    );
  });

  Future<void> preencher() async {
    await historico.salvar(
      enderecoTeste(
        cep: '01001-000',
        logradouro: 'Praça da Sé',
        consultadoEm: DateTime(2026, 11, 1, 9, 5),
      ),
    );
    await historico.salvar(
      enderecoTeste(consultadoEm: DateTime(2026, 11, 2, 14, 30)),
    );
  }

  Future<void> abrirPelaHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HistoryPage(controller: controller),
                ),
              ),
              child: const Text('abrir histórico'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir histórico'));
    await tester.pumpAndSettle();
  }

  testWidgets('carrega o histórico sozinho ao abrir a página', (tester) async {
    await preencher();

    await abrirPelaHome(tester);

    expect(find.text('2 endereços consultados'), findsOneWidget);
    expect(find.byType(EnderecoCard), findsNWidgets(2));
    expect(find.text('Praça da Sé'), findsOneWidget);
    expect(find.text('Consultado em 01/11/2026 às 09:05'), findsOneWidget);
  });

  testWidgets('mais recente aparece primeiro', (tester) async {
    await preencher();

    await abrirPelaHome(tester);

    final primeiro = tester.getTopLeft(find.text('Avenida Mauro Ramos'));
    final segundo = tester.getTopLeft(find.text('Praça da Sé'));
    expect(primeiro.dy, lessThan(segundo.dy));
  });

  testWidgets('sem histórico mostra o estado vazio e desabilita limpar', (
    tester,
  ) async {
    await abrirPelaHome(tester);

    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);
    final botao = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
    );
    expect(botao.onPressed, isNull);
  });

  testWidgets('limpar pede confirmação e cancelar mantém tudo', (tester) async {
    await preencher();
    await abrirPelaHome(tester);

    await tester.tap(find.byTooltip('Limpar histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Limpar histórico?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.byType(EnderecoCard), findsNWidgets(2));
    expect(historico.listar(), hasLength(2));
  });

  testWidgets('confirmar limpeza apaga e mostra o estado vazio', (
    tester,
  ) async {
    await preencher();
    await abrirPelaHome(tester);

    await tester.tap(find.byTooltip('Limpar histórico'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Limpar'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);
    expect(historico.listar(), isEmpty);
  });

  testWidgets('tocar num endereço volta para a tela anterior e o promove', (
    tester,
  ) async {
    await preencher();
    await abrirPelaHome(tester);

    await tester.tap(find.text('Praça da Sé'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryPage), findsNothing);
    expect(find.text('abrir histórico'), findsOneWidget);
    expect(historico.ultimo()?.cep, '01001-000');
  });
}
