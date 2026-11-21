import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/app_widget.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/shared/colors/app_colors.dart';
import 'package:fastlocation/src/shared/colors/tema_controller.dart';
import 'package:fastlocation/src/shared/storage/preferencias_repository.dart';

import '../../fakes/fakes_home.dart';

void main() {
  group('TemaController', () {
    test('sem preferência salva segue o sistema', () {
      final tema = TemaController(PreferenciasEmMemoria())..carregar();

      expect(tema.modo, ThemeMode.system);
      expect(tema.estaEscuro(Brightness.dark), isTrue);
      expect(tema.estaEscuro(Brightness.light), isFalse);
    });

    test(
      'alternar a partir do sistema claro vai para escuro e salva',
      () async {
        final preferencias = PreferenciasEmMemoria();
        final tema = TemaController(preferencias)..carregar();

        await tema.alternar(Brightness.light);

        expect(tema.modo, ThemeMode.dark);
        expect(preferencias.lerTema(), 'escuro');
      },
    );

    test('alternar duas vezes volta ao claro', () async {
      final tema = TemaController(PreferenciasEmMemoria())..carregar();

      await tema.alternar(Brightness.light);
      await tema.alternar(Brightness.light);

      expect(tema.modo, ThemeMode.light);
    });

    test('carregar lê a escolha salva', () async {
      final preferencias = PreferenciasEmMemoria();
      await preferencias.salvarTema('escuro');

      final tema = TemaController(preferencias)..carregar();

      expect(tema.modo, ThemeMode.dark);
    });
  });

  test('a escolha sobrevive a fechar e abrir o Hive', () async {
    final pasta = await Directory.systemTemp.createTemp('preferencias_test');
    Hive.init(pasta.path);
    final box = await Hive.openBox<String>('preferencias_teste');

    await TemaController(HivePreferenciasRepository(box))
        .alternar(Brightness.light);
    await box.close();

    final reaberta = await Hive.openBox<String>('preferencias_teste');
    final tema = TemaController(HivePreferenciasRepository(reaberta))
      ..carregar();

    expect(tema.modo, ThemeMode.dark);
    await Hive.close();
    await pasta.delete(recursive: true);
  });

  testWidgets('o botão da Home troca o tema do app inteiro', (tester) async {
    final tema = TemaController(PreferenciasEmMemoria())..carregar();
    await tester.pumpWidget(
      AppWidget(tema: tema, criarHomeController: homeControllerFake),
    );
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    Color fundo() =>
        Theme.of(tester.element(find.byType(HomePage))).scaffoldBackgroundColor;

    expect(fundo(), AppColors.fundoClaro);
    expect(find.byTooltip('Usar modo escuro'), findsOneWidget);

    await tester.tap(find.byTooltip('Usar modo escuro'));
    await tester.pumpAndSettle();

    expect(fundo(), AppColors.mirage);
    expect(find.byTooltip('Usar modo claro'), findsOneWidget);

    await tester.tap(find.byTooltip('Usar modo claro'));
    await tester.pumpAndSettle();

    expect(fundo(), AppColors.fundoClaro);
  });
}
