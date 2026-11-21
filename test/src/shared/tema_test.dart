import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/shared/colors/app_colors.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (claro, escuro) = la > lb ? (la, lb) : (lb, la);
  return (claro + 0.05) / (escuro + 0.05);
}

void main() {
  test('tema claro usa Blue Dianne e Porsche', () {
    final tema = AppTheme.claro;

    expect(tema.brightness, Brightness.light);
    expect(tema.colorScheme.primary, AppColors.blueDianne);
    expect(tema.colorScheme.secondary, AppColors.porsche);
    expect(tema.appBarTheme.backgroundColor, AppColors.blueDianne);
    expect(tema.extension<CoresApp>()!.destaque, AppColors.porsche);
  });

  test('tema claro: texto do botão principal passa AA para texto comum', () {
    final esquema = AppTheme.claro.colorScheme;
    expect(_contraste(esquema.onPrimary, esquema.primary), greaterThan(4.5));
  });

  test('tema escuro: escritos brancos e detalhes em Red Damask', () {
    final tema = AppTheme.escuro;
    final cores = tema.extension<CoresApp>()!;
    final contornado = tema.outlinedButtonTheme.style!;

    expect(tema.colorScheme.onPrimary, AppColors.branco);
    expect(contornado.foregroundColor!.resolve({}), cores.texto);
    expect(contornado.iconColor!.resolve({}), AppColors.redDamask);
  });

  test('tema escuro usa Mirage e Red Damask', () {
    final tema = AppTheme.escuro;

    expect(tema.brightness, Brightness.dark);
    expect(tema.scaffoldBackgroundColor, AppColors.mirage);
    expect(tema.colorScheme.primary, AppColors.redDamask);
    expect(tema.extension<CoresApp>()!.splashFundo, AppColors.mirage);
  });

  for (final (nome, tema) in [
    ('claro', AppTheme.claro),
    ('escuro', AppTheme.escuro),
  ]) {
    test('tema $nome: texto corrido com contraste AA (≥ 4,5)', () {
      final esquema = tema.colorScheme;
      final cores = tema.extension<CoresApp>()!;

      expect(_contraste(cores.texto, esquema.surface), greaterThan(4.5));
      expect(_contraste(cores.textoSuave, esquema.surface), greaterThan(4.5));
      expect(_contraste(esquema.onError, esquema.error), greaterThan(4.5));
      expect(
        _contraste(cores.texto, tema.scaffoldBackgroundColor),
        greaterThan(4.5),
      );
    });

    testWidgets('tema $nome: botão principal com texto AA (≥ 4,5)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: tema,
          home: Scaffold(
            body: FilledButton(onPressed: () {}, child: const Text('Buscar')),
          ),
        ),
      );

      final fundo = tester
          .widget<Material>(
            find.descendant(
              of: find.byType(FilledButton),
              matching: find.byType(Material),
            ),
          )
          .color!;
      final texto = tester
          .renderObject<RenderParagraph>(find.text('Buscar'))
          .text
          .style!
          .color!;

      expect(_contraste(texto, fundo), greaterThan(4.5));
      expect(texto, AppColors.branco);
    });
  }

  testWidgets('botão principal desabilitado mantém o estilo padrão', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.escuro,
        home: const Scaffold(
          body: FilledButton(onPressed: null, child: Text('Buscar')),
        ),
      ),
    );

    final fundo = tester
        .widget<Material>(
          find.descendant(
            of: find.byType(FilledButton),
            matching: find.byType(Material),
          ),
        )
        .color;
    expect(fundo, isNot(AppColors.redDamask));
    expect(fundo, isNot(AppColors.redDamaskFechado));
  });

  test('Red Damask original continua nos detalhes do tema escuro', () {
    final tema = AppTheme.escuro;
    expect(tema.colorScheme.primary, AppColors.redDamask);
    expect(tema.extension<CoresApp>()!.destaque, AppColors.redDamask);
  });
}
