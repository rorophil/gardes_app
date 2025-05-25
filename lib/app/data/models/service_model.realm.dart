// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Service extends _Service with RealmEntity, RealmObjectBase, RealmObject {
  Service(
    ObjectId id,
    String nom,
    bool requiresAnesthesiste,
    bool requiresPediatrique,
    bool requiresSamu,
    bool requiresIntensiviste, {
    Iterable<String> joursBloquees = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'nom', nom);
    RealmObjectBase.set(this, 'requiresAnesthesiste', requiresAnesthesiste);
    RealmObjectBase.set(this, 'requiresPediatrique', requiresPediatrique);
    RealmObjectBase.set(this, 'requiresSamu', requiresSamu);
    RealmObjectBase.set(this, 'requiresIntensiviste', requiresIntensiviste);
    RealmObjectBase.set<RealmList<String>>(
      this,
      'joursBloquees',
      RealmList<String>(joursBloquees),
    );
  }

  Service._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get nom => RealmObjectBase.get<String>(this, 'nom') as String;
  @override
  set nom(String value) => RealmObjectBase.set(this, 'nom', value);

  @override
  bool get requiresAnesthesiste =>
      RealmObjectBase.get<bool>(this, 'requiresAnesthesiste') as bool;
  @override
  set requiresAnesthesiste(bool value) =>
      RealmObjectBase.set(this, 'requiresAnesthesiste', value);

  @override
  bool get requiresPediatrique =>
      RealmObjectBase.get<bool>(this, 'requiresPediatrique') as bool;
  @override
  set requiresPediatrique(bool value) =>
      RealmObjectBase.set(this, 'requiresPediatrique', value);

  @override
  bool get requiresSamu =>
      RealmObjectBase.get<bool>(this, 'requiresSamu') as bool;
  @override
  set requiresSamu(bool value) =>
      RealmObjectBase.set(this, 'requiresSamu', value);

  @override
  bool get requiresIntensiviste =>
      RealmObjectBase.get<bool>(this, 'requiresIntensiviste') as bool;
  @override
  set requiresIntensiviste(bool value) =>
      RealmObjectBase.set(this, 'requiresIntensiviste', value);

  @override
  RealmList<String> get joursBloquees =>
      RealmObjectBase.get<String>(this, 'joursBloquees') as RealmList<String>;
  @override
  set joursBloquees(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Service>> get changes =>
      RealmObjectBase.getChanges<Service>(this);

  @override
  Stream<RealmObjectChanges<Service>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Service>(this, keyPaths);

  @override
  Service freeze() => RealmObjectBase.freezeObject<Service>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'nom': nom.toEJson(),
      'requiresAnesthesiste': requiresAnesthesiste.toEJson(),
      'requiresPediatrique': requiresPediatrique.toEJson(),
      'requiresSamu': requiresSamu.toEJson(),
      'requiresIntensiviste': requiresIntensiviste.toEJson(),
      'joursBloquees': joursBloquees.toEJson(),
    };
  }

  static EJsonValue _toEJson(Service value) => value.toEJson();
  static Service _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'nom': EJsonValue nom,
        'requiresAnesthesiste': EJsonValue requiresAnesthesiste,
        'requiresPediatrique': EJsonValue requiresPediatrique,
        'requiresSamu': EJsonValue requiresSamu,
        'requiresIntensiviste': EJsonValue requiresIntensiviste,
      } =>
        Service(
          fromEJson(id),
          fromEJson(nom),
          fromEJson(requiresAnesthesiste),
          fromEJson(requiresPediatrique),
          fromEJson(requiresSamu),
          fromEJson(requiresIntensiviste),
          joursBloquees: fromEJson(ejson['joursBloquees']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Service._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Service, 'Service', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('nom', RealmPropertyType.string),
      SchemaProperty('requiresAnesthesiste', RealmPropertyType.bool),
      SchemaProperty('requiresPediatrique', RealmPropertyType.bool),
      SchemaProperty('requiresSamu', RealmPropertyType.bool),
      SchemaProperty('requiresIntensiviste', RealmPropertyType.bool),
      SchemaProperty(
        'joursBloquees',
        RealmPropertyType.string,
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
