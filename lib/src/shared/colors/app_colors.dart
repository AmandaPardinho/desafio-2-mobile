import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  static const Color porsche = Color(0xFFEAAE69);
  static const Color blueDianne = Color(0xFF204852);
  static const Color mirage = Color(0xFF161928);
  static const Color redDamask = Color(0xFFDA6A41);
  static const Color redDamaskFechado = Color(0xFFAE5534);

  static const Color branco = Color(0xFFFFFFFF);

  static const Color fundoClaro = Color(0xFFF8F4EE);
  static const Color textoClaro = Color(0xFF17282D);
  static const Color textoSuaveClaro = Color(0xFF55676C);
  static const Color destaqueSuaveClaro = Color(0xFFF6DEBF);
  static const Color erroClaro = Color(0xFFB3261E);

  static const Color superficieEscura = Color(0xFF22263A);
  static const Color textoEscuro = Color(0xFFECEDF2);
  static const Color textoSuaveEscuro = Color(0xFFA6ABBF);
  static const Color destaqueSuaveEscuro = Color(0xFF4B2C24);
  static const Color erroEscuro = Color(0xFFFFB4AB);
  static const Color onErroEscuro = Color(0xFF690005);
}

@immutable
class CoresApp extends ThemeExtension<CoresApp> {
  const CoresApp({
    required this.texto,
    required this.textoSuave,
    required this.destaque,
    required this.splashFundo,
    required this.splashIcone,
  });

  static const claro = CoresApp(
    texto: AppColors.textoClaro,
    textoSuave: AppColors.textoSuaveClaro,
    destaque: AppColors.porsche,
    splashFundo: AppColors.blueDianne,
    splashIcone: AppColors.porsche,
  );

  static const escuro = CoresApp(
    texto: AppColors.textoEscuro,
    textoSuave: AppColors.textoSuaveEscuro,
    destaque: AppColors.redDamask,
    splashFundo: AppColors.mirage,
    splashIcone: AppColors.redDamask,
  );

  final Color texto;
  final Color textoSuave;
  final Color destaque;
  final Color splashFundo;
  final Color splashIcone;

  @override
  CoresApp copyWith({
    Color? texto,
    Color? textoSuave,
    Color? destaque,
    Color? splashFundo,
    Color? splashIcone,
  }) {
    return CoresApp(
      texto: texto ?? this.texto,
      textoSuave: textoSuave ?? this.textoSuave,
      destaque: destaque ?? this.destaque,
      splashFundo: splashFundo ?? this.splashFundo,
      splashIcone: splashIcone ?? this.splashIcone,
    );
  }

  @override
  CoresApp lerp(CoresApp? other, double t) {
    if (other == null) return this;
    return CoresApp(
      texto: Color.lerp(texto, other.texto, t)!,
      textoSuave: Color.lerp(textoSuave, other.textoSuave, t)!,
      destaque: Color.lerp(destaque, other.destaque, t)!,
      splashFundo: Color.lerp(splashFundo, other.splashFundo, t)!,
      splashIcone: Color.lerp(splashIcone, other.splashIcone, t)!,
    );
  }
}

extension CoresDoContexto on BuildContext {
  CoresApp get cores => Theme.of(this).extension<CoresApp>() ?? CoresApp.claro;

  ColorScheme get esquema => Theme.of(this).colorScheme;
}

abstract final class AppTheme {
  static final ThemeData claro = _tema(
    esquema: ColorScheme.fromSeed(seedColor: AppColors.blueDianne).copyWith(
      primary: AppColors.blueDianne,
      onPrimary: AppColors.branco,
      secondary: AppColors.porsche,
      onSecondary: AppColors.blueDianne,
      secondaryContainer: AppColors.destaqueSuaveClaro,
      onSecondaryContainer: AppColors.blueDianne,
      surface: AppColors.branco,
      onSurface: AppColors.textoClaro,
      onSurfaceVariant: AppColors.textoSuaveClaro,
      error: AppColors.erroClaro,
      onError: AppColors.branco,
    ),
    fundo: AppColors.fundoClaro,
    barra: AppColors.blueDianne,
    textoBarra: AppColors.branco,
    cores: CoresApp.claro,
  );

  static final ThemeData escuro = _tema(
    esquema:
        ColorScheme.fromSeed(
          seedColor: AppColors.redDamask,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.redDamask,
          onPrimary: AppColors.branco,
          secondary: AppColors.redDamask,
          onSecondary: AppColors.mirage,
          secondaryContainer: AppColors.destaqueSuaveEscuro,
          onSecondaryContainer: AppColors.textoEscuro,
          surface: AppColors.superficieEscura,
          onSurface: AppColors.textoEscuro,
          onSurfaceVariant: AppColors.textoSuaveEscuro,
          error: AppColors.erroEscuro,
          onError: AppColors.onErroEscuro,
        ),
    fundo: AppColors.mirage,
    barra: AppColors.mirage,
    textoBarra: AppColors.textoEscuro,
    cores: CoresApp.escuro,
    textoNeutroNosBotoes: true,
    fundoBotaoPrincipal: AppColors.redDamaskFechado,
  );

  static ThemeData _tema({
    required ColorScheme esquema,
    required Color fundo,
    required Color barra,
    required Color textoBarra,
    required CoresApp cores,
    bool textoNeutroNosBotoes = false,
    Color? fundoBotaoPrincipal,
  }) {
    final secundario = textoNeutroNosBotoes
        ? ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(cores.texto),
            iconColor: WidgetStatePropertyAll(esquema.primary),
          )
        : null;

    return ThemeData(
      colorScheme: esquema,
      scaffoldBackgroundColor: fundo,
      appBarTheme: AppBarTheme(
        backgroundColor: barra,
        foregroundColor: textoBarra,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(color: esquema.surface),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          backgroundColor: fundoBotaoPrincipal == null
              ? null
              : WidgetStateProperty.resolveWith(
                  (estados) => estados.contains(WidgetState.disabled)
                      ? null
                      : fundoBotaoPrincipal,
                ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secundario),
      textButtonTheme: TextButtonThemeData(style: secundario),
      extensions: [cores],
    );
  }
}
