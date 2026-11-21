import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/app_widget.dart';

import 'fakes/fakes_home.dart';

void main() {
  testWidgets('AppWidget abre o FastLocation sem o exemplo do contador', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );

    expect(find.text('FastLocation'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('0'), findsNothing);

    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
