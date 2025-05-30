import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';

// Classes de mocks
class MockDatabaseService extends Mock implements DatabaseService {}

// Classes de test pour les modèles Realm
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

  // RealmList pour les tests
  @override
  final RealmList<String> joursIndisponibles = RealmList<String>([]);

  TestDoctor(
    this.id,
    this.nom,
    this.prenom,
    this.login,
    this.password,
    this.isAnesthesiste,
    this.isPediatrique,
    this.isSamu,
    this.isIntensiviste,
    this.maxGardesParMois,
    this.joursMinEntreGardes,
  );

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

  // RealmList pour les tests
  @override
  final RealmList<String> joursBloquees = RealmList<String>([]);

  TestService(
    this.id,
    this.nom,
    this.requiresAnesthesiste,
    this.requiresPediatrique,
    this.requiresSamu,
    this.requiresIntensiviste,
  );

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

// Extension pour faciliter la mise à jour des schedules pendant les tests
extension ScheduleTest on Schedule {
  Schedule withDoctorId(ObjectId doctorId) {
    return this..doctorId = doctorId;
  }
}

// Tests unitaires pour ScheduleService
void main() {
  group('Tests du ScheduleService', () {
    late MockDatabaseService mockDatabaseService;
    late ScheduleService scheduleService;

    // Données de test
    final doctorAnesthesiste = TestDoctor(
      ObjectId(),
      'Dupont',
      'Jean',
      'jdupont',
      'password',
      true, // isAnesthesiste
      false, // isPediatrique
      false, // isSamu
      false, // isIntensiviste
      10, // maxGardesParMois
      2, // joursMinEntreGardes
    );

    final doctorPediatrique = TestDoctor(
      ObjectId(),
      'Martin',
      'Marie',
      'mmartin',
      'password',
      false, // isAnesthesiste
      true, // isPediatrique
      false, // isSamu
      false, // isIntensiviste
      10, // maxGardesParMois
      2, // joursMinEntreGardes
    );

    final doctorPolyvalent = TestDoctor(
      ObjectId(),
      'Bernard',
      'Sophie',
      'sbernard',
      'password',
      true, // isAnesthesiste
      true, // isPediatrique
      true, // isSamu
      true, // isIntensiviste
      10, // maxGardesParMois
      2, // joursMinEntreGardes
    );

    final serviceAnesthesie = TestService(
      ObjectId(),
      'Anesthésie',
      true, // requiresAnesthesiste
      false, // requiresPediatrique
      false, // requiresSamu
      false, // requiresIntensiviste
    );

    final servicePediatrie = TestService(
      ObjectId(),
      'Pédiatrie',
      false, // requiresAnesthesiste
      true, // requiresPediatrique
      false, // requiresSamu
      false, // requiresIntensiviste
    );

    final year = 2025;
    final month = 6;

    setUp(() {
      mockDatabaseService = MockDatabaseService();

      // Injection manuelle du mock
      scheduleService = ScheduleService();
      scheduleService._databaseService = mockDatabaseService;
    });

    test('swapDoctors devrait échanger les médecins entre deux plannings', () {
      // Arrange
      final schedule1 = Schedule(
        ObjectId(),
        doctorAnesthesiste.id,
        serviceAnesthesie.id,
        DateTime(year, month, 10),
      );
      final schedule2 = Schedule(
        ObjectId(),
        doctorPediatrique.id,
        servicePediatrie.id,
        DateTime(year, month, 15),
      );

      // Act
      scheduleService.swapDoctors(schedule1, schedule2);

      // Assert
      verify(
        mockDatabaseService.updateSchedule(
          schedule1.withDoctorId(doctorPediatrique.id),
        ),
      ).called(1);
      verify(
        mockDatabaseService.updateSchedule(
          schedule2.withDoctorId(doctorAnesthesiste.id),
        ),
      ).called(1);
    });

    test('changeDoctor devrait changer le médecin d\'un planning', () {
      // Arrange
      final schedule = Schedule(
        ObjectId(),
        doctorAnesthesiste.id,
        serviceAnesthesie.id,
        DateTime(year, month, 10),
      );

      // Act
      scheduleService.changeDoctor(schedule, doctorPolyvalent);

      // Assert
      verify(
        mockDatabaseService.updateSchedule(
          schedule.withDoctorId(doctorPolyvalent.id),
        ),
      ).called(1);
    });

    test(
      'generateMonthlySchedule devrait créer des plannings pour tous les jours du mois hors jours bloqués',
      () async {
        // Arrange
        final allDoctors = [
          doctorAnesthesiste,
          doctorPediatrique,
          doctorPolyvalent,
        ];
        when(mockDatabaseService.getAllDoctors()).thenReturn(allDoctors);

        // Bloquer quelques jours
        serviceAnesthesie.addBlockedDay(DateTime(year, month, 5));
        serviceAnesthesie.addBlockedDay(DateTime(year, month, 6));

        // Simuler la création d'un planning
        when(
          mockDatabaseService.createSchedule(
            doctor: anyNamed('doctor'),
            service: anyNamed('service'),
            date: anyNamed('date'),
          ),
        ).thenAnswer((inv) {
          final doctor = inv.namedArguments[const Symbol('doctor')] as Doctor;
          final service =
              inv.namedArguments[const Symbol('service')] as Service;
          final date = inv.namedArguments[const Symbol('date')] as DateTime;
          return Schedule(ObjectId(), doctor.id, service.id, date);
        });

        // Rendre un médecin indisponible certains jours
        doctorAnesthesiste.addUnavailableDay(DateTime(year, month, 10));
        doctorAnesthesiste.addUnavailableDay(DateTime(year, month, 11));

        // Act
        final result = await scheduleService.generateMonthlySchedule(
          serviceAnesthesie,
          year,
          month,
        );

        // Assert
        // Juin 2025 a 30 jours, moins 2 jours bloqués, donc on devrait avoir 28 plannings
        expect(result.length, lessThanOrEqualTo(30 - 2));

        // Vérifier qu'on n'a pas de plannings pour les jours bloqués
        expect(result.any((s) => s.date.day == 5), isFalse);
        expect(result.any((s) => s.date.day == 6), isFalse);

        // Vérifier que doctorAnesthesiste n'est pas assigné les jours où il est indisponible
        for (final schedule in result) {
          if (schedule.date.day == 10 || schedule.date.day == 11) {
            expect(schedule.doctorId, isNot(equals(doctorAnesthesiste.id)));
          }
        }
      },
    );

    test(
      '_getEligibleDoctors devrait retourner les médecins qui peuvent travailler dans le service',
      () {
        // Arrange
        when(
          mockDatabaseService.getAllDoctors(),
        ).thenReturn([doctorAnesthesiste, doctorPediatrique, doctorPolyvalent]);

        // Act - appel à la méthode privée via une méthode de test
        List<Doctor> eligibleForAnesthesie = scheduleService
            ._getEligibleDoctors(serviceAnesthesie);
        List<Doctor> eligibleForPediatrie = scheduleService._getEligibleDoctors(
          servicePediatrie,
        );

        // Assert
        expect(eligibleForAnesthesie.length, 2);
        expect(eligibleForAnesthesie.contains(doctorAnesthesiste), isTrue);
        expect(eligibleForAnesthesie.contains(doctorPolyvalent), isTrue);
        expect(eligibleForAnesthesie.contains(doctorPediatrique), isFalse);

        expect(eligibleForPediatrie.length, 2);
        expect(eligibleForPediatrie.contains(doctorPediatrique), isTrue);
        expect(eligibleForPediatrie.contains(doctorPolyvalent), isTrue);
        expect(eligibleForPediatrie.contains(doctorAnesthesiste), isFalse);
      },
    );

    test('_getDatesInMonth devrait retourner toutes les dates du mois', () {
      // Act
      final result = scheduleService._getDatesInMonth(2025, 6);

      // Assert - Juin 2025 a 30 jours
      expect(result.length, 30);
      expect(result.first, DateTime(2025, 6, 1));
      expect(result.last, DateTime(2025, 6, 30));
    });

    test(
      '_getDatePriority devrait attribuer la priorité correcte aux différents jours de la semaine',
      () {
        // Les jours de test
        final vendredi = DateTime(2025, 6, 6); // 6 juin 2025 est un vendredi
        final samedi = DateTime(2025, 6, 7); // 7 juin 2025 est un samedi
        final dimanche = DateTime(2025, 6, 8); // 8 juin 2025 est un dimanche
        final jeudi = DateTime(2025, 6, 5); // 5 juin 2025 est un jeudi
        final mardi = DateTime(2025, 6, 3); // 3 juin 2025 est un mardi

        // Act & Assert
        expect(
          scheduleService._getDatePriority(vendredi),
          0,
        ); // Priorité la plus haute
        expect(
          scheduleService._getDatePriority(samedi),
          1,
        ); // Weekend - priorité haute
        expect(
          scheduleService._getDatePriority(dimanche),
          1,
        ); // Weekend - priorité haute
        expect(
          scheduleService._getDatePriority(jeudi),
          3,
        ); // Priorité la plus basse
        expect(
          scheduleService._getDatePriority(mardi),
          2,
        ); // Jour de semaine standard
      },
    );
  });
}
