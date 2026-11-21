import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';

import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/model/endereco_model.dart';
import 'package:fastlocation/src/modules/home/repositories/historico_repository.dart';
import 'package:fastlocation/src/modules/home/repositories/via_cep_repository.dart';
import 'package:fastlocation/src/modules/home/service/endereco_service.dart';
import 'package:fastlocation/src/modules/home/service/rota_service.dart';

EnderecoModel enderecoTeste({
  String cep = '88020-300',
  String logradouro = 'Avenida Mauro Ramos',
  DateTime? consultadoEm,
}) {
  return EnderecoModel(
    cep: cep,
    logradouro: logradouro,
    complemento: '',
    bairro: 'Centro',
    localidade: 'Florianópolis',
    uf: 'SC',
    ddd: '48',
    consultadoEm: consultadoEm,
  );
}

DioError dioErro(DioErrorType tipo, {int? status}) {
  final requisicao = RequestOptions(path: '/');
  return DioError(
    requestOptions: requisicao,
    type: tipo,
    response: status == null
        ? null
        : Response<dynamic>(requestOptions: requisicao, statusCode: status),
  );
}

class FakeViaCepRepository implements ViaCepRepository {
  EnderecoModel? respostaCep;
  List<EnderecoModel> respostaEndereco = [];
  Object? erro;
  final List<String> cepsConsultados = [];
  final List<Map<String, String>> enderecosConsultados = [];

  @override
  Future<EnderecoModel?> buscarPorCep(String cep) async {
    cepsConsultados.add(cep);
    if (erro != null) throw erro!;
    return respostaCep;
  }

  @override
  Future<List<EnderecoModel>> buscarPorEndereco({
    required String uf,
    required String cidade,
    required String logradouro,
  }) async {
    enderecosConsultados.add({
      'uf': uf,
      'cidade': cidade,
      'logradouro': logradouro,
    });
    if (erro != null) throw erro!;
    return respostaEndereco;
  }
}

class FakeHistoricoRepository implements HistoricoRepository {
  final Map<String, EnderecoModel> _dados = {};

  @override
  Future<void> salvar(EnderecoModel endereco) async {
    _dados[endereco.cepSomenteDigitos] = endereco;
  }

  @override
  List<EnderecoModel> listar() {
    final lista = _dados.values.toList()
      ..sort((a, b) => b.consultadoEm!.compareTo(a.consultadoEm!));
    return lista;
  }

  @override
  EnderecoModel? ultimo() {
    final lista = listar();
    return lista.isEmpty ? null : lista.first;
  }

  @override
  Future<void> limpar() async => _dados.clear();
}

class FakeAbridorDeMapa implements AbridorDeMapa {
  bool temAppDeMapa = true;
  final List<({double latitude, double longitude, String titulo})> chamadas =
      [];

  @override
  Future<bool> abrirRota({
    required double latitude,
    required double longitude,
    required String titulo,
  }) async {
    chamadas.add((latitude: latitude, longitude: longitude, titulo: titulo));
    return temAppDeMapa;
  }
}

Geocodificador geocodificadorFixo(List<Location> locais) {
  return (_) async => locais;
}

Location localTeste() => Location(
  latitude: -27.59,
  longitude: -48.54,
  timestamp: DateTime(2026, 11, 20),
);

HomeController homeControllerFake() {
  return HomeController(
    EnderecoService(FakeViaCepRepository(), FakeHistoricoRepository()),
    RotaService(
      geocodificar: geocodificadorFixo([localTeste()]),
      abridor: FakeAbridorDeMapa(),
    ),
  );
}
