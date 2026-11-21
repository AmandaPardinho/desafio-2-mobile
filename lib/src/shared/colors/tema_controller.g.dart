// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tema_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TemaController on TemaControllerBase, Store {
  late final _$modoAtom = Atom(
    name: 'TemaControllerBase.modo',
    context: context,
  );

  @override
  ThemeMode get modo {
    _$modoAtom.reportRead();
    return super.modo;
  }

  @override
  set modo(ThemeMode value) {
    _$modoAtom.reportWrite(value, super.modo, () {
      super.modo = value;
    });
  }

  late final _$alternarAsyncAction = AsyncAction(
    'TemaControllerBase.alternar',
    context: context,
  );

  @override
  Future<void> alternar(Brightness brilhoDoSistema) {
    return _$alternarAsyncAction.run(() => super.alternar(brilhoDoSistema));
  }

  late final _$TemaControllerBaseActionController = ActionController(
    name: 'TemaControllerBase',
    context: context,
  );

  @override
  void carregar() {
    final _$actionInfo = _$TemaControllerBaseActionController.startAction(
      name: 'TemaControllerBase.carregar',
    );
    try {
      return super.carregar();
    } finally {
      _$TemaControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
modo: ${modo}
    ''';
  }
}
