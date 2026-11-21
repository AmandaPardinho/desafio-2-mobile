// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HistoryController on HistoryControllerBase, Store {
  Computed<bool>? _$vazioComputed;

  @override
  bool get vazio => (_$vazioComputed ??= Computed<bool>(
    () => super.vazio,
    name: 'HistoryControllerBase.vazio',
  )).value;

  late final _$carregadoAtom = Atom(
    name: 'HistoryControllerBase.carregado',
    context: context,
  );

  @override
  bool get carregado {
    _$carregadoAtom.reportRead();
    return super.carregado;
  }

  @override
  set carregado(bool value) {
    _$carregadoAtom.reportWrite(value, super.carregado, () {
      super.carregado = value;
    });
  }

  late final _$erroAtom = Atom(
    name: 'HistoryControllerBase.erro',
    context: context,
  );

  @override
  String? get erro {
    _$erroAtom.reportRead();
    return super.erro;
  }

  @override
  set erro(String? value) {
    _$erroAtom.reportWrite(value, super.erro, () {
      super.erro = value;
    });
  }

  late final _$limparAsyncAction = AsyncAction(
    'HistoryControllerBase.limpar',
    context: context,
  );

  @override
  Future<void> limpar() {
    return _$limparAsyncAction.run(() => super.limpar());
  }

  late final _$consultarDeNovoAsyncAction = AsyncAction(
    'HistoryControllerBase.consultarDeNovo',
    context: context,
  );

  @override
  Future<bool> consultarDeNovo(EnderecoModel endereco) {
    return _$consultarDeNovoAsyncAction.run(
      () => super.consultarDeNovo(endereco),
    );
  }

  late final _$HistoryControllerBaseActionController = ActionController(
    name: 'HistoryControllerBase',
    context: context,
  );

  @override
  void carregar() {
    final _$actionInfo = _$HistoryControllerBaseActionController.startAction(
      name: 'HistoryControllerBase.carregar',
    );
    try {
      return super.carregar();
    } finally {
      _$HistoryControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparErro() {
    final _$actionInfo = _$HistoryControllerBaseActionController.startAction(
      name: 'HistoryControllerBase.limparErro',
    );
    try {
      return super.limparErro();
    } finally {
      _$HistoryControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
carregado: ${carregado},
erro: ${erro},
vazio: ${vazio}
    ''';
  }
}
