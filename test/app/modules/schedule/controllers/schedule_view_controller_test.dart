import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_view_controller.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_view_controller.dart';

import '../../admin/bindings/admin_binding_test.dart';
import 'schedule_controller_test.dart';

@GenerateMocks([DatabaseService, ScheduleService])
void main() {
  late MockDatabaseService mockDatabaseService;
  late MockScheduleService mockScheduleService;
  late ScheduleViewController controller;

  // Test data
  final testDoctor = Doctor(
    ObjectId(),
    'Nom',
    'Prénom',
    'login',
    'password',
    true, // anesthésiste
    false,
    false,
    false,
    10,
    2,
  );

  final testServiceAnesthesie = Service(
    ObjectId(),
    'Anesthésie',
    true,
    false,
    false,
    false,
  );

  final testServicePediatrie = Service(
    ObjectId(),
    'Pédiatrie',
    false,
    true,
    false,
    false,
  );

  final testSchedules = [
    Schedule(
      ObjectId(),
      testDoctor.id,
      testServiceAnesthesie.id,
      DateTime(2023, 10, 15),
    ),
    Schedule(
      ObjectId(),
      testDoctor.id,
      testServiceAnesthesie.id,
      DateTime(2023, 10, 16),
    ),
  ];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockScheduleService = MockScheduleService();

    // Configure mocks
    when(
      mockDatabaseService.getAllServices(),
    ).thenReturn([testServiceAnesthesie, testServicePediatrie]);
    when(mockDatabaseService.getAllDoctors()).thenReturn([testDoctor]);
    when(
      mockDatabaseService.getSchedulesByService(
        testServiceAnesthesie,
        2023,
        10,
      ),
    ).thenReturn(testSchedules);
    when(mockDatabaseService.getDoctor(testDoctor.id)).thenReturn(testDoctor);

    // Register mocks with Get.put so they are available via Get.find
    Get.put<DatabaseService>(mockDatabaseService);
    Get.put<ScheduleService>(mockScheduleService);

    // Initialize controller
    controller = ScheduleViewController();

    // Set controller values manually for testing
    controller.selectedYear.value = 2023;
    controller.selectedMonth.value = 10;
    controller.services.value = [testServiceAnesthesie, testServicePediatrie];
    controller.displayedServices.value = [testServiceAnesthesie];
  });

  tearDown(() {
    Get.reset();
  });

  group('ScheduleViewController Tests', () {
    test('should load services and schedules on init', () async {
      await controller.loadSchedules();

      verify(
        mockDatabaseService.getSchedulesByService(
          testServiceAnesthesie,
          2023,
          10,
        ),
      ).called(1);
      expect(controller.displayedServices, contains(testServiceAnesthesie));
      expect(
        controller.schedulesByService.value.containsKey(
          testServiceAnesthesie.id,
        ),
        isTrue,
      );
    });

    test('should filter doctors who can work in displayed services', () {
      controller.loadAvailableDoctors();

      // Since the test doctor is an anesthesiologist and the displayed service requires anesthesiologists
      expect(controller.availableDoctors, contains(testDoctor));
    });

    test('should correctly determine if a doctor can work in a service', () {
      // This doctor is an anesthesiologist and can work in the anesthesia service
      expect(
        controller._canDoctorWorkInService(testDoctor, testServiceAnesthesie),
        isTrue,
      );

      // But not in the pediatric service which requires pediatric doctors
      expect(
        controller._canDoctorWorkInService(testDoctor, testServicePediatrie),
        isFalse,
      );
    });

    test('should find a schedule for a specific day', () {
      controller.schedulesByService.value = {
        testServiceAnesthesie.id: testSchedules,
      };

      // Should find the schedule for the 15th
      expect(
        controller.getScheduleForDay(testServiceAnesthesie, 15),
        equals(testSchedules[0]),
      );

      // But not for the 17th
      expect(controller.getScheduleForDay(testServiceAnesthesie, 17), isNull);
    });

    test('should correctly format month names', () {
      expect(controller.getMonthName(1), equals('Janvier'));
      expect(controller.getMonthName(12), equals('Décembre'));
      expect(controller.getMonthName(5), equals('Mai'));
    });

    test('should correctly format day of week names', () {
      // In 2023, Oct 15 was a Sunday
      controller.selectedYear.value = 2023;
      controller.selectedMonth.value = 10;
      expect(controller.getDayOfWeek(15), equals('Dim'));

      // Oct 16 was a Monday
      expect(controller.getDayOfWeek(16), equals('Lun'));
    });
  });
}
