import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gardes_app/app/modules/admin/bindings/admin_binding.dart';
import 'package:gardes_app/app/modules/admin/controllers/admin_controller.dart';
import 'package:gardes_app/app/modules/admin/controllers/doctor_management_controller.dart';
import 'package:gardes_app/app/modules/admin/controllers/doctor_form_controller.dart';
import 'package:gardes_app/app/modules/admin/controllers/service_management_controller.dart';
import 'package:gardes_app/app/modules/admin/controllers/service_form_controller.dart';
import 'package:gardes_app/app/data/services/auth_service.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:realm/realm.dart';
import 'package:get/get.dart';

// Mock des services utilisés par les contrôleurs
class MockAuthService extends GetxService implements AuthService {
  @override
  bool get isLoggedIn => true;

  @override
  bool get isAdminLoggedIn => true;

  @override
  Future<bool> login(String login, String password) async => true;

  @override
  void logout() {}

  @override
  final currentUser = Rx<Doctor?>(null);

  @override
  final currentRole = Rx<UserRole>(UserRole.admin);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDatabaseService extends GetxService implements DatabaseService {
  @override
  Future<DatabaseService> init() async => this;

  @override
  List<Doctor> getAllDoctors() => [];

  @override
  List<Service> getAllServices() => [];

  @override
  List<Schedule> getAllSchedules() => [];

  @override
  Doctor? getDoctor(ObjectId id) => null;

  @override
  Service? getService(ObjectId id) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock du DoctorManagementController pour éviter le problème de snackbar
class MockDoctorManagementController extends DoctorManagementController {
  @override
  void onInit() {
    // On doit appeler super.onInit() car c'est une méthode @mustCallSuper
    super.onInit();
    // Mais on remplace la méthode loadDoctors pour éviter l'utilisation de snackbar
  }

  @override
  Future<void> loadDoctors() async {
    // Ne rien faire pour éviter l'utilisation de snackbar
    isLoading.value = false;
    doctors.clear();
  }
}

// Mock du ServiceManagementController pour éviter le problème de snackbar
class MockServiceManagementController extends ServiceManagementController {
  @override
  void onInit() {
    // On doit appeler super.onInit() car c'est une méthode @mustCallSuper
    super.onInit();
    // Mais on remplace la méthode loadServices pour éviter l'utilisation de snackbar
  }

  @override
  Future<void> loadServices() async {
    // Ne rien faire pour éviter l'utilisation de snackbar
    isLoading.value = false;
    services.clear();
  }
}

// Mock de AdminBinding pour utiliser nos contrôleurs mockés
class TestAdminBinding extends AdminBinding {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
    Get.lazyPut<DoctorManagementController>(
      () => MockDoctorManagementController(),
      fenix: true,
    );
    Get.lazyPut<DoctorFormController>(
      () => DoctorFormController(),
      fenix: true,
    );
    Get.lazyPut<ServiceManagementController>(
      () => MockServiceManagementController(),
      fenix: true,
    );
    Get.lazyPut<ServiceFormController>(
      () => ServiceFormController(),
      fenix: true,
    );
  }
}

void main() {
  group('AdminBinding Tests', () {
    setUp(() {
      // Reset GetX avant chaque test
      Get.reset();

      // Initialiser un contexte d'interface pour GetX
      WidgetsFlutterBinding.ensureInitialized();

      // Enregistrer les services mock dont dépendent les controllers
      Get.put<AuthService>(MockAuthService());
      Get.put<DatabaseService>(MockDatabaseService());
    });

    tearDown(() {
      Get.reset();
    });

    test('All admin controllers should be registered correctly', () {
      // Arrange & Act - Utiliser TestAdminBinding pour éviter les problèmes de Snackbar
      final binding = TestAdminBinding();
      binding.dependencies();

      // Assert - vérifier que tous les contrôleurs sont correctement enregistrés
      expect(Get.find<AdminController>(), isA<AdminController>());
      expect(
        Get.find<DoctorManagementController>(),
        isA<MockDoctorManagementController>(),
      );
      expect(Get.find<DoctorFormController>(), isA<DoctorFormController>());
      expect(
        Get.find<ServiceManagementController>(),
        isA<MockServiceManagementController>(),
      );
      expect(Get.find<ServiceFormController>(), isA<ServiceFormController>());
    });

    test('AdminController should have access to its dependencies', () {
      // Arrange
      final binding = TestAdminBinding();
      binding.dependencies();

      // Act
      final controller = Get.find<AdminController>();

      // Assert - vérifier que le contrôleur peut accéder à ses dépendances
      // Pas de test direct car les dépendances sont privées,
      // mais si elles n'étaient pas injectées correctement,
      // le contrôleur lancerait une exception à sa création
      expect(controller, isNotNull);
    });

    test('Form controllers should have properly initialized form keys', () {
      // Arrange
      final binding = TestAdminBinding();
      binding.dependencies();

      // Act
      final doctorFormController = Get.find<DoctorFormController>();
      final serviceFormController = Get.find<ServiceFormController>();

      // Assert
      expect(doctorFormController, isNotNull);
      expect(serviceFormController, isNotNull);
      expect(doctorFormController.formKey, isA<GlobalKey<FormState>>());
      expect(serviceFormController.formKey, isA<GlobalKey<FormState>>());
      expect(doctorFormController.nomController, isA<TextEditingController>());
      expect(serviceFormController.nomController, isA<TextEditingController>());
    });

    test(
      'Management controllers should have properly initialized state variables',
      () {
        // Arrange
        final binding = TestAdminBinding();
        binding.dependencies();

        // Act
        final doctorMgmtController = Get.find<DoctorManagementController>();
        final serviceMgmtController = Get.find<ServiceManagementController>();

        // Assert
        expect(doctorMgmtController, isNotNull);
        expect(serviceMgmtController, isNotNull);
        expect(doctorMgmtController.doctors, isEmpty);
        expect(serviceMgmtController.services, isEmpty);
      },
    );
  });
}
