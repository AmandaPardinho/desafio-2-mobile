import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/app_widget.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';

import '../fakes/fakes_home.dart';

void main() {
  testWidgets('rolar além do fim não estica as telas do app', (tester) async {
    await tester.pumpWidget(
      const AppWidget(criarHomeController: homeControllerFake),
    );
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsWidgets);
  });
}
