import 'package:dio/dio.dart';

abstract final class AppHttpClient {
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws/';
  static const int timeoutMs = 10000;

  static Dio viaCep() {
    return Dio(
      BaseOptions(
        baseUrl: viaCepBaseUrl,
        connectTimeout: timeoutMs,
        receiveTimeout: timeoutMs,
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );
  }
}
