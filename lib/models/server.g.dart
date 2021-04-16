// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerAdapter extends TypeAdapter<Server> {
  @override
  final int typeId = 1;

  @override
  Server read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Server(
      name: fields[0] as String,
      hostname: fields[1] as String,
      username: fields[2] as String,
      password: fields[3] as String,
      port: fields[4] as int,
      privateKey: fields[5] as String,
      privateKeyPassphrase: fields[6] as String,
    )
      ..useCount = fields[7] as int
      ..useKeyring = fields[8] as bool
      ..uuid = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, Server obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.hostname)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.port)
      ..writeByte(5)
      ..write(obj.privateKey)
      ..writeByte(6)
      ..write(obj.privateKeyPassphrase)
      ..writeByte(7)
      ..write(obj.useCount)
      ..writeByte(8)
      ..write(obj.useKeyring)
      ..writeByte(9)
      ..write(obj.uuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
