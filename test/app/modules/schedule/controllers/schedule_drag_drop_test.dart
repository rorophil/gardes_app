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

// Mocks
class MockDatabaseService extends Mock implements DatabaseService {}

class MockScheduleService extends Mock implements ScheduleService {}

// Extension pour les tests avec Schedule
extension ScheduleTest on Schedule {
  Schedule withDoctorId(ObjectId doctorId) {
    return Schedule(this.id, doctorId, this.serviceId, this.date);
  }
}

// Classes de test pour les objets Realm
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
    String dateString = _formatDateToString(date);
    return !joursIndisponibles.contains(dateString);
  }

  @override
  bool canTakeShiftOn(DateTime date) {
    return isAvailableOn(date);
  }

  void addUnavailableDay(DateTime date) {
    joursIndisponibles.add(_formatDateToString(date));
  }

  String _formatDateToString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
    String dateString = _formatDateToString(date);
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
    joursBloquees.add(_formatDateToString(date));
  }

  String _formatDateToString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Tests Drag-and-Drop du ScheduleViewController', () {
    late MockDatabaseService mockDatabaseService;
    late MockScheduleService mockScheduleService;
    late ScheduleViewController controller;

    // Données de test
    final doctor1 = TestDoctor(
      id: ObjectId(),
      nom: 'Dupont',
      prenom: 'Jean',
      isAnesthesiste: true,
    );

    final doctor2 = TestDoctor(
      id: ObjectId(),
      nom: 'Martin',
      prenom: 'Marie',
      isPediatrique: true,
    );

    final doctor3 = TestDoctor(
      id: ObjectId(),
      nom: 'Bernard',
      prenom: 'Sophie',
      isAnesthesiste: true,
      isPediatrique: true,
      isSamu: true,
    );

    final serviceAnesthesie = TestService(
      id: ObjectId(),
      nom: 'Anesthésie',
      requiresAnesthesiste: true,
    );

    final servicePediatrie = TestService(
      id: ObjectId(),
      nom: 'Pédiatrie',
      requiresPediatrique: true,
    );

    final year = 2025;
    final month = 6;

    // Créer des plannings pour les tests
    Schedule createSchedule(ObjectId doctorId, ObjectId serviceId, int day) {
      return Schedule()
        ..id = ObjectId()
        ..doctorId = doctorId
        ..serviceId = serviceId
        ..date = DateTime(year, month, day);
    }

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockScheduleService = MockScheduleService();

      // Enregistrer les mocks avec Get.put
      Get.put<DatabaseService>(mockDatabaseService);
      Get.put<ScheduleService>(mockScheduleService);

      // Initialiser le contrôleur
      controller = ScheduleViewController();

      // Configurer le contrôleur
      controller.selectedYear.value = year;
      controller.selectedMonth.value = month;
      controller.services.value = [serviceAnesthesie, servicePediatrie];
      controller.displayedServices.value = [
        serviceAnesthesie,
        servicePediatrie,
      ];
      controller.availableDoctors.value = [doctor1, doctor2, doctor3];

      // Mock des méthodes du service utilisées par le contrôleur
      when(mockDatabaseService.getDoctor(doctor1.id)).thenReturn(doctor1);
      when(mockDatabaseService.getDoctor(doctor2.id)).thenReturn(doctor2);
      when(mockDatabaseService.getDoctor(doctor3.id)).thenReturn(doctor3);
    });

    tearDown(() {
      Get.reset();
    });

    group('Déplacement de médecin (Drag-and-Drop)', () {
      test('startDragDoctor devrait initialiser draggedDoctor', () {
        // Act
        controller.startDragDoctor(doctor1);

        // Assert
        expect(controller.draggedDoctor.value, equals(doctor1));
      });

      test(
        'endDrag devrait réinitialiser draggedDoctor et draggedSchedule',
        () {
          // Arrange
          controller.draggedDoctor.value = doctor1;
          controller.draggedSchedule.value = createSchedule(
            doctor1.id,
            serviceAnesthesie.id,
            10,
          );

          // Act
          controller.endDrag();

          // Assert
          expect(controller.draggedDoctor.value, isNull);
          expect(controller.draggedSchedule.value, isNull);
        },
      );

      test('acceptDoctorDrop devrait vérifier les conditions requises', () {
        // Arrange
        controller.draggedDoctor.value = doctor1; // Anesthésiste

        // Créer des plannings de test
        final schedule1 = createSchedule(doctor2.id, serviceAnesthesie.id, 10);
        final schedule2 = createSchedule(doctor3.id, servicePediatrie.id, 10);

        // Configurer le schedulesByService pour les tests
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [schedule1],
          servicePediatrie.id: [schedule2],
        };

        // Act & Assert
        // Un anesthésiste peut remplacer dans le service d'anesthésie
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 10), isTrue);

        // Mais pas dans le service de pédiatrie
        expect(controller.acceptDoctorDrop(servicePediatrie, 10), isFalse);

        // Changer pour un médecin qui peut travailler dans les deux services
        controller.draggedDoctor.value = doctor3;
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 10), isTrue);
        expect(controller.acceptDoctorDrop(servicePediatrie, 10), isTrue);

        // Jour sans planning
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 15), isFalse);

        // Pas de médecin sélectionné
        controller.draggedDoctor.value = null;
        expect(controller.acceptDoctorDrop(serviceAnesthesie, 10), isFalse);
      });

      test(
        'completeDoctorDrop devrait mettre à jour le planning avec le nouveau médecin',
        () {
          // Arrange
          controller.draggedDoctor.value = doctor1;
          final schedule = createSchedule(doctor2.id, serviceAnesthesie.id, 10);

          // Configurer le schedulesByService pour les tests
          controller.schedulesByService.value = {
            serviceAnesthesie.id: [schedule],
          };

          // Act
          controller.completeDoctorDrop(serviceAnesthesie, 10);

          // Assert
          verify(mockScheduleService.changeDoctor(schedule, doctor1)).called(1);
          expect(controller.draggedDoctor.value, isNull); // Drag terminé
        },
      );
    });

    group('Déplacement de planning (Drag-and-Drop)', () {
      test('startDragSchedule devrait initialiser draggedSchedule', () {
        // Arrange
        final schedule = createSchedule(doctor1.id, serviceAnesthesie.id, 10);

        // Act
        controller.startDragSchedule(schedule);

        // Assert
        expect(controller.draggedSchedule.value, equals(schedule));
      });

      test('acceptScheduleDrop devrait vérifier les conditions requises', () {
        // Arrange
        final sourceSchedule = createSchedule(
          doctor1.id,
          serviceAnesthesie.id,
          10,
        );
        final targetSchedule1 = createSchedule(
          doctor2.id,
          serviceAnesthesie.id,
          15,
        );
        final targetSchedule2 = createSchedule(
          doctor3.id,
          servicePediatrie.id,
          20,
        );

        controller.draggedSchedule.value = sourceSchedule;

        // Configurer le schedulesByService pour les tests
        controller.schedulesByService.value = {
          serviceAnesthesie.id: [sourceSchedule, targetSchedule1],
          servicePediatrie.id: [targetSchedule2],
        };

        // Act & Assert
        // Accepter le drop sur un jour avec un planning existant
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 15), isTrue);
        expect(controller.acceptScheduleDrop(servicePediatrie, 20), isTrue);

        // Refuser le drop sur un jour sans planning
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 25), isFalse);

        // Pas de schedule sélectionné
        controller.draggedSchedule.value = null;
        expect(controller.acceptScheduleDrop(serviceAnesthesie, 15), isFalse);
      });

      test(
        'completeScheduleDrop devrait échanger les médecins entre plannings',
        () {
          // Arrange
          final sourceSchedule = createSchedule(
            doctor1.id,
            serviceAnesthesie.id,
            10,
          );
          final targetSchedule = createSchedule(
            doctor2.id,
            serviceAnesthesie.id,
            15,
          );

          controller.draggedSchedule.value = sourceSchedule;

          // Configurer le schedulesByService pour les tests
          controller.schedulesByService.value = {
            serviceAnesthesie.id: [sourceSchedule, targetSchedule],
          };

          // Act
          controller.completeScheduleDrop(serviceAnesthesie, 15);

          // Assert
          verify(
            mockScheduleService.swapDoctors(sourceSchedule, targetSchedule),
          ).called(1);
          // Le mockScheduleService.swapDoctors a déjà été vérifié dans la ligne précédente
          expect(controller.draggedSchedule.value, isNull); // Drag terminé
        },
      );

      test(
        'aucune action ne devrait être effectuée si la cible est invalide',
        () {
          // Arrange
          final sourceSchedule = createSchedule(
            doctor1.id,
            serviceAnesthesie.id,
            10,
          );
          controller.draggedSchedule.value = sourceSchedule;

          // Configurer le schedulesByService pour les tests avec une cible inexistante
          controller.schedulesByService.value = {
            serviceAnesthesie.id: [sourceSchedule],
          };

          // Act
          controller.completeScheduleDrop(serviceAnesthesie, 15);

          // Assert
          // Vérifier qu'aucun appel à swapDoctors n'a été effectué
          verifyNever(
            mockScheduleService.swapDoctors(
              argThat(isA<Schedule>()),
              argThat(isA<Schedule>()),
            ),
          );
          expect(
            controller.draggedSchedule.value,
            isNull,
          ); // Drag terminé quand même
        },
      );
    });

    group('Combinaison des opérations de Drag-and-Drop', () {
      test('une seule opération de drag devrait être autorisée à la fois', () {
        // Arrange
        final schedule = createSchedule(doctor1.id, serviceAnesthesie.id, 10);

        // Act
        controller.startDragDoctor(doctor1);
        controller.startDragSchedule(schedule);

        // Assert - la deuxième action écrase la première
        expect(controller.draggedDoctor.value, isNull);
        expect(controller.draggedSchedule.value, equals(schedule));

        // Act
        controller.endDrag();
        controller.startDragDoctor(doctor1);

        // Assert
        expect(controller.draggedDoctor.value, equals(doctor1));
        expect(controller.draggedSchedule.value, isNull);
      });
    });

    group('Vérification des médecins et services', () {
      // Note: La méthode _canDoctorWorkInService est privée et n'est pas accessible directement
      // Nous testons donc indirectement via acceptDoctorDrop ou d'autres méthodes publiques
      test(
        'compatibilité médecin-service devrait être correctement vérifiée',
        () {
          // Arrange
          final schedule1 = createSchedule(
            doctor2.id,
            serviceAnesthesie.id,
            10,
          );
          final schedule2 = createSchedule(doctor3.id, servicePediatrie.id, 10);

          controller.schedulesByService.value = {
            serviceAnesthesie.id: [schedule1],
            servicePediatrie.id: [schedule2],
          };

          // Tests avec le médecin anesthésiste
          controller.draggedDoctor.value = doctor1;
          expect(
            controller.acceptDoctorDrop(serviceAnesthesie, 10),
            isTrue,
          ); // Compatible
          expect(
            controller.acceptDoctorDrop(servicePediatrie, 10),
            isFalse,
          ); // Non compatible

          // Tests avec le médecin pédiatre
          controller.draggedDoctor.value = doctor2;
          expect(
            controller.acceptDoctorDrop(serviceAnesthesie, 10),
            isFalse,
          ); // Non compatible
          expect(
            controller.acceptDoctorDrop(servicePediatrie, 10),
            isTrue,
          ); // Compatible

          // Tests avec le médecin polyvalent
          controller.draggedDoctor.value = doctor3;
          expect(
            controller.acceptDoctorDrop(serviceAnesthesie, 10),
            isTrue,
          ); // Compatible
          expect(
            controller.acceptDoctorDrop(servicePediatrie, 10),
            isTrue,
          ); // Compatible
        },
      );
    });
  });
}
