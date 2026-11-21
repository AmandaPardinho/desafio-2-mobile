import 'package:material_ui/material_ui.dart';

import 'src/app_widget.dart';
import 'src/modules/home/model/endereco_model.dart';
import 'src/shared/colors/tema_controller.dart';
import 'src/shared/storage/app_storage.dart';
import 'src/shared/storage/preferencias_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppStorage.init();
  await AppStorage.abrirBox<EnderecoModel>(
    StorageBoxes.historico,
    EnderecoModelAdapter(),
  );

  final preferencias = await AppStorage.abrirPreferencias();
  final tema = TemaController(HivePreferenciasRepository(preferencias))
    ..carregar();

  runApp(AppWidget(tema: tema));
}
