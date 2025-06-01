import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_view_controller.dart';

import 'schedule_view_controller_test.mocks.dart';

@GenerateMocks([DatabaseService, ScheduleService])
void main() {
  late MockDatabaseService mockDatabaseService;
  late MockScheduleService mockScheduleService;
  late ScheduleViewController controller;

  // Create test data
  final testService1 = Service(
    ObjectId(),
    'Service Test 1',
    true,
    false,
    false,
    false,
  );

  final testService2 = Service(
    ObjectId(),
    'Service Test 2',
    false,
    true,
    true,
    false,
  );

  final testDoctor1 = Doctor(
    ObjectId(),
    'Dupont',
    'Jean',
    'jdupont',
    'password',
    true,
    false,
    false,
    false,
    10,
    2,
  );

  final testDoctor2 = Doctor(
    ObjectId(),
    'Martin',
    'Marie',
    'mmartin',
    'password',
    false,
    true,
    true,
    false,
    8,
    3,
  );

  final testDate = DateTime(2023, 10, 15);
  
  final testSchedule1 = Schedule(ObjectId(), testDoctor1.id, testService1.id, testDate);
  final testSchedule2 = Schedule(ObjectId(), testDoctor2.id, testService2.id, testDate);
  
  final List<Service> testServices = [testService1, testService2];
  final List<Doctor> testDoctors = [testDoctor1, testDoctor2];
  
  final Map<ObjectId, List<Schedule>> testSchedulesByService = {
    testService1.id: [testSchedule1],
    testService2.id: [testSchedule2],
  };

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockScheduleService = MockScheduleService();
    
    // Initialize the GetX dependency injection
    Get.put<DatabaseService>(mockDatabaseService);
    Get.put<ScheduleService>(mockScheduleService);
    
    // Configure mocks
    when(mockDatabaseService.getAllServices()).thenReturn(testServices);
    when(mockDatabaseService.getAllDoctors()).thenReturn(testDoctors);
    when(mockDatabaseService.getSchedulesByService(any, any, any))
        .thenAnswer((invocation) {
          final service = invocation.positionalArguments[0] as Service;
          return testSchedulesByService[service.id] ?? [];
        });
    when(mockDatabaseService.getDoctor(any))
        .thenAnswer((invocation) {
          final doctorId = invocation.positionalArguments[0] as ObjectId;
          return testDoctors.firstWhere((d) => d.id == doctorId, orElse: () => testDoctor1);
        });
        
    // Initialize controller
    controller = ScheduleViewController();
  });

  tearDown(() {
    Get.reset();
  });

  group('ScheduleViewController Tests', () {
    test('should load services on init', () {
      expect(controller.services, equals(testServices));
    });
    
    test('should set default displayed services', () {
      expect(controller.displayedServices.length, greaterThan(0));
      expect(controller.displayedServices.length, lessThanOrEqualTo(3));
    });

    test('should load schedules for services', () async {
      await controller.loadSchedules();
      
      for (final service in controller.displayedServices) {
        expect(controller.schedulesByService.value.containsKey(service.id), isTrue);
      }
      
      verify(mockDatabaseService.getSchedulesByService(
        any, 
        controller.selectedYear.value, 
        controller.selectedMonth.value
      )).called(controller.displayedServices.length);
    });

    test('should filter available doctors', () {
      controller.displayedServices.value = [testService1]; // Only anesthesiste required
      controller.loadAvailableDoctors();
      
      expect(controller.availableDoctors, contains(testDoctor1)); // Has anesthesiste
      expect(controller.availableDoctors, isNot(contains(testDoctor2))); // Doesn't have anesthesiste
    });

    test('should check if doctor can work in service', () {
      expect(controller.canDoctorWorkInService(testDoctor1, testService1), isTrue); // Anesthesiste
      expect(controller.canDoctorWorkInService(testDoctor2, testService1), isFalse); // Not anesthesiste
      expect(controller.canDoctorWorkInService(testDoctor2, testService2), isTrue); // Pediatrique and SAMU
    });

    test('should change displayed services and reload schedules', () async {
      final newServices = [testService2];
      controller.changeDisplayedServices(newServices);
      
      expect(controller.displayedServices, equals(newServices));
      verify(mockDatabaseService.getSchedulesByService(
        testService2, 
        controller.selectedYear.value, 
        controller.selectedMonth.value
      )).called(1);
    });

    test('should change month and reload schedules', () async {
      final newYear = 2024;
      final newMonth = 3;
      controller.changeMonth(newYear, newMonth);
      
      expect(controller.selectedYear.value, equals(newYear));
      expect(controller.selectedMonth.value, equals(newMonth));
      
      for (final service in controller.displayedServices) {
        verify(mockDatabaseService.getSchedulesByService(service, newYear, newMonth)).called(1);
      }
    });

    test('should get schedule for specific day', () {
      controller.selectedYear.value = 2023;
      controller.selectedMonth.value = 10;
      controller.schedulesByService.value = testSchedulesByService;
      
      final schedule = controller.getScheduleForDay(testService1, 15);
      expect(schedule, equals(testSchedule1));
      
      final noSchedule = controller.getScheduleForDay(testService1, 16);
      expect(noSchedule, isNull);
    });

    test('should get doctor by id', () {
      controller.availableDoctors.value = testDoctors;
      
      final doctor = controller.getDoctorById(testDoctor1.id);
      expect(doctor, equals(testDoctor1));
      
      verify(mockDatabaseService.getDoctor(any)).called(0); // Should find in available doctors
      
      // Test with doctor not in availableDoctors
      controller.availableDoctors.value = [];
      final doctor2 = controller.getDoctorById(testDoctor2.id);
      expect(doctor2, isNotNull);
      
      verify(mockDatabaseService.getDoctor(any)).called(1); // Should query database
    });
    
    test('should handle drag and drop operations for schedules', () {
      controller.startDragSchedule(testSchedule1);
      expect(controller.draggedSchedule.value, equals(testSchedule1));
      
      controller.endDrag();
      expect(controller.draggedSchedule.value, isNull);
      
      // Test schedule drop acceptance
      controller.startDragSchedule(testSchedule1);
      controller.schedulesByService.value = testSchedulesByService;
      controller.selectedYear.value = 2023;
      controller.selectedMonth.value = 10;
      
      final canAccept = controller.acceptScheduleDrop(testService2, 15);
      expect(canAccept, isTrue);
      
      // Test complete schedule drop
      when(mockScheduleService.swapDoctors(any, any)).thenAnswer((_) => null);
      controller.completeScheduleDrop(testService2, 15);
      
      verify(mockScheduleService.swapDoctors(testSchedule1, testSchedule2)).called(1);
      expect(controller.draggedSchedule.value, isNull); // Should reset drag state
    });
    
    test('should format month names correctly', () {
      expect(controller.getMonthName(1), equals('Janvier'));
      expect(controller.getMonthName(6), equals('Juin'));
      expect(controller.getMonthName(12), equals('Décembre'));
    });
    
    test('should format day of week correctly', () {
      controller.selectedYear.value = 2023;
      controller.selectedMonth.value = 10;
      
      // October 16, 2023 was a Monday
      expect(controller.getDayOfWeek(16), equals('Lun'));
      // October 20, 2023 was a Friday
      expect(controller.getDayOfWeek(20), equals('Ven'));
      // October 22, 2023 was a Sunday
      expect(controller.getDayOfWeek(22), equals('Dim'));
    });
  });
}