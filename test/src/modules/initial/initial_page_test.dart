import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/app_widget.dart';

import '../../../fakes/fakes_home.dart';

import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/initial/page/initial_page.dart';

final _tempoAteAHome =
    InitialPage.duracaoAnimacao + InitialPage.pausaAntesDaHome;
const _folga = Duration(milliseconds: 400);

Finder _transicaoDoIcone<T extends Widget>() => find
    .ancestor(of: find.byIcon(Icons.location_on), matching: find.byType(T))
    .first;

Future<void> _avancar(WidgetTester tester, Duration total) async {
  const passo = Duration(milliseconds: 50);
  for (var t = Duration.zero; t < total; t += passo) {
    await tester.pump(passo);
  }
}

void main() {
  testWidgets('abre na tela de abertura', (tester) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );

    expect(find.byType(InitialPage), findsOneWidget);
    expect(find.text('FastLocation'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await _avancar(tester, _tempoAteAHome + _folga);
  });

  testWidgets('o ícone começa invisível e pequeno e termina inteiro', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );

    FadeTransition fade() =>
        tester.widget<FadeTransition>(_transicaoDoIcone<FadeTransition>());
    ScaleTransition escala() =>
        tester.widget<ScaleTransition>(_transicaoDoIcone<ScaleTransition>());

    expect(fade().opacity.value, 0);
    expect(escala().scale.value, lessThan(1));

    await _avancar(tester, InitialPage.duracaoAnimacao ~/ 3);
    final opacidadeNoMeio = fade().opacity.value;
    expect(opacidadeNoMeio, greaterThan(0));
    expect(opacidadeNoMeio, lessThan(1));

    await _avancar(tester, InitialPage.duracaoAnimacao);
    expect(fade().opacity.value, 1);
    expect(escala().scale.value, 1);

    await _avancar(tester, InitialPage.pausaAntesDaHome + _folga);
  });

  testWidgets('continua na abertura durante a pausa', (tester) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );
    await _avancar(tester, _tempoAteAHome - _folga);

    expect(find.byType(InitialPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await _avancar(tester, _folga * 3);
  });

  testWidgets('vai sozinha para a Home e não deixa voltar', (tester) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );
    await _avancar(tester, _tempoAteAHome + _folga);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(InitialPage), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(HomePage))).canPop(),
      isFalse,
    );
  });

  testWidgets('sair da abertura durante a pausa cancela o redirecionamento', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );
    await _avancar(tester, InitialPage.duracaoAnimacao + _folga);

    await tester.pumpWidget(const MaterialApp(home: Text('outra tela')));
    await _avancar(tester, InitialPage.pausaAntesDaHome + _folga);

    expect(find.text('outra tela'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
