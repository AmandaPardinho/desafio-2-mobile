import 'package:hive/hive.dart';

part 'endereco_model.g.dart';

@HiveType(typeId: 0)
class EnderecoModel {
  EnderecoModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.ddd,
    this.consultadoEm,
    this.unidade = '',
    this.estado = '',
    this.regiao = '',
    this.ibge = '',
    this.gia = '',
    this.siafi = '',
  });

  factory EnderecoModel.fromJson(Map<String, dynamic> json) {
    String texto(String chave) => (json[chave] ?? '').toString().trim();

    return EnderecoModel(
      cep: texto('cep'),
      logradouro: texto('logradouro'),
      complemento: texto('complemento'),
      bairro: texto('bairro'),
      localidade: texto('localidade'),
      uf: texto('uf'),
      ddd: texto('ddd'),
      unidade: texto('unidade'),
      estado: texto('estado'),
      regiao: texto('regiao'),
      ibge: texto('ibge'),
      gia: texto('gia'),
      siafi: texto('siafi'),
    );
  }

  static bool respostaDeErro(Map<String, dynamic> json) {
    final erro = json['erro'];
    return erro == true || erro.toString().toLowerCase() == 'true';
  }

  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String logradouro;

  @HiveField(2)
  final String complemento;

  @HiveField(3)
  final String bairro;

  @HiveField(4)
  final String localidade;

  @HiveField(5)
  final String uf;

  @HiveField(6)
  final String ddd;

  @HiveField(7)
  final DateTime? consultadoEm;

  @HiveField(8, defaultValue: '')
  final String unidade;

  @HiveField(9, defaultValue: '')
  final String estado;

  @HiveField(10, defaultValue: '')
  final String regiao;

  @HiveField(11, defaultValue: '')
  final String ibge;

  @HiveField(12, defaultValue: '')
  final String gia;

  @HiveField(13, defaultValue: '')
  final String siafi;

  String get cepSomenteDigitos => cep.replaceAll(RegExp(r'\D'), '');

  String get cidadeUf =>
      [localidade, uf].where((parte) => parte.isNotEmpty).join(' - ');

  String get enderecoParaMapa => [
    logradouro,
    bairro,
    localidade,
    uf,
    cep,
    'Brasil',
  ].where((parte) => parte.isNotEmpty).join(', ');

  EnderecoModel consultadoAgora(DateTime momento) {
    return EnderecoModel(
      cep: cep,
      logradouro: logradouro,
      complemento: complemento,
      bairro: bairro,
      localidade: localidade,
      uf: uf,
      ddd: ddd,
      consultadoEm: momento,
      unidade: unidade,
      estado: estado,
      regiao: regiao,
      ibge: ibge,
      gia: gia,
      siafi: siafi,
    );
  }
}
