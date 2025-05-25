// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Doctor extends _Doctor with RealmEntity, RealmObjectBase, RealmObject {
  Doctor(
    ObjectId id,
    String nom,
    String prenom,
    String login,
    String password,
    bool isAnesthesiste,
    bool isPediatrique,
    bool isSamu,
    bool isIntensiviste,
    int maxGardesParMois,
    int joursMinEntreGardes, {
    Iterable<String> joursIndisponibles = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'nom', nom);
    RealmObjectBase.set(this, 'prenom', prenom);
    RealmObjectBase.set(this, 'login', login);
    RealmObjectBase.set(this, 'password', password);
    RealmObjectBase.set(this, 'isAnesthesiste', isAnesthesiste);
    RealmObjectBase.set(this, 'isPediatrique', isPediatrique);
    RealmObjectBase.set(this, 'isSamu', isSamu);
    RealmObjectBase.set(this, 'isIntensiviste', isIntensiviste);
    RealmObjectBase.set<RealmList<String>>(
      this,
      'joursIndisponibles',
      RealmList<String>(joursIndisponibles),
    );
    RealmObjectBase.set(this, 'maxGardesParMois', maxGardesParMois);
    RealmObjectBase.set(this, 'joursMinEntreGardes', joursMinEntreGardes);
  }

  Doctor._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get nom => RealmObjectBase.get<String>(this, 'nom') as String;
  @override
  set nom(String value) => RealmObjectBase.set(this, 'nom', value);

  @override
  String get prenom => RealmObjectBase.get<String>(this, 'prenom') as String;
  @override
  set prenom(String value) => RealmObjectBase.set(this, 'prenom', value);

  @override
  String get login => RealmObjectBase.get<String>(this, 'login') as String;
  @override
  set login(String value) => RealmObjectBase.set(this, 'login', value);

  @override
  String get password =>
      RealmObjectBase.get<String>(this, 'password') as String;
  @override
  set password(String value) => RealmObjectBase.set(this, 'password', value);

  @override
  bool get isAnesthesiste =>
      RealmObjectBase.get<bool>(this, 'isAnesthesiste') as bool;
  @override
  set isAnesthesiste(bool value) =>
      RealmObjectBase.set(this, 'isAnesthesiste', value);

  @override
  bool get isPediatrique =>
      RealmObjectBase.get<bool>(this, 'isPediatrique') as bool;
  @override
  set isPediatrique(bool value) =>
      RealmObjectBase.set(this, 'isPediatrique', value);

  @override
  bool get isSamu => RealmObjectBase.get<bool>(this, 'isSamu') as bool;
  @override
  set isSamu(bool value) => RealmObjectBase.set(this, 'isSamu', value);

  @override
  bool get isIntensiviste =>
      RealmObjectBase.get<bool>(this, 'isIntensiviste') as bool;
  @override
  set isIntensiviste(bool value) =>
      RealmObjectBase.set(this, 'isIntensiviste', value);

  @override
  RealmList<String> get joursIndisponibles =>
      RealmObjectBase.get<String>(this, 'joursIndisponibles')
          as RealmList<String>;
  @override
  set joursIndisponibles(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  int get maxGardesParMois =>
      RealmObjectBase.get<int>(this, 'maxGardesParMois') as int;
  @override
  set maxGardesParMois(int value) =>
      RealmObjectBase.set(this, 'maxGardesParMois', value);

  @override
  int get joursMinEntreGardes =>
      RealmObjectBase.get<int>(this, 'joursMinEntreGardes') as int;
  @override
  set joursMinEntreGardes(int value) =>
      RealmObjectBase.set(this, 'joursMinEntreGardes', value);

  @override
  Stream<RealmObjectChanges<Doctor>> get changes =>
      RealmObjectBase.getChanges<Doctor>(this);

  @override
  Stream<RealmObjectChanges<Doctor>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Doctor>(this, keyPaths);

  @override
  Doctor freeze() => RealmObjectBase.freezeObject<Doctor>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'nom': nom.toEJson(),
      'prenom': prenom.toEJson(),
      'login': login.toEJson(),
      'password': password.toEJson(),
      'isAnesthesiste': isAnesthesiste.toEJson(),
      'isPediatrique': isPediatrique.toEJson(),
      'isSamu': isSamu.toEJson(),
      'isIntensiviste': isIntensiviste.toEJson(),
      'joursIndisponibles': joursIndisponibles.toEJson(),
      'maxGardesParMois': maxGardesParMois.toEJson(),
      'joursMinEntreGardes': joursMinEntreGardes.toEJson(),
    };
  }

  static EJsonValue _toEJson(Doctor value) => value.toEJson();
  static Doctor _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'nom': EJsonValue nom,
        'prenom': EJsonValue prenom,
        'login': EJsonValue login,
        'password': EJsonValue password,
        'isAnesthesiste': EJsonValue isAnesthesiste,
        'isPediatrique': EJsonValue isPediatrique,
        'isSamu': EJsonValue isSamu,
        'isIntensiviste': EJsonValue isIntensiviste,
        'maxGardesParMois': EJsonValue maxGardesParMois,
        'joursMinEntreGardes': EJsonValue joursMinEntreGardes,
      } =>
        Doctor(
          fromEJson(id),
          fromEJson(nom),
          fromEJson(prenom),
          fromEJson(login),
          fromEJson(password),
          fromEJson(isAnesthesiste),
          fromEJson(isPediatrique),
          fromEJson(isSamu),
          fromEJson(isIntensiviste),
          fromEJson(maxGardesParMois),
          fromEJson(joursMinEntreGardes),
          joursIndisponibles: fromEJson(ejson['joursIndisponibles']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Doctor._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Doctor, 'Doctor', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('nom', RealmPropertyType.string),
      SchemaProperty('prenom', RealmPropertyType.string),
      SchemaProperty('login', RealmPropertyType.string),
      SchemaProperty('password', RealmPropertyType.string),
      SchemaProperty('isAnesthesiste', RealmPropertyType.bool),
      SchemaProperty('isPediatrique', RealmPropertyType.bool),
      SchemaProperty('isSamu', RealmPropertyType.bool),
      SchemaProperty('isIntensiviste', RealmPropertyType.bool),
      SchemaProperty(
        'joursIndisponibles',
        RealmPropertyType.string,
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('maxGardesParMois', RealmPropertyType.int),
      SchemaProperty('joursMinEntreGardes', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
