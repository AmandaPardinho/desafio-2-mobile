import 'dart:convert';
import 'dart:io';

String fixtureTexto(String nome) =>
    File('test/fixtures/$nome').readAsStringSync();

dynamic fixtureJson(String nome) => jsonDecode(fixtureTexto(nome));
