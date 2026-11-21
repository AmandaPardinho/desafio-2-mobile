import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/modules/home/model/endereco_model.dart';

import '../../../fixtures/fixtures.dart';

void main() {
  group('EnderecoModel.fromJson', () {
    test('lê a resposta real do ViaCEP para um CEP válido', () {
      final json = fixtureJson('cep_01001000.json') as Map<String, dynamic>;
      final endereco = EnderecoModel.fromJson(json);

      expect(EnderecoModel.respostaDeErro(json), isFalse);
      expect(endereco.cep, '01001-000');
      expect(endereco.logradouro, 'Praça da Sé');
      expect(endereco.bairro, 'Sé');
      expect(endereco.localidade, 'São Paulo');
      expect(endereco.uf, 'SP');
      expect(endereco.ddd, '11');
      expect(endereco.estado, 'São Paulo');
      expect(endereco.regiao, 'Sudeste');
      expect(endereco.ibge, '3550308');
      expect(endereco.gia, '1004');
      expect(endereco.siafi, '7107');
      expect(endereco.unidade, '');
      expect(endereco.consultadoEm, isNull);
    });

    test('campo ausente vira texto vazio, não null', () {
      final endereco = EnderecoModel.fromJson({'cep': '88000-000'});

      expect(endereco.logradouro, '');
      expect(endereco.uf, '');
    });
  });

  group('EnderecoModel.respostaDeErro', () {
    test('reconhece o erro como string, formato real atual do ViaCEP', () {
      final json = fixtureJson('cep_inexistente.json') as Map<String, dynamic>;

      expect(json['erro'], 'true');
      expect(EnderecoModel.respostaDeErro(json), isTrue);
    });

    test('reconhece o erro como booleano', () {
      expect(EnderecoModel.respostaDeErro({'erro': true}), isTrue);
    });

    test('resposta sem erro não é erro', () {
      expect(EnderecoModel.respostaDeErro({'cep': '01001-000'}), isFalse);
      expect(EnderecoModel.respostaDeErro({'erro': false}), isFalse);
    });
  });

  group('derivados', () {
    final endereco = EnderecoModel(
      cep: '88020-300',
      logradouro: 'Avenida Mauro Ramos',
      complemento: '',
      bairro: 'Centro',
      localidade: 'Florianópolis',
      uf: 'SC',
      ddd: '48',
    );

    test('cepSomenteDigitos tira o hífen', () {
      expect(endereco.cepSomenteDigitos, '88020300');
    });

    test('enderecoParaMapa junta as partes e ignora vazias', () {
      expect(
        endereco.enderecoParaMapa,
        'Avenida Mauro Ramos, Centro, Florianópolis, SC, 88020-300, Brasil',
      );
    });

    test('consultadoAgora carimba a data sem mudar o resto', () {
      final momento = DateTime(2026, 11, 20, 21);
      final carimbado = endereco.consultadoAgora(momento);

      expect(carimbado.consultadoEm, momento);
      expect(carimbado.cep, endereco.cep);
      expect(carimbado.logradouro, endereco.logradouro);
    });
  });
}
