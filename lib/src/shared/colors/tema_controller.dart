import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../storage/preferencias_repository.dart';

part 'tema_controller.g.dart';

class TemaController = TemaControllerBase with _$TemaController;

abstract class TemaControllerBase with Store {
  TemaControllerBase(this._preferencias);

  final PreferenciasRepository _preferencias;

  @observable
  ThemeMode modo = ThemeMode.system;

  @action
  void carregar() {
    modo = switch (_preferencias.lerTema()) {
      'claro' => ThemeMode.light,
      'escuro' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  bool estaEscuro(Brightness brilhoDoSistema) => switch (modo) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system => brilhoDoSistema == Brightness.dark,
  };

  @action
  Future<void> alternar(Brightness brilhoDoSistema) async {
    final paraEscuro = !estaEscuro(brilhoDoSistema);
    modo = paraEscuro ? ThemeMode.dark : ThemeMode.light;
    try {
      await _preferencias.salvarTema(paraEscuro ? 'escuro' : 'claro');
    } catch (_) {}
  }
}
