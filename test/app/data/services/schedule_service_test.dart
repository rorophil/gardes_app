// Tests pour le service de planification des gardes
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'testable_schedule_service.dart';
import 'schedule_service_test.mocks.dart';

// Génération du fichier de mocks
@GenerateMocks([DatabaseService])
void main() {
  late MockDatabaseService mockDatabaseService;
  late TestableScheduleService scheduleService;

  final doctorId1 = ObjectId();
  final doctorId2 = ObjectId();
  final serviceId = ObjectId();
  final scheduleId1 = ObjectId();
  final scheduleId2 = ObjectId();

  // Test data
  final testDoctor1 = Doctor(
    doctorId1,
    'Dupont',
    'Jean',
    'jdupont',
    'password',
    true, // anesthésiste
    false,
    false,
    false,
    10, // max gardes
    2, // jours min entre gardes
  );

  final testDoctor2 = Doctor(
    doctorId2,
    'Martin',
    'Sophie',
    'smartin',
    'password',
    true, // anesthésiste
    true, // pédiatrique aussi
    false,
    false,
    10,
    2,
    joursIndisponibles: ['2023-10-15', '2023-10-16'],
  );

  final testService = Service(
    serviceId,
    'Anesthésie',
    true,
    false,
    false,
    false,
    joursBloquees: ['2023-10-25'],
  );

  setUp(() {
    Get.reset(); // Reset GetX
    mockDatabaseService = MockDatabaseService();

    // Configure mocks
    when(
      mockDatabaseService.getAllDoctors(),
    ).thenReturn([testDoctor1, testDoctor2]);
    when(mockDatabaseService.getSchedulesByDoctor(testDoctor1)).thenReturn([]);
    when(mockDatabaseService.getSchedulesByDoctor(testDoctor2)).thenReturn([]);
    when(
      mockDatabaseService.createSchedule(
        doctor: anyNamed('doctor'),
        service: anyNamed('service'),
        date: anyNamed('date'),
      ),
    ).thenAnswer((invocation) {
      final doctor =
          invocation.namedArguments[const Symbol('doctor')] as Doctor;
      final service =
          invocation.namedArguments[const Symbol('service')] as Service;
      final date = invocation.namedArguments[const Symbol('date')] as DateTime;
      return Schedule(ObjectId(), doctor.id, service.id, date);
    });

    // Ajouter des implémentations mock manquantes
    when(mockDatabaseService.getDoctor(any)).thenAnswer((invocation) {
      final id = invocation.positionalArguments[0] as ObjectId;
      if (id == doctorId1) return testDoctor1;
      if (id == doctorId2) return testDoctor2;
      return null;
    });

    when(mockDatabaseService.getService(any)).thenReturn(testService);

    // Créer le service de test en injectant le mock directement
    scheduleService = TestableScheduleService(mockDatabaseService);
  });

  tearDown(() {
    Get.reset();
  });

  group('ScheduleService Tests', () {
    test('should generate monthly schedule correctly', () async {
      final schedules = await scheduleService.generateMonthlySchedule(
        testService,
        2023,
        10,
      );

      // Should generate schedules for days in October except blocked day 25th
      // Also should not generate schedules for days when doctor2 is unavailable
      expect(schedules, isNotEmpty);

      // Verify that createSchedule was called at least once
      verify(
        mockDatabaseService.createSchedule(
          doctor: anyNamed('doctor'),
          service: anyNamed('service'),
          date: anyNamed('date'),
        ),
      ).called(greaterThan(0));

      // Verify schedules were not created for blocked days
      for (var schedule in schedules) {
        expect(schedule.date.day != 25, isTrue); // 25th is blocked
      }
    });

    test('should swap doctors correctly', () {
      // Setup
      final schedule1Copy = Schedule(
        scheduleId1,
        doctorId1,
        serviceId,
        DateTime(2023, 10, 15),
      );
      final schedule2Copy = Schedule(
        scheduleId2,
        doctorId2,
        serviceId,
        DateTime(2023, 10, 20),
      );

      // Execute
      scheduleService.swapDoctors(schedule1Copy, schedule2Copy);

      // Verify
      verify(mockDatabaseService.updateSchedule(schedule1Copy)).called(1);
      verify(mockDatabaseService.updateSchedule(schedule2Copy)).called(1);

      // Check IDs were swapped
      expect(schedule1Copy.doctorId, equals(doctorId2));
      expect(schedule2Copy.doctorId, equals(doctorId1));
    });

    test('should change doctor correctly', () {
      // Setup
      final scheduleCopy = Schedule(
        scheduleId1,
        doctorId1,
        serviceId,
        DateTime(2023, 10, 15),
      );

      // Execute
      scheduleService.changeDoctor(scheduleCopy, testDoctor2);

      // Verify
      verify(mockDatabaseService.updateSchedule(scheduleCopy)).called(1);

      // Check ID was updated
      expect(scheduleCopy.doctorId, equals(doctorId2));
    });

    test('should get eligible doctors correctly', () {
      final eligibleDoctors = scheduleService.getEligibleDoctors(testService);
      // Both doctors are anesthesiologists and the service requires anesthesiologists
      expect(eligibleDoctors.length, equals(2));
      expect(eligibleDoctors, contains(testDoctor1));
      expect(eligibleDoctors, contains(testDoctor2));
    });

    test('should determine date priority correctly', () {
      // Friday
      final friday = DateTime(2023, 10, 13);
      // Saturday
      final saturday = DateTime(2023, 10, 14);
      // Thursday
      final thursday = DateTime(2023, 10, 12);
      // Monday
      final monday = DateTime(2023, 10, 16);

      // Lower value means higher priority
      expect(
        scheduleService.getDatePriority(friday),
        equals(0),
      ); // Highest priority
      expect(scheduleService.getDatePriority(saturday), equals(1)); // Weekend
      expect(
        scheduleService.getDatePriority(monday),
        equals(2),
      ); // Regular weekday
      expect(
        scheduleService.getDatePriority(thursday),
        equals(3),
      ); // Lowest priority
    });

    test('should get available doctors for a specific date', () {
      final dates = scheduleService.getDatesInMonth(2023, 10);
      final availableDoctors = scheduleService.getAvailableDoctorsForDate(
        [testDoctor1, testDoctor2],
        DateTime(2023, 10, 17), // Date où tous les docteurs sont disponibles
        [],
      );

      expect(dates.length, equals(31)); // Octobre a 31 jours
      expect(
        availableDoctors.length,
        equals(2),
      ); // Les deux docteurs sont disponibles

      // Test date où docteur2 est indisponible
      final availableOnBlockedDay = scheduleService.getAvailableDoctorsForDate(
        [testDoctor1, testDoctor2],
        DateTime(2023, 10, 15), // Jour où docteur2 est indisponible
        [],
      );

      expect(
        availableOnBlockedDay.length,
        equals(1),
      ); // Seul docteur1 est disponible
      expect(availableOnBlockedDay, contains(testDoctor1));
      expect(availableOnBlockedDay, isNot(contains(testDoctor2)));
    });

    test('should respect minimum days between shifts', () {
      // Simuler un planning existant pour docteur1
      final existingSchedules = [
        Schedule(ObjectId(), doctorId1, serviceId, DateTime(2023, 10, 15)),
      ];

      // Test pour une date trop proche (1 jour après)
      final availableTooSoon = scheduleService.getAvailableDoctorsForDate(
        [testDoctor1],
        DateTime(2023, 10, 16), // Seulement 1 jour après la garde précédente
        existingSchedules,
      );

      expect(
        availableTooSoon.isEmpty,
        isTrue,
      ); // Docteur1 ne peut pas prendre cette garde

      // Test pour une date suffisamment éloignée (3 jours après)
      final availableAfterGap = scheduleService.getAvailableDoctorsForDate(
        [testDoctor1],
        DateTime(2023, 10, 18), // 3 jours après la garde précédente
        existingSchedules,
      );

      expect(
        availableAfterGap.isNotEmpty,
        isTrue,
      ); // Docteur1 peut prendre cette garde
      expect(availableAfterGap, contains(testDoctor1));
    });

    test('should respect maximum shifts per month', () {
      // Créer un planning avec le maximum de gardes déjà atteint pour docteur1
      final maxSchedules = List.generate(
        testDoctor1.maxGardesParMois,
        (i) => Schedule(
          ObjectId(),
          doctorId1,
          serviceId,
          DateTime(2023, 10, i + 1), // Jours 1 à 10
        ),
      );

      final availableDoctors = scheduleService.getAvailableDoctorsForDate(
        [testDoctor1],
        DateTime(2023, 10, 20), // Date ultérieure dans le mois
        maxSchedules,
      );

      expect(
        availableDoctors.isEmpty,
        isTrue,
      ); // Docteur1 a atteint son max de gardes
    });
  });
}
