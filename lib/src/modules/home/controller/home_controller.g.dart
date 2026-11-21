// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  Computed<bool>? _$carregandoComputed;

  @override
  bool get carregando => (_$carregandoComputed ??= Computed<bool>(
    () => super.carregando,
    name: 'HomeControllerBase.carregando',
  )).value;
  Computed<bool>? _$temBuscaAtivaComputed;

  @override
  bool get temBuscaAtiva => (_$temBuscaAtivaComputed ??= Computed<bool>(
    () => super.temBuscaAtiva,
    name: 'HomeControllerBase.temBuscaAtiva',
  )).value;
  Computed<bool>? _$podeTracarRotaComputed;

  @override
  bool get podeTracarRota => (_$podeTracarRotaComputed ??= Computed<bool>(
    () => super.podeTracarRota,
    name: 'HomeControllerBase.podeTracarRota',
  )).value;

  late final _$modoAtom = Atom(
    name: 'HomeControllerBase.modo',
    context: context,
  );

  @override
  ModoBusca get modo {
    _$modoAtom.reportRead();
    return super.modo;
  }

  @override
  set modo(ModoBusca value) {
    _$modoAtom.reportWrite(value, super.modo, () {
      super.modo = value;
    });
  }

  late final _$estadoAtom = Atom(
    name: 'HomeControllerBase.estado',
    context: context,
  );

  @override
  EstadoBusca get estado {
    _$estadoAtom.reportRead();
    return super.estado;
  }

  @override
  set estado(EstadoBusca value) {
    _$estadoAtom.reportWrite(value, super.estado, () {
      super.estado = value;
    });
  }

  late final _$ultimoEnderecoAtom = Atom(
    name: 'HomeControllerBase.ultimoEndereco',
    context: context,
  );

  @override
  EnderecoModel? get ultimoEndereco {
    _$ultimoEnderecoAtom.reportRead();
    return super.ultimoEndereco;
  }

  @override
  set ultimoEndereco(EnderecoModel? value) {
    _$ultimoEnderecoAtom.reportWrite(value, super.ultimoEndereco, () {
      super.ultimoEndereco = value;
    });
  }

  late final _$erroAtom = Atom(
    name: 'HomeControllerBase.erro',
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

  late final _$abrindoRotaAtom = Atom(
    name: 'HomeControllerBase.abrindoRota',
    context: context,
  );

  @override
  bool get abrindoRota {
    _$abrindoRotaAtom.reportRead();
    return super.abrindoRota;
  }

  @override
  set abrindoRota(bool value) {
    _$abrindoRotaAtom.reportWrite(value, super.abrindoRota, () {
      super.abrindoRota = value;
    });
  }

  late final _$consultarCepAsyncAction = AsyncAction(
    'HomeControllerBase.consultarCep',
    context: context,
  );

  @override
  Future<void> consultarCep(String cep) {
    return _$consultarCepAsyncAction.run(() => super.consultarCep(cep));
  }

  late final _$buscarPorEnderecoAsyncAction = AsyncAction(
    'HomeControllerBase.buscarPorEndereco',
    context: context,
  );

  @override
  Future<void> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) {
    return _$buscarPorEnderecoAsyncAction.run(
      () => super.buscarPorEndereco(
        uf: uf,
        cidade: cidade,
        logradouro: logradouro,
      ),
    );
  }

  late final _$selecionarEnderecoAsyncAction = AsyncAction(
    'HomeControllerBase.selecionarEndereco',
    context: context,
  );

  @override
  Future<void> selecionarEndereco(EnderecoModel endereco) {
    return _$selecionarEnderecoAsyncAction.run(
      () => super.selecionarEndereco(endereco),
    );
  }

  late final _$tracarRotaAsyncAction = AsyncAction(
    'HomeControllerBase.tracarRota',
    context: context,
  );

  @override
  Future<void> tracarRota() {
    return _$tracarRotaAsyncAction.run(() => super.tracarRota());
  }

  late final _$HomeControllerBaseActionController = ActionController(
    name: 'HomeControllerBase',
    context: context,
  );

  @override
  void carregarUltimo() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.carregarUltimo',
    );
    try {
      return super.carregarUltimo();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void alterarModo(ModoBusca novoModo) {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.alterarModo',
    );
    try {
      return super.alterarModo(novoModo);
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void novaConsulta() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.novaConsulta',
    );
    try {
      return super.novaConsulta();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void limparErro() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
      name: 'HomeControllerBase.limparErro',
    );
    try {
      return super.limparErro();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
modo: ${modo},
estado: ${estado},
ultimoEndereco: ${ultimoEndereco},
erro: ${erro},
abrindoRota: ${abrindoRota},
carregando: ${carregando},
temBuscaAtiva: ${temBuscaAtiva},
podeTracarRota: ${podeTracarRota}
    ''';
  }
}
