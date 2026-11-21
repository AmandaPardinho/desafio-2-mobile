import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/http/app_http_client.dart';

Uri _uriFinal(Dio dio, String path) => Options().compose(dio.options, path).uri;

void main() {
  test('AppHttpClient.viaCep configura timeout e JSON', () {
    final dio = AppHttpClient.viaCep();

    expect(dio.options.connectTimeout, AppHttpClient.timeoutMs);
    expect(dio.options.receiveTimeout, AppHttpClient.timeoutMs);
    expect(dio.options.headers['Accept'], 'application/json');
  });

  test('caminho relativo sem barra inicial monta a URL do ViaCEP', () {
    expect(
      _uriFinal(AppHttpClient.viaCep(), '01001000/json/').toString(),
      'https://viacep.com.br/ws/01001000/json/',
    );
  });

  test('caminho com barra inicial monta a mesma URL', () {
    expect(
      _uriFinal(
        AppHttpClient.viaCep(),
        '/SC/Florianopolis/Mauro/json/',
      ).toString(),
      'https://viacep.com.br/ws/SC/Florianopolis/Mauro/json/',
    );
  });
}
