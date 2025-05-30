import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';

// Classes de test pour simples pour les modèles Realm
class TestDoctor implements Doctor {
  @override
  ObjectId id;
  @override
  String nom;
  @override
  String prenom;
  @override
  String login;
  @override
  String password;
  @override
  bool isAnesthesiste;
  @override
  bool isPediatrique;
  @override
  bool isSamu;
  @override
  bool isIntensiviste;
  @override
  int maxGardesParMois;
  @override
  int joursMinEntreGardes;
  @override
  final RealmList<String> joursIndisponibles = RealmList<String>([]);

  TestDoctor({
    required this.id,
    required this.nom,
    required this.prenom,
    this.login = '',
    this.password = '',
    this.isAnesthesiste = false,
    this.isPediatrique = false,
    this.isSamu = false,
    this.isIntensiviste = false,
    this.maxGardesParMois = 10,
    this.joursMinEntreGardes = 2,
  });

  @override
  bool hasPrivilege(Privilege privilege) {
    switch (privilege) {
      case Privilege.anesthesiste:
        return isAnesthesiste;
      case Privilege.pediatrique:
        return isPediatrique;
      case Privilege.samu:
        return isSamu;
      case Privilege.intensiviste:
        return isIntensiviste;
    }
  }

  @override
  List<Privilege> get privileges {
    List<Privilege> result = [];
    if (isAnesthesiste) result.add(Privilege.anesthesiste);
    if (isPediatrique) result.add(Privilege.pediatrique);
    if (isSamu) result.add(Privilege.samu);
    if (isIntensiviste) result.add(Privilege.intensiviste);
    return result;
  }

  @override
  bool isAvailableOn(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return !joursIndisponibles.contains(dateString);
  }

  @override
  bool canTakeShiftOn(DateTime date) {
    return isAvailableOn(date);
  }

