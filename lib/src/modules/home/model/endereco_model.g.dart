// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'endereco_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnderecoModelAdapter extends TypeAdapter<EnderecoModel> {
  @override
  final int typeId = 0;

  @override
  EnderecoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnderecoModel(
      cep: fields[0] as String,
      logradouro: fields[1] as String,
      complemento: fields[2] as String,
      bairro: fields[3] as String,
      localidade: fields[4] as String,
      uf: fields[5] as String,
      ddd: fields[6] as String,
      consultadoEm: fields[7] as DateTime?,
      unidade: fields[8] == null ? '' : fields[8] as String,
      estado: fields[9] == null ? '' : fields[9] as String,
      regiao: fields[10] == null ? '' : fields[10] as String,
      ibge: fields[11] == null ? '' : fields[11] as String,
      gia: fields[12] == null ? '' : fields[12] as String,
      siafi: fields[13] == null ? '' : fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EnderecoModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.cep)
      ..writeByte(1)
      ..write(obj.logradouro)
      ..writeByte(2)
      ..write(obj.complemento)
      ..writeByte(3)
      ..write(obj.bairro)
      ..writeByte(4)
      ..write(obj.localidade)
      ..writeByte(5)
      ..write(obj.uf)
      ..writeByte(6)
      ..write(obj.ddd)
      ..writeByte(7)
      ..write(obj.consultadoEm)
      ..writeByte(8)
      ..write(obj.unidade)
      ..writeByte(9)
      ..write(obj.estado)
      ..writeByte(10)
      ..write(obj.regiao)
      ..writeByte(11)
      ..write(obj.ibge)
      ..writeByte(12)
      ..write(obj.gia)
      ..writeByte(13)
      ..write(obj.siafi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnderecoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
