import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/endereco_model.dart';

class EnderecoCard extends StatelessWidget {
  const EnderecoCard({
    super.key,
    required this.endereco,
    this.onTap,
    this.selecionado = false,
    this.mostrarData = false,
  });

  final EnderecoModel endereco;
  final VoidCallback? onTap;
  final bool selecionado;
  final bool mostrarData;

  @override
  Widget build(BuildContext context) {
    final titulo = endereco.logradouro.isEmpty
        ? 'CEP geral de ${endereco.cidadeUf}'
        : endereco.logradouro;
    final cores = context.cores;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppMetrics.spacingXs),
      color: context.esquema.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radius),
        side: BorderSide(
          color: selecionado ? cores.destaque : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.spacingMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selecionado ? Icons.check_circle : Icons.place_outlined,
                color: context.esquema.primary,
              ),
              const SizedBox(width: AppMetrics.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cores.texto,
                      ),
                    ),
                    const SizedBox(height: AppMetrics.spacingXs),
                    if (endereco.complemento.isNotEmpty)
                      _Linha(endereco.complemento),
                    if (endereco.bairro.isNotEmpty) _Linha(endereco.bairro),
                    _Linha(endereco.cidadeUf),
                    _Linha('CEP ${endereco.cep}', destaque: true),
                    if (mostrarData && endereco.consultadoEm != null)
                      _Linha(
                        'Consultado em ${_formatar(endereco.consultadoEm!)}',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatar(DateTime data) {
    String doisDigitos(int n) => n.toString().padLeft(2, '0');
    return '${doisDigitos(data.day)}/${doisDigitos(data.month)}/${data.year} '
        'às ${doisDigitos(data.hour)}:${doisDigitos(data.minute)}';
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.texto, {this.destaque = false});

  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        texto,
        style: TextStyle(
          color: destaque ? context.cores.texto : context.cores.textoSuave,
          fontWeight: destaque ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
