import 'package:hive/hive.dart';

abstract interface class PreferenciasRepository {
  String? lerTema();

  Future<void> salvarTema(String tema);
}

class HivePreferenciasRepository implements PreferenciasRepository {
  HivePreferenciasRepository(this._box);

  final Box<String> _box;

  static const String _chaveTema = 'tema';

  @override
  String? lerTema() => _box.get(_chaveTema);

  @override
  Future<void> salvarTema(String tema) => _box.put(_chaveTema, tema);
}

class PreferenciasEmMemoria implements PreferenciasRepository {
  String? _tema;

  @override
  String? lerTema() => _tema;

  @override
  Future<void> salvarTema(String tema) async => _tema = tema;
}