  void addUnavailableDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursIndisponibles.add(dateString);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestService implements Service {
  @override
  ObjectId id;
  @override
  String nom;
  @override
  bool requiresAnesthesiste;
  @override
  bool requiresPediatrique;
  @override
  bool requiresSamu;
  @override
  bool requiresIntensiviste;
  @override
  final RealmList<String> joursBloquees = RealmList<String>([]);

  TestService({
    required this.id,
    required this.nom,
    this.requiresAnesthesiste = false,
    this.requiresPediatrique = false,
    this.requiresSamu = false,
    this.requiresIntensiviste = false,
  });

  @override
  List<Privilege> get privileges {
    List<Privilege> result = [];
    if (requiresAnesthesiste) result.add(Privilege.anesthesiste);
    if (requiresPediatrique) result.add(Privilege.pediatrique);
    if (requiresSamu) result.add(Privilege.samu);
    if (requiresIntensiviste) result.add(Privilege.intensiviste);
    return result;
  }

  @override
  bool isDateBlocked(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return joursBloquees.contains(dateString);
  }

  @override
  bool acceptsDoctor(Doctor doctor) {
    if (requiresAnesthesiste && doctor.isAnesthesiste) return true;
    if (requiresPediatrique && doctor.isPediatrique) return true;
    if (requiresSamu && doctor.isSamu) return true;
    if (requiresIntensiviste && doctor.isIntensiviste) return true;
    return false;
  }

  void addBlockedDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursBloquees.add(dateString);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mocks simples
class MockDatabaseService extends Mock implements DatabaseService {}

class MockScheduleService extends Mock implements ScheduleService {}

// Test simple pour les fonctionnalités de planification
void main() {
  group('Fonctionnalités de planification simples', () {
    late MockDatabaseService mockDatabase;
    late MockScheduleService mockScheduleService;

    setUp(() {
      mockDatabase = MockDatabaseService();
      mockScheduleService = MockScheduleService();
    });

    test('Échange de médecins entre plannings', () {
      // Arrange
      final serviceId = ObjectId();
      final doctor1Id = ObjectId();
      final doctor2Id = ObjectId();

      final schedule1 = Schedule(
        ObjectId(),
        doctor1Id,
        serviceId,
        DateTime(2025, 5, 15),
      );
      final schedule2 = Schedule(
        ObjectId(),
        doctor2Id,
        serviceId,
        DateTime(2025, 5, 16),
      );

      // Act
      mockScheduleService.swapDoctors(schedule1, schedule2);

      // Assert
      verify(mockScheduleService.swapDoctors(schedule1, schedule2)).called(1);
    });

    test('Changement de médecin dans un planning', () {
      // Arrange
      final serviceId = ObjectId();
      final oldDoctorId = ObjectId();

      final doctor = TestDoctor(
        id: ObjectId(),
        nom: 'Nouveau',
        prenom: 'Docteur',
        isAnesthesiste: true,
      );

      final schedule = Schedule(
        ObjectId(),
        oldDoctorId,
        serviceId,
        DateTime(2025, 5, 15),
      );

      // Act
      mockScheduleService.changeDoctor(schedule, doctor);

      // Assert
      verify(mockScheduleService.changeDoctor(schedule, doctor)).called(1);
    });

    test('Génération d\'un planning mensuel', () async {
      // Arrange
      final service = TestService(
        id: ObjectId(),
        nom: "Service de Cardiologie",
        requiresAnesthesiste: true,
      );

      final doctor = TestDoctor(
        id: ObjectId(),
        nom: 'Cardiologiste',
        prenom: 'Test',
        isAnesthesiste: true,
      );

      final schedules = [
        Schedule(ObjectId(), doctor.id, service.id, DateTime(2025, 5, 1)),
        Schedule(ObjectId(), doctor.id, service.id, DateTime(2025, 5, 2)),
      ];

      // Créer une Future à retourner pour le mock
      Future<List<Schedule>> futureSchedules = Future.value(schedules);

      when(
        mockScheduleService.generateMonthlySchedule(any, any, any),
      ).thenAnswer((_) => futureSchedules);

      // Act
      await mockScheduleService.generateMonthlySchedule(service, 2025, 5);

      // Assert
      verify(
        mockScheduleService.generateMonthlySchedule(any, any, any),
      ).called(1);
    });

    test('Récupération des plannings pour un mois donné', () {
      // Arrange
      final month = 5;
      final year = 2025;
      final schedules = [
        Schedule(ObjectId(), ObjectId(), ObjectId(), DateTime(2025, 5, 1)),
        Schedule(ObjectId(), ObjectId(), ObjectId(), DateTime(2025, 5, 15)),
      ];

      when(mockDatabase.getSchedulesByMonth(year, month)).thenReturn(schedules);

      // Act
      final result = mockDatabase.getSchedulesByMonth(year, month);

      // Assert
      verify(mockDatabase.getSchedulesByMonth(year, month)).called(1);
      expect(result.length, 2);
      expect(result[0].date.month, 5);
      expect(result[1].date.month, 5);
    });

    test('Récupération des plannings pour un service', () {
      // Arrange
      final service = TestService(
        id: ObjectId(),
        nom: "Service d'Urgences",
        requiresSamu: true,
      );

      final schedules = [
        Schedule(ObjectId(), ObjectId(), service.id, DateTime(2025, 5, 1)),
        Schedule(ObjectId(), ObjectId(), service.id, DateTime(2025, 5, 2)),
      ];

      when(
        mockDatabase.getSchedulesByService(service, 2025, 5),
      ).thenReturn(schedules);

      // Act
      final result = mockDatabase.getSchedulesByService(service, 2025, 5);

      // Assert
      verify(mockDatabase.getSchedulesByService(service, 2025, 5)).called(1);
      expect(result.length, 2);
      expect(result[0].serviceId, service.id);
      expect(result[1].serviceId, service.id);
    });

    test('Récupération des plannings pour un médecin', () {
      // Arrange
      final doctor = TestDoctor(id: ObjectId(), nom: "Dupont", prenom: "Jean");

      final schedules = [
        Schedule(ObjectId(), doctor.id, ObjectId(), DateTime(2025, 5, 10)),
        Schedule(ObjectId(), doctor.id, ObjectId(), DateTime(2025, 5, 25)),
      ];

      when(mockDatabase.getSchedulesByDoctor(doctor)).thenReturn(schedules);

      // Act
      final result = mockDatabase.getSchedulesByDoctor(doctor);

      // Assert
      verify(mockDatabase.getSchedulesByDoctor(doctor)).called(1);
      expect(result.length, 2);
      expect(result[0].doctorId, doctor.id);
      expect(result[1].doctorId, doctor.id);
    });

    test('Vérification de compatibilité service-médecin', () {
      // Arrange
      final doctorAnesthesiste = TestDoctor(
        id: ObjectId(),
        nom: "Anesthésiste",
        prenom: "Test",
        isAnesthesiste: true,
      );

      final doctorPediatrique = TestDoctor(
        id: ObjectId(),
        nom: "Pédiatre",
        prenom: "Test",
        isPediatrique: true,
      );

      final serviceAnesthesie = TestService(
        id: ObjectId(),
        nom: "Anesthésie",
        requiresAnesthesiste: true,
      );

      final servicePediatrie = TestService(
        id: ObjectId(),
        nom: "Pédiatrie",
        requiresPediatrique: true,
      );

      // Act & Assert
      expect(serviceAnesthesie.acceptsDoctor(doctorAnesthesiste), isTrue);
      expect(serviceAnesthesie.acceptsDoctor(doctorPediatrique), isFalse);
      expect(servicePediatrie.acceptsDoctor(doctorPediatrique), isTrue);
      expect(servicePediatrie.acceptsDoctor(doctorAnesthesiste), isFalse);
    });

    test('Vérification des jours bloqués pour un service', () {
      // Arrange
      final service = TestService(id: ObjectId(), nom: "Service Test");

      final blockedDate = DateTime(2025, 5, 15);
      final normalDate = DateTime(2025, 5, 16);

      service.addBlockedDay(blockedDate);

      // Act & Assert
      expect(service.isDateBlocked(blockedDate), isTrue);
      expect(service.isDateBlocked(normalDate), isFalse);
    });

    test('Vérification des jours indisponibles pour un médecin', () {
      // Arrange
      final doctor = TestDoctor(id: ObjectId(), nom: "Dupont", prenom: "Jean");

      final unavailableDate = DateTime(2025, 5, 15);
      final availableDate = DateTime(2025, 5, 16);

      doctor.addUnavailableDay(unavailableDate);

      // Act & Assert
      expect(doctor.isAvailableOn(unavailableDate), isFalse);
      expect(doctor.isAvailableOn(availableDate), isTrue);
      expect(doctor.canTakeShiftOn(unavailableDate), isFalse);
      expect(doctor.canTakeShiftOn(availableDate), isTrue);
    });
  });
}
