class ConsultaException implements Exception {
  const ConsultaException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'ConsultaException: $mensagem';
}

class RotaException implements Exception {
  const RotaException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'RotaException: $mensagem';
}
