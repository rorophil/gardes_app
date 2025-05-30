import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_view_controller.dart';

// Mock classes for testing
class MockDatabaseService extends Mock implements DatabaseService {}

class MockScheduleService extends Mock implements ScheduleService {}

// Classe d'aide pour créer des objets Doctor pour les tests
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

  // RealmList spéciale pour les tests
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

  // Pour ajouter des jours indisponibles pour les tests
  void addUnavailableDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursIndisponibles.add(dateString);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Classe d'aide pour créer des objets Service pour les tests
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

  // RealmList spéciale pour les tests
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

  // Pour ajouter des jours bloqués pour les tests
  void addBlockedDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursBloquees.add(dateString);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockScheduleService mockScheduleService;
  late ScheduleViewController controller;

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

  final serviceUrgences = TestService(
    ObjectId(),
    'Urgences',
    false, // requiresAnesthesiste
    false, // requiresPediatrique
    true, // requiresSamu
    false, // requiresIntensiviste
  );

  final year = 2025;
  final month = 6;

  final schedules = [
    Schedule(
      ObjectId(),
      doctorAnesthesiste.id,
      serviceAnesthesie.id,
      DateTime(year, month, 10),
    ),
    Schedule(
      ObjectId(),
      doctorPediatrique.id,
      servicePediatrie.id,
      DateTime(year, month, 10),
    ),
    Schedule(
      ObjectId(),
      doctorPolyvalent.id,
      serviceUrgences.id,
      DateTime(year, month, 10),
    ),
    Schedule(
      ObjectId(),
      doctorAnesthesiste.id,
      serviceAnesthesie.id,
      DateTime(year, month, 15),
    ),
    Schedule(
      ObjectId(),
      doctorPediatrique.id,
      servicePediatrie.id,
      DateTime(year, month, 15),
    ),
    Schedule(
      ObjectId(),
      doctorPolyvalent.id,
      serviceUrgences.id,
      DateTime(year, month, 15),
    ),
  ];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockScheduleService = MockScheduleService();

    // Configurer les mocks
    when(
      mockDatabaseService.getAllServices(),
    ).thenReturn([serviceAnesthesie, servicePediatrie, serviceUrgences]);

    when(
      mockDatabaseService.getAllDoctors(),
    ).thenReturn([doctorAnesthesiste, doctorPediatrique, doctorPolyvalent]);

    when(
      mockDatabaseService.getSchedulesByService(serviceAnesthesie, year, month),
    ).thenReturn([
      schedules[0], // 10 juin
      schedules[3], // 15 juin
    ]);

    when(
      mockDatabaseService.getSchedulesByService(servicePediatrie, year, month),
    ).thenReturn([
      schedules[1], // 10 juin
      schedules[4], // 15 juin
    ]);

    when(
      mockDatabaseService.getSchedulesByService(serviceUrgences, year, month),
    ).thenReturn([
      schedules[2], // 10 juin
      schedules[5], // 15 juin
    ]);

    when(
      mockDatabaseService.getDoctor(doctorAnesthesiste.id),
    ).thenReturn(doctorAnesthesiste);
    when(
      mockDatabaseService.getDoctor(doctorPediatrique.id),
    ).thenReturn(doctorPediatrique);
    when(
      mockDatabaseService.getDoctor(doctorPolyvalent.id),
    ).thenReturn(doctorPolyvalent);

    // Enregistrer les mocks avec Get.put pour qu'ils soient disponibles via Get.find
    Get.put<DatabaseService>(mockDatabaseService);
    Get.put<ScheduleService>(mockScheduleService);

    // Initialiser le contrôleur
    controller = ScheduleViewController();

    // Configurer manuellement les valeurs du contrôleur pour les tests
    controller.selectedYear.value = year;
    controller.selectedMonth.value = month;
    controller.services.value = [
      serviceAnesthesie,
      servicePediatrie,
      serviceUrgences,
    ];
    controller.displayedServices.value = [serviceAnesthesie, servicePediatrie];
  });

  tearDown(() {
    Get.reset();
  });

  group('Tests du ScheduleViewController', () {
    test('devrait charger correctement les plannings', () async {
      // Act
      await controller.loadSchedules();

      // Assert
      verify(
        mockDatabaseService.getSchedulesByService(
          serviceAnesthesie,
          year,
          month,
        ),
      ).called(1);
      verify(
        mockDatabaseService.getSchedulesByService(
          servicePediatrie,
          year,
          month,
        ),
      ).called(1);
      expect(
        controller.schedulesByService.value.length,
        2,
      ); // Pour les deux services affichés
      expect(
        controller.schedulesByService.value.containsKey(serviceAnesthesie.id),
        isTrue,
      );
      expect(
        controller.schedulesByService.value.containsKey(servicePediatrie.id),
        isTrue,
      );
      expect(
        controller.schedulesByService.value[serviceAnesthesie.id]?.length,
        2,
      );
      expect(
        controller.schedulesByService.value[servicePediatrie.id]?.length,
        2,
      );
    });

    test(
      'devrait filtrer les médecins disponibles pour les services affichés',
      () {
        // Act
        controller.loadAvailableDoctors();

        // Assert
        expect(controller.availableDoctors.length, 2);
        expect(
          controller.availableDoctors.contains(doctorAnesthesiste),
          isTrue,
        );
        expect(controller.availableDoctors.contains(doctorPediatrique), isTrue);
        expect(controller.availableDoctors.contains(doctorPolyvalent), isTrue);
      },
    );

    test(
      'devrait déterminer correctement si un médecin peut travailler dans un service',
      () {
        // Assert
        expect(
          controller._canDoctorWorkInService(
            doctorAnesthesiste,
            serviceAnesthesie,
          ),
          isTrue,
        );
        expect(
          controller._canDoctorWorkInService(
            doctorAnesthesiste,
            servicePediatrie,
          ),
          isFalse,
        );
        expect(
          controller._canDoctorWorkInService(
            doctorPediatrique,
            servicePediatrie,
          ),
          isTrue,
        );
        expect(
          controller._canDoctorWorkInService(
            doctorPediatrique,
            serviceAnesthesie,
          ),
          isFalse,
        );
        expect(
          controller._canDoctorWorkInService(
            doctorPolyvalent,
            serviceAnesthesie,
          ),
          isTrue,
        );
        expect(
          controller._canDoctorWorkInService(
            doctorPolyvalent,
            servicePediatrie,
          ),
          isTrue,
        );
        expect(
          controller._canDoctorWorkInService(doctorPolyvalent, serviceUrgences),
          isTrue,
        );
      },
    );

    test(
      'devrait trouver correctement un planning pour un jour spécifique',
      () {
        // Arrange
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [
            schedules[0], // 10 juin
            schedules[3], // 15 juin
          ],
        };

        // Assert
        expect(
          controller.getScheduleForDay(serviceAnesthesie, 10),
          equals(schedules[0]),
        );
        expect(
          controller.getScheduleForDay(serviceAnesthesie, 15),
          equals(schedules[3]),
        );
        expect(controller.getScheduleForDay(serviceAnesthesie, 20), isNull);
      },
    );

    test('devrait mettre à jour les services affichés', () {
      // Act
      controller.changeDisplayedServices([serviceUrgences]);

      // Assert
      verify(
        mockDatabaseService.getSchedulesByService(serviceUrgences, year, month),
      ).called(1);
      expect(controller.displayedServices.length, 1);
      expect(controller.displayedServices[0], equals(serviceUrgences));
    });

    test('devrait changer le mois et l\'année et recharger les plannings', () {
      // Act
      controller.changeMonth(2026, 7);

      // Assert
      expect(controller.selectedYear.value, 2026);
      expect(controller.selectedMonth.value, 7);
      verify(
        mockDatabaseService.getSchedulesByService(serviceAnesthesie, 2026, 7),
      ).called(1);
      verify(
        mockDatabaseService.getSchedulesByService(servicePediatrie, 2026, 7),
      ).called(1);
    });

    test('devrait démarrer correctement un drag de docteur', () {
      // Act
      controller.startDragDoctor(doctorAnesthesiste);

      // Assert
      expect(controller.draggedDoctor.value, equals(doctorAnesthesiste));
    });

    test('devrait démarrer correctement un drag de planning', () {
      // Act
      controller.startDragSchedule(schedules[0]);

      // Assert
      expect(controller.draggedSchedule.value, equals(schedules[0]));
    });

    test('devrait terminer correctement un drag', () {
      // Arrange
      controller.draggedDoctor.value = doctorAnesthesiste;
      controller.draggedSchedule.value = schedules[0];

      // Act
      controller.endDrag();

      // Assert
      expect(controller.draggedDoctor.value, isNull);
      expect(controller.draggedSchedule.value, isNull);
    });

    test(
      'acceptScheduleDrop devrait vérifier correctement si un drop de planning est possible',
      () {
        // Arrange
        final sourceSchedule = schedules[0]; // 10 juin anesthesie
        controller.draggedSchedule.value = sourceSchedule;

        // Ajouter le schedule dans le map pour qu'il puisse être trouvé par getScheduleForDay
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [schedules[0], schedules[3]],
          servicePediatrie.id: [schedules[1], schedules[4]],
        };

        // Tests
        // Target existe: Jour 15, service anesthésie
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 15), isTrue);

        // Target n'existe pas: Jour 20, service anesthésie
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 20), isFalse);

        // Pas de schedule en train d'être déplacé
        controller.draggedSchedule.value = null;
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 15), isFalse);
      },
    );

    test(
      'completeScheduleDrop devrait échanger les médecins entre plannings correctement',
      () {
        // Arrange
        final sourceSchedule = schedules[0]; // 10 juin anesthesie
        final targetSchedule = schedules[3]; // 15 juin anesthesie
        controller.draggedSchedule.value = sourceSchedule;

        // Ajouter les schedules dans le map pour qu'ils puissent être trouvés par getScheduleForDay
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [sourceSchedule, targetSchedule],
        };

        // Act
        controller.completeScheduleDrop(serviceAnesthesie, 15);

        // Assert
        verify(
          mockScheduleService.swapDoctors(sourceSchedule, targetSchedule),
        ).called(1);
        expect(controller.draggedSchedule.value, isNull); // Drag terminé
      },
    );

    test(
      'acceptDoctorDrop devrait vérifier correctement si un drop de médecin est possible',
      () {
        // Arrange
        controller.draggedDoctor.value = doctorAnesthesiste;

        // Ajouter le schedule dans le map pour qu'il puisse être trouvé par getScheduleForDay
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [schedules[0], schedules[3]],
        };

        // Tests
        // Médecin compatible, jour avec planning
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 15), isTrue);

        // Médecin incompatible
        controller.draggedDoctor.value = doctorPediatrique;
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 15), isFalse);

        // Jour sans planning
        controller.draggedDoctor.value = doctorAnesthesiste;
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 20), isFalse);

        // Pas de médecin en train d'être déplacé
        controller.draggedDoctor.value = null;
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 15), isFalse);
      },
    );

    test(
      'completeDoctorDrop devrait changer le médecin dans un planning correctement',
      () {
        // Arrange
        controller.draggedDoctor.value = doctorAnesthesiste;
        final targetSchedule = schedules[3]; // 15 juin anesthesie

        // Ajouter le schedule dans le map pour qu'il puisse être trouvé par getScheduleForDay
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [schedules[0], targetSchedule],
        };

        // Act
        controller.completeDoctorDrop(serviceAnesthesie, 15);

        // Assert
        verify(
          mockScheduleService.changeDoctor(targetSchedule, doctorAnesthesiste),
        ).called(1);
        expect(controller.draggedDoctor.value, isNull); // Drag terminé
      },
    );

    test('devrait formater correctement les noms de mois', () {
      // Assert
      expect(controller.getMonthName(1), equals('Janvier'));
      expect(controller.getMonthName(4), equals('Avril'));
      expect(controller.getMonthName(8), equals('Août'));
      expect(controller.getMonthName(12), equals('Décembre'));
    });

    test('devrait formater correctement les noms de jours', () {
      // Arrange - en juin 2025
      controller.selectedYear.value = 2025;
      controller.selectedMonth.value = 6;

      // Assert - en juin 2025, le 1er est un dimanche
      expect(controller.getDayOfWeek(1), equals('Dim'));
      expect(controller.getDayOfWeek(2), equals('Lun'));
      expect(controller.getDayOfWeek(7), equals('Sam'));
    });
  });
}
