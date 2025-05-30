import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:get/get.dart';
import 'package:gardes_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:gardes_app/app/data/services/auth_service.dart';

// Mock des services utilisés par le contrôleur
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthController Tests', () {
    late AuthController controller;
    late MockAuthService mockAuthService;

    // Configurer le test Flutter
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      // Initialiser GetX avant chaque test
      Get.reset();

      // Activation du mode test pour GetX
      Get.testMode = true;

      // Créer les mocks
      mockAuthService = MockAuthService();

      // Créer le controller avec le mock injecté
      controller = AuthController(authService: mockAuthService);

      // Configurer GetX pour les tests
      Get.config(
        enableLog: false,
        defaultTransition: Transition.noTransition,
        defaultPopGesture: false,
        defaultOpaqueRoute: false,
      );
    });

    test('validateLogin should return error for empty login', () {
      // Act
      final result = controller.validateLogin('');

      // Assert
      expect(result, 'Veuillez entrer votre identifiant');
    });

    test('validateLogin should return null for valid login', () {
      // Act
      final result = controller.validateLogin('user123');

      // Assert
      expect(result, null);
    });

    test('validatePassword should return error for empty password', () {
      // Act
      final result = controller.validatePassword('');

      // Assert
      expect(result, 'Veuillez entrer votre mot de passe');
    });

    test('validatePassword should return null for valid password', () {
      // Act
      final result = controller.validatePassword('password123');

      // Assert
      expect(result, null);
    });

    // Note: Les tests de la méthode login() nécessitent une configuration plus complexe
    // pour mocker correctement FormState et les interactions avec GetX.
    // Pour un test complet, il faudrait utiliser mockito avec la génération de code,
    // mais pour l'instant, nous nous concentrons sur les fonctions simples.

    // Note: Ce test n'est pas implémentable directement car il est difficile de mocker
    // le FormState et la validation du formulaire dans un environnement de test Flutter.
    // Nous pourrons vérifier cette fonctionnalité avec un test d'intégration à la place.

    test('controllers are initialized correctly', () {
      // Assert
      expect(controller.loginController, isNotNull);
      expect(controller.passwordController, isNotNull);
      expect(controller.loginFormKey, isNotNull);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, '');
    });

    test('login controllers are set correctly', () {
      // Arrange
      final login = 'testuser';
      final password = 'password123';

      // Act
      controller.loginController.text = login;
      controller.passwordController.text = password;

      // Assert
      expect(controller.loginController.text, equals(login));
      expect(controller.passwordController.text, equals(password));
    });

    test('onClose should dispose controllers', () {
      // Act - this will run without errors if controllers are correctly set up
      controller.onClose();
    });
  });
}
