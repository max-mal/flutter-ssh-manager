// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portForwarding.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PortForwardingAdapter extends TypeAdapter<PortForwarding> {
  @override
  final int typeId = 2;

  @override
  PortForwarding read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PortForwarding()
      ..uuid = fields[0] as String
      ..localPort = fields[1] as int
      ..remotePort = fields[2] as int
      ..remoteHost = fields[3] as String
      ..mode = fields[4] as PortForwardingMode
      ..serverUuid = fields[5] as String
      ..startOnConnect = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, PortForwarding obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.localPort)
      ..writeByte(2)
      ..write(obj.remotePort)
      ..writeByte(3)
      ..write(obj.remoteHost)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.serverUuid)
      ..writeByte(6)
      ..write(obj.startOnConnect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PortForwardingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
