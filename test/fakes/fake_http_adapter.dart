import 'dart:typed_data';

import 'package:dio/dio.dart';

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this._responder);

  final ResponseBody Function(RequestOptions options) _responder;
  final List<Uri> requisicoes = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requisicoes.add(options.uri);
    return _responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody respostaJson(String corpo, {int status = 200}) {
  return ResponseBody.fromString(
    corpo,
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    },
  );
}
