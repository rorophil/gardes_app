// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceHiveAdapter extends TypeAdapter<ServiceHive> {
  @override
  final int typeId = 1;

  @override
  ServiceHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceHive(
      id: fields[0] as String,
      nom: fields[1] as String,
      requiresAnesthesiste: fields[2] as bool,
      requiresPediatrique: fields[3] as bool,
      requiresSamu: fields[4] as bool,
      requiresIntensiviste: fields[5] as bool,
      joursBloquees: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.requiresAnesthesiste)
      ..writeByte(3)
      ..write(obj.requiresPediatrique)
      ..writeByte(4)
      ..write(obj.requiresSamu)
      ..writeByte(5)
      ..write(obj.requiresIntensiviste)
      ..writeByte(6)
      ..write(obj.joursBloquees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
