import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:get/get.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_view_controller.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';

// Mocks manuels pour les services
class MockDatabaseService extends GetxService
    with Mock
    implements DatabaseService {
  @override
  void onInit() {}

  @override
  void onClose() {}
}

class MockScheduleService extends GetxService
    with Mock
    implements ScheduleService {
  @override
  void onInit() {}

  @override
  void onClose() {}
}

// Classes factices pour les tests
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
  late RealmList<String> joursBloquees;

  TestService(
    this.id,
    this.nom, {
    this.requiresAnesthesiste = false,
    this.requiresPediatrique = false,
    this.requiresSamu = false,
    this.requiresIntensiviste = false,
  }) {
    joursBloquees = RealmList<String>([]);
  }

  @override
  bool isDateBlocked(DateTime date) => false;

  @override
  bool acceptsDoctor(Doctor doctor) => true;

  @override
  List<Privilege> get privileges => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  late RealmList<String> joursIndisponibles;
  @override
  int maxGardesParMois = 10;
  @override
  int joursMinEntreGardes = 2;

  TestDoctor(
    this.id,
    this.nom,
    this.prenom, {
    this.login = '',
    this.password = '',
    this.isAnesthesiste = false,
    this.isPediatrique = false,
    this.isSamu = false,
    this.isIntensiviste = false,
  }) {
    joursIndisponibles = RealmList<String>([]);
  }

  @override
  bool hasPrivilege(Privilege privilege) => false;

  @override
  bool isAvailableOn(DateTime date) => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ScheduleViewController Tests', () {
    late ScheduleViewController controller;
    late MockDatabaseService mockDatabaseService;
    late MockScheduleService mockScheduleService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      mockScheduleService = MockScheduleService();

      // Enregistrer les mocks dans GetX
      Get.put<DatabaseService>(mockDatabaseService);
      Get.put<ScheduleService>(mockScheduleService);

      controller = ScheduleViewController();
    });

    tearDown(() {
      Get.reset();
    });

    test('loadData devrait charger les services et les plannings', () async {
      // Arrange
      final services = [
        TestService(ObjectId(), "Service 1"),
        TestService(ObjectId(), "Service 2"),
      ];

      final doctors = [
        TestDoctor(ObjectId(), "Dupont", "Jean"),
        TestDoctor(ObjectId(), "Martin", "Marie"),
      ];

      final schedules = [
        Schedule(
          ObjectId(),
          doctors[0].id,
          services[0].id,
          DateTime(2025, 5, 15),
        ),
        Schedule(
          ObjectId(),
          doctors[1].id,
          services[0].id,
          DateTime(2025, 5, 16),
        ),
      ];

      when(mockDatabaseService.getAllServices()).thenReturn(services);
      when(mockDatabaseService.getAllDoctors()).thenReturn(doctors);
      when(
        mockDatabaseService.getSchedulesByMonth(2025, 5),
      ).thenReturn(schedules);

      // Act
      await controller.loadData();

      // Assert
      verify(mockDatabaseService.getAllServices()).called(1);
      verify(mockDatabaseService.getSchedulesByMonth(2025, 5)).called(1);
      expect(controller.services.length, 2);
      expect(controller.displayedServices.length, 2);
      expect(controller.schedulesByService.value.isEmpty, isFalse);
    });

    test('changer les services affichés devrait fonctionner', () {
      // Arrange
      final services = [
        TestService(ObjectId(), "Service 1"),
        TestService(ObjectId(), "Service 2"),
        TestService(ObjectId(), "Service 3"),
      ];

      controller.services.assignAll(services);

      // Act
      controller.displayedServices.value = [services[0], services[2]];

      // Assert
      expect(controller.displayedServices.length, 2);
      expect(controller.displayedServices.contains(services[0]), isTrue);
      expect(controller.displayedServices.contains(services[1]), isFalse);
      expect(controller.displayedServices.contains(services[2]), isTrue);
    });

    test('startDragDoctor devrait mettre à jour draggedDoctor', () {
      // Arrange
      final doctor = TestDoctor(ObjectId(), "Dupont", "Jean");

      // Act
      controller.startDragDoctor(doctor);

      // Assert
      expect(controller.draggedDoctor.value, doctor);
    });

    test('startDragSchedule devrait mettre à jour draggedSchedule', () {
      // Arrange
      final service = TestService(ObjectId(), "Service 1");
      final schedule = Schedule(
        ObjectId(),
        ObjectId(),
        service.id,
        DateTime(2025, 5, 15),
      );

      // Act
      controller.startDragSchedule(schedule);

      // Assert
      expect(controller.draggedSchedule.value, schedule);
    });

    test('endDrag devrait réinitialiser les valeurs de drag', () {
      // Arrange
      final service = TestService(ObjectId(), "Service 1");
      final doctor = TestDoctor(ObjectId(), "Dupont", "Jean");
      final schedule = Schedule(
        ObjectId(),
        doctor.id,
        service.id,
        DateTime(2025, 5, 15),
      );

      controller.draggedSchedule.value = schedule;
      controller.draggedDoctor.value = doctor;

      // Act
      controller.endDrag();

      // Assert
      expect(controller.draggedSchedule.value, isNull);
      expect(controller.draggedDoctor.value, isNull);
    });

    test(
      'completeScheduleDrop devrait échanger les médecins entre plannings',
      () {
        // Arrange
        final service = TestService(ObjectId(), "Service 1");
        final schedule1 = Schedule(
          ObjectId(),
          ObjectId(),
          service.id,
          DateTime(2025, 5, 15),
        );
        final schedule2 = Schedule(
          ObjectId(),
          ObjectId(),
          service.id,
          DateTime(2025, 5, 16),
        );

        controller.draggedSchedule.value = schedule1;

        // Ajouter le schedule dans le map pour qu'il puisse être trouvé par getScheduleForDay
        final scheduleMap = {
          service.id: [schedule2],
        };
        controller.schedulesByService.value = scheduleMap;

        // Simuler le fait que schedule2 est pour le jour 16
        schedule2.date = DateTime(2025, 5, 16);

        // Act
        controller.completeScheduleDrop(service, 16);

        // Assert
        verify(mockScheduleService.swapDoctors(schedule1, schedule2)).called(1);
        expect(controller.draggedSchedule.value, isNull);
      },
    );

    test('completeDoctorDrop devrait changer le médecin dans un planning', () {
      // Arrange
      final service = TestService(ObjectId(), "Service 1");
      final doctor = TestDoctor(ObjectId(), "Dupont", "Jean");
      final schedule = Schedule(
        ObjectId(),
        ObjectId(),
        service.id,
        DateTime(2025, 5, 15),
      );

      controller.draggedDoctor.value = doctor;

      // Ajouter le schedule dans le map pour qu'il puisse être trouvé par getScheduleForDay
      final scheduleMap = {
        service.id: [schedule],
      };
      controller.schedulesByService.value = scheduleMap;

      // Act
      controller.completeDoctorDrop(service, 15);

      // Assert
      verify(mockScheduleService.changeDoctor(schedule, doctor)).called(1);
      expect(controller.draggedDoctor.value, isNull);
    });
  });
}
