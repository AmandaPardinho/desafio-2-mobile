import 'package:hive_flutter/hive_flutter.dart';

abstract final class StorageBoxes {
  static const String historico = 'historico_enderecos';
  static const String preferencias = 'preferencias';
}

abstract final class AppStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box<T>> abrirBox<T>(String nome, TypeAdapter<T> adapter) async {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter<T>(adapter);
    }
    if (Hive.isBoxOpen(nome)) {
      return Hive.box<T>(nome);
    }
    return Hive.openBox<T>(nome);
  }

  static Future<Box<String>> abrirPreferencias() async {
    if (Hive.isBoxOpen(StorageBoxes.preferencias)) {
      return Hive.box<String>(StorageBoxes.preferencias);
    }
    return Hive.openBox<String>(StorageBoxes.preferencias);
  }
}
