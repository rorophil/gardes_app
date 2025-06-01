import 'package:flutter_test/flutter_test.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/services/schedule_service.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/modules/schedule/controllers/schedule_generation_controller.dart';
import 'package:gardes_app/app/routes/app_routes.dart';

import 'schedule_generation_controller_test.mocks.dart';

@GenerateMocks([DatabaseService, ScheduleService])
void main() {
  late MockDatabaseService mockDatabaseService;
  late MockScheduleService mockScheduleService;
  late ScheduleGenerationController controller;

  // Pour capturer la navigation
  var navigationData = <String, dynamic>{};

  // Créer des données de test
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

  final List<Service> testServices = [testService1, testService2];

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockScheduleService = MockScheduleService();

    // Réinitialisez les données de navigation
    navigationData.clear();

    // Initialiser l'injection de dépendance GetX
    Get.put<DatabaseService>(mockDatabaseService);
    Get.put<ScheduleService>(mockScheduleService);

    // Configurer les mocks
    when(mockDatabaseService.getAllServices()).thenReturn(testServices);
    
    when(mockScheduleService.generateMonthlySchedule(any, any, any))
        .thenAnswer((_) async => Future<List<Schedule>>.value([]));

    // Initialiser le contrôleur avec la redéfinition de la navigation
    controller = ScheduleGenerationController();
    
    // Modification du comportement de navigation pour les tests
    // Utilisons une implémentation test-friendly de Get.toNamed
    controller.navigateToScheduleView = (int year, int month, List<Service> services) {
      navigationData['route'] = AppRoutes.SCHEDULE_VIEW;
      navigationData['year'] = year;
      navigationData['month'] = month;
      navigationData['services'] = services;
    };
    
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('ScheduleGenerationController Tests', () {
    test('should load services on init', () {
      expect(controller.services, equals(testServices));
      expect(controller.isLoading.value, isFalse);
      verify(mockDatabaseService.getAllServices()).called(1);
    });

    test('should toggle service selection correctly', () {
      expect(controller.selectedServices.isEmpty, isTrue);
      
      controller.toggleServiceSelection(testService1);
      expect(controller.selectedServices, contains(testService1));
      expect(controller.selectedServices.length, 1);
      
      controller.toggleServiceSelection(testService1);
      expect(controller.selectedServices.isEmpty, isTrue);
      
      controller.toggleServiceSelection(testService1);
      controller.toggleServiceSelection(testService2);
      expect(controller.selectedServices, contains(testService1));
      expect(controller.selectedServices, contains(testService2));
      expect(controller.selectedServices.length, 2);
    });

    test('should change month correctly', () {
      final initialYear = controller.selectedYear.value;
      final initialMonth = controller.selectedMonth.value;
      
      final newYear = 2024;
      final newMonth = 5;
      
      controller.changeMonth(newYear, newMonth);
      
      expect(controller.selectedYear.value, equals(newYear));
      expect(controller.selectedMonth.value, equals(newMonth));
      expect(controller.selectedYear.value, isNot(equals(initialYear)));
      expect(controller.selectedMonth.value, isNot(equals(initialMonth)));
    });

    test('should show error when trying to generate schedules with no services selected', () async {
      controller.selectedServices.clear();
      await controller.generateSchedules();
      
      expect(controller.isGenerating.value, isFalse);
      verifyNever(mockScheduleService.generateMonthlySchedule(any, any, any));
    });

    test('should generate schedules for selected services', () async {
      controller.selectedServices.value = [testService1, testService2];
      
      await controller.generateSchedules();
      
      // Utiliser spécifiquement verify avec les arguments exacts
      verify(mockScheduleService.generateMonthlySchedule(
        testService1, 
        controller.selectedYear.value, 
        controller.selectedMonth.value
      )).called(1);
      
      verify(mockScheduleService.generateMonthlySchedule(
        testService2, 
        controller.selectedYear.value, 
        controller.selectedMonth.value
      )).called(1);
      
      expect(controller.isGenerating.value, isFalse);
      expect(controller.generationStatus.value, contains('Terminé'));
    });

    test('should format month names correctly', () {
      expect(controller.getMonthName(1), equals('Janvier'));
      expect(controller.getMonthName(4), equals('Avril'));
      expect(controller.getMonthName(8), equals('Août'));
      expect(controller.getMonthName(12), equals('Décembre'));
    });

    test('should handle errors during service loading', () {
      // Reset controller
      Get.reset();
      mockDatabaseService = MockDatabaseService();
      mockScheduleService = MockScheduleService();
      Get.put<DatabaseService>(mockDatabaseService);
      Get.put<ScheduleService>(mockScheduleService);

      // Configure mock to throw an error
      when(mockDatabaseService.getAllServices()).thenThrow(Exception('Test error'));

      // Initialize controller with error
      controller = ScheduleGenerationController();

      expect(controller.isLoading.value, isFalse); // Loading should complete
      expect(controller.services.isEmpty, isTrue); // Services should be empty due to error
    });

    test('should handle errors during schedule generation', () async {
      controller.selectedServices.value = [testService1];

      // Configure mock to throw an error
      when(mockScheduleService.generateMonthlySchedule(any, any, any))
          .thenThrow(Exception('Generation error'));

      await controller.generateSchedules();

      expect(controller.isGenerating.value, isFalse);
      // Generation should stop after the error
    });
    
    test('should update generation status during processing', () async {
      controller.selectedServices.value = [testService1, testService2];
      
      // Spy on generationStatus changes
      final statusValues = <String>[];
      ever(controller.generationStatus, (val) => statusValues.add(val));
      
      await controller.generateSchedules();
      
      // Verify that status was updated for preparation
      expect(statusValues.any((s) => s.contains('Préparation')), isTrue);
      
      // Verify status updates for each service
      expect(statusValues.any((s) => s.contains('Génération pour ${testService1.nom}')), isTrue);
      expect(statusValues.any((s) => s.contains('Génération pour ${testService2.nom}')), isTrue);
      
      // Verify completion status
      expect(statusValues.any((s) => s.contains('Terminé')), isTrue);
    });
    
    test('should navigate to schedule view after successful generation', () async {
      controller.selectedServices.value = [testService1, testService2];
      
      await controller.generateSchedules();
      
      expect(navigationData['route'], equals(AppRoutes.SCHEDULE_VIEW));
      expect(navigationData['year'], equals(controller.selectedYear.value));
      expect(navigationData['month'], equals(controller.selectedMonth.value));
      expect(navigationData['services'] is List, isTrue);
      
      final services = navigationData['services'] as List;
      expect(services.length, lessThanOrEqualTo(3));
      expect(services.contains(testService1), isTrue);
    });
    
    test('should limit displayed services to 3 in navigation', () async {
      final manyServices = [
        testService1,
        testService2,
        Service(ObjectId(), 'Service 3', false, false, true, false),
        Service(ObjectId(), 'Service 4', false, false, false, true),
      ];
      
      controller.selectedServices.value = manyServices;
      
      await controller.generateSchedules();
      
      final services = navigationData['services'] as List;
      expect(services.length, equals(3)); // Should be limited to 3
    });
  });
}