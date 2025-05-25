// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Schedule extends _Schedule
    with RealmEntity, RealmObjectBase, RealmObject {
  Schedule(ObjectId id, ObjectId doctorId, ObjectId serviceId, DateTime date) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'doctorId', doctorId);
    RealmObjectBase.set(this, 'serviceId', serviceId);
    RealmObjectBase.set(this, 'date', date);
  }

  Schedule._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  ObjectId get doctorId =>
      RealmObjectBase.get<ObjectId>(this, 'doctorId') as ObjectId;
  @override
  set doctorId(ObjectId value) => RealmObjectBase.set(this, 'doctorId', value);

  @override
  ObjectId get serviceId =>
      RealmObjectBase.get<ObjectId>(this, 'serviceId') as ObjectId;
  @override
  set serviceId(ObjectId value) =>
      RealmObjectBase.set(this, 'serviceId', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  Stream<RealmObjectChanges<Schedule>> get changes =>
      RealmObjectBase.getChanges<Schedule>(this);

  @override
  Stream<RealmObjectChanges<Schedule>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Schedule>(this, keyPaths);

  @override
  Schedule freeze() => RealmObjectBase.freezeObject<Schedule>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'doctorId': doctorId.toEJson(),
      'serviceId': serviceId.toEJson(),
      'date': date.toEJson(),
    };
  }

  static EJsonValue _toEJson(Schedule value) => value.toEJson();
  static Schedule _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'doctorId': EJsonValue doctorId,
        'serviceId': EJsonValue serviceId,
        'date': EJsonValue date,
      } =>
        Schedule(
          fromEJson(id),
          fromEJson(doctorId),
          fromEJson(serviceId),
          fromEJson(date),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Schedule._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Schedule, 'Schedule', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('doctorId', RealmPropertyType.objectid),
      SchemaProperty('serviceId', RealmPropertyType.objectid),
      SchemaProperty('date', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
