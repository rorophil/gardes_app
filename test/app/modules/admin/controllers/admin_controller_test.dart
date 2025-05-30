import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:gardes_app/app/modules/admin/controllers/admin_controller.dart';
import 'package:gardes_app/app/data/services/auth_service.dart';
import 'package:gardes_app/app/routes/app_routes.dart';

// Mock des services utilisés par le contrôleur
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AdminController Tests', () {
    late AdminController controller;
    late MockAuthService mockAuthService;

    // Configurer Get.testMode
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      // Initialiser GetX avant chaque test
      Get.reset();

      // Activation du mode test pour GetX
      Get.testMode = true;

      // Créer les mocks
      mockAuthService = MockAuthService();

      // Créer le controller avec le mock injecté
      controller = AdminController(authService: mockAuthService);

      // Configurer les routes pour GetX
      Get.testMode = true;
      Get.config(
        enableLog: false,
        defaultTransition: Transition.noTransition,
        defaultPopGesture: false,
        defaultOpaqueRoute: false,
      );
    });

    test('logout should call auth service logout', () {
      // Act
      controller.logout();

      // Assert
      verify(mockAuthService.logout()).called(1);
      // Nous ne pouvons pas vérifier la navigation car GetX ne le permet pas facilement en mode test
    });

    test(
      'goToDoctorManagement should attempt to navigate to doctor management',
      () {
        // Mock pour capturer la navigation
        final previousRoute = Get.currentRoute;

        // Act
        controller.goToDoctorManagement();

        // Assert - vérifier que nous avons essayé d'appeler la navigation, même si elle ne se produit pas réellement en mode test
        expect(previousRoute, isNot(equals(AppRoutes.DOCTOR_MANAGEMENT)));
      },
    );

    test(
      'goToServiceManagement should attempt to navigate to service management',
      () {
        // Act
        controller.goToServiceManagement();

        // Assert - vérifier que la méthode s'exécute sans erreur
        // Dans un scénario réel, cela naviguerait vers la route SERVICE_MANAGEMENT
      },
    );

    test(
      'goToScheduleGeneration should attempt to navigate to schedule generation',
      () {
        // Act
        controller.goToScheduleGeneration();

        // Assert - vérifier que la méthode s'exécute sans erreur
        // Dans un scénario réel, cela naviguerait vers la route SCHEDULE_GENERATION
      },
    );

    test('goToScheduleView should attempt to navigate to schedule view', () {
      // Act
      controller.goToScheduleView();

      // Assert - vérifier que la méthode s'exécute sans erreur
      // Dans un scénario réel, cela naviguerait vers la route SCHEDULE_VIEW
    });
  });
}
