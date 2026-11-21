import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/shared/components/app_feedback.dart';
import 'package:fastlocation/src/shared/components/app_loading.dart';

Widget _emTela(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('AppLoading mostra o indicador e a mensagem', (tester) async {
    await tester.pumpWidget(
      _emTela(const AppLoading(mensagem: 'Buscando CEP...')),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Buscando CEP...'), findsOneWidget);
  });

  testWidgets('AppFeedback mostra ícone, título e mensagem', (tester) async {
    await tester.pumpWidget(
      _emTela(
        const AppFeedback(
          icone: Icons.search_off,
          titulo: 'Nada encontrado',
          mensagem: 'Confira o CEP digitado.',
        ),
      ),
    );

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('Nada encontrado'), findsOneWidget);
    expect(find.text('Confira o CEP digitado.'), findsOneWidget);
  });

  testWidgets('AppFeedback sem mensagem mostra só o título', (tester) async {
    await tester.pumpWidget(
      _emTela(
        const AppFeedback(icone: Icons.history, titulo: 'Histórico vazio'),
      ),
    );

    expect(find.text('Histórico vazio'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });
}
