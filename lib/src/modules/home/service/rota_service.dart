import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';

import '../model/endereco_model.dart';
import 'consulta_exception.dart';

typedef Geocodificador = Future<List<Location>> Function(String endereco);

abstract interface class AbridorDeMapa {
  Future<bool> abrirRota({
    required double latitude,
    required double longitude,
    required String titulo,
  });
}

class MapLauncherAbridor implements AbridorDeMapa {
  @override
  Future<bool> abrirRota({
    required double latitude,
    required double longitude,
    required String titulo,
  }) async {
    final mapas = await MapLauncher.installedMaps;
    if (mapas.isEmpty) {
      return false;
    }

    final mapa = mapas.firstWhere(
      (m) => m.mapType == MapType.google,
      orElse: () => mapas.first,
    );
    await mapa.showDirections(
      destination: Coords(latitude, longitude),
      destinationTitle: titulo,
    );
    return true;
  }
}

class RotaService {
  RotaService({Geocodificador? geocodificar, AbridorDeMapa? abridor})
    : _geocodificar = geocodificar ?? locationFromAddress,
      _abridor = abridor ?? MapLauncherAbridor();

  final Geocodificador _geocodificar;
  final AbridorDeMapa _abridor;

  Future<void> tracarRota(EnderecoModel destino) async {
    List<Location> locais;
    try {
      locais = await _geocodificar(destino.enderecoParaMapa);
    } catch (_) {
      locais = const [];
    }

    if (locais.isEmpty) {
      throw const RotaException(
        'Não foi possível localizar esse endereço no mapa.',
      );
    }

    final local = locais.first;
    bool abriu;
    try {
      abriu = await _abridor.abrirRota(
        latitude: local.latitude,
        longitude: local.longitude,
        titulo: destino.logradouro.isEmpty
            ? destino.cidadeUf
            : destino.logradouro,
      );
    } catch (_) {
      throw const RotaException('Não foi possível abrir o app de mapa.');
    }

    if (!abriu) {
      throw const RotaException(
        'Nenhum app de mapas encontrado no aparelho para traçar a rota.',
      );
    }
  }
}
