import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import '../colors/tema_controller.dart';

class BotaoTema extends StatelessWidget {
  const BotaoTema({super.key, required this.controller});

  final TemaController controller;

  @override
  Widget build(BuildContext context) {
    final brilhoDoSistema = MediaQuery.platformBrightnessOf(context);

    return Observer(
      builder: (_) {
        final escuro = controller.estaEscuro(brilhoDoSistema);
        return IconButton(
          icon: Icon(
            escuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          tooltip: escuro ? 'Usar modo claro' : 'Usar modo escuro',
          onPressed: () => controller.alternar(brilhoDoSistema),
        );
      },
    );
  }
}
