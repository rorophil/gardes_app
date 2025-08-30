// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleHiveAdapter extends TypeAdapter<ScheduleHive> {
  @override
  final int typeId = 2;

  @override
  ScheduleHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleHive(
      id: fields[0] as String,
      doctorId: fields[1] as String,
      serviceId: fields[2] as String,
      dateMilliseconds: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.doctorId)
      ..writeByte(2)
      ..write(obj.serviceId)
      ..writeByte(3)
      ..write(obj.dateMilliseconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
