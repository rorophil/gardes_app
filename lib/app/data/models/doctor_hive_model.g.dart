// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoctorHiveAdapter extends TypeAdapter<DoctorHive> {
  @override
  final int typeId = 0;

  @override
  DoctorHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoctorHive(
      id: fields[0] as String,
      nom: fields[1] as String,
      prenom: fields[2] as String,
      login: fields[3] as String,
      password: fields[4] as String,
      isAnesthesiste: fields[5] as bool,
      isPediatrique: fields[6] as bool,
      isSamu: fields[7] as bool,
      isIntensiviste: fields[8] as bool,
      joursIndisponibles: (fields[9] as List).cast<String>(),
      maxGardesParMois: fields[10] as int,
      joursMinEntreGardes: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DoctorHive obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.prenom)
      ..writeByte(3)
      ..write(obj.login)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.isAnesthesiste)
      ..writeByte(6)
      ..write(obj.isPediatrique)
      ..writeByte(7)
      ..write(obj.isSamu)
      ..writeByte(8)
      ..write(obj.isIntensiviste)
      ..writeByte(9)
      ..write(obj.joursIndisponibles)
      ..writeByte(10)
      ..write(obj.maxGardesParMois)
      ..writeByte(11)
      ..write(obj.joursMinEntreGardes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
