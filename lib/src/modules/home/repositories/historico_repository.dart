import 'package:hive/hive.dart';

import '../model/endereco_model.dart';

class HistoricoRepository {
  HistoricoRepository(this._box);

  final Box<EnderecoModel> _box;

  static final DateTime _semData = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> salvar(EnderecoModel endereco) {
    return _box.put(endereco.cepSomenteDigitos, endereco);
  }

  List<EnderecoModel> listar() {
    final enderecos = _box.values.toList()
      ..sort(
        (a, b) =>
            (b.consultadoEm ?? _semData).compareTo(a.consultadoEm ?? _semData),
      );
    return enderecos;
  }

  EnderecoModel? ultimo() {
    final enderecos = listar();
    return enderecos.isEmpty ? null : enderecos.first;
  }

  Future<void> limpar() => _box.clear();
}
