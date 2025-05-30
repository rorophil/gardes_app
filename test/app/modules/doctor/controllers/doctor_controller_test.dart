import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/auth_service.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/modules/doctor/controllers/doctor_controller.dart';

import 'doctor_controller_test.mocks.dart';

@GenerateMocks([AuthService, DatabaseService])
void main() {
  late MockAuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  late DoctorController controller;

  // Create test data
  final testDoctor = Doctor(
    ObjectId(),
    'Nom',
    'Prénom',
    'login',
    'password',
    true,
    false,
    true,
    false,
    10,
    2,
  );

  final testService = Service(
    ObjectId(),
    'Service Test',
    true,
    false,
    false,
    false,
  );

  final List<Schedule> testSchedules = [
    Schedule(ObjectId(), testDoctor.id, testService.id, DateTime(2023, 10, 15)),
    Schedule(ObjectId(), testDoctor.id, testService.id, DateTime(2023, 10, 20)),
    Schedule(ObjectId(), testDoctor.id, testService.id, DateTime(2023, 11, 5)),
  ];

  setUp(() {
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();

    // Configure mocks
    when(mockAuthService.currentUser).thenReturn(Rx<Doctor?>(testDoctor));
    when(
      mockDatabaseService.getSchedulesByDoctor(testDoctor),
    ).thenReturn(testSchedules);
    when(
      mockDatabaseService.getServiceById(testService.id),
    ).thenReturn(testService);

    // Initialize controller with mocks
    controller = DoctorController(
      authService: mockAuthService,
      databaseService: mockDatabaseService,
    );
  });

  group('DoctorController Tests', () {
    test('should load doctor from auth service', () {
      expect(controller.currentDoctor.value, equals(testDoctor));
    });

    test('should load schedules for current doctor', () {
      controller.loadSchedules();
      expect(controller.schedules.length, equals(testSchedules.length));
      verify(mockDatabaseService.getSchedulesByDoctor(testDoctor)).called(1);
    });

    test('should group schedules by month correctly', () {
      controller.schedules.value = testSchedules;
      final groupedSchedules = controller.getSchedulesByMonth();

      expect(groupedSchedules.length, equals(2)); // October and November
      expect(groupedSchedules.containsKey('2023-10'), isTrue);
      expect(groupedSchedules.containsKey('2023-11'), isTrue);
      expect(
        groupedSchedules['2023-10']?.length,
        equals(2),
      ); // 2 schedules in October
      expect(
        groupedSchedules['2023-11']?.length,
        equals(1),
      ); // 1 schedule in November
    });

    test('should format month correctly', () {
      expect(controller.formatMonth('2023-1'), equals('Janvier 2023'));
      expect(controller.formatMonth('2023-12'), equals('Décembre 2023'));
      expect(controller.formatMonth('2023-3'), equals('Mars 2023'));
    });

    test('should retrieve service by id', () {
      final returnedService = controller.getServiceById(testService.id);
      expect(returnedService, equals(testService));
      verify(mockDatabaseService.getService(testService.id)).called(1);
    });
  });
}
