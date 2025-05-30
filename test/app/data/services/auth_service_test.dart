// filepath: /Users/philipperobert/development/codage en flutter/gardes_app/test/app/data/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gardes_app/app/data/services/auth_service.dart';
import 'package:gardes_app/app/data/services/database_service.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';

// Créer une implémentation simple du DatabaseService pour les tests
class MockDatabaseService extends GetxService implements DatabaseService {
  final List<Doctor> _mockDoctors = [];

  void addDoctor(Doctor doctor) {
    _mockDoctors.add(doctor);
  }

  @override
  List<Doctor> getAllDoctors() => _mockDoctors;

  @override
  Future<DatabaseService> init() async => this;

  @override
  void close() {}

  // Les méthodes qui ne sont pas utilisées dans les tests peuvent retourner des valeurs par défaut
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      // Reset GetX avant chaque test
      Get.reset();

      // Initialiser le mock et l'enregistrer dans GetX
      mockDatabaseService = MockDatabaseService();
      Get.put<DatabaseService>(mockDatabaseService);

      // Créer le service d'authentification qui utilisera le mock
      authService = AuthService();
    });

    tearDown(() {
      Get.reset();
    });

    test(
      'login devrait retourner true pour les identifiants admin valides',
      () async {
        // Act
        final result = await authService.login('admin', 'admin123');

        // Assert
        expect(result, isTrue);
        expect(authService.isAdminLoggedIn, isTrue);
        expect(authService.currentRole.value, equals(UserRole.admin));
      },
    );

    test(
      'login devrait retourner false pour des identifiants admin invalides',
      () async {
        // Act
        final result = await authService.login('admin', 'mauvaisMotDePasse');

        // Assert
        expect(result, isFalse);
        expect(authService.isAdminLoggedIn, isFalse);
      },
    );

    test(
      'login devrait retourner true pour des identifiants médecin valides',
      () async {
        // Arrange
        final testDoctor = Doctor(
          ObjectId(), // id
          'Dupont', // nom
          'Jean', // prenom
          'jdupont', // login
          'password123', // password
          true, // isAnesthesiste
          false, // isPediatrique
          true, // isSamu
          false, // isIntensiviste
          5, // maxGardesParMois
          2, // joursMinEntreGardes
        );
        mockDatabaseService.addDoctor(testDoctor);

        // Act
        final result = await authService.login('jdupont', 'password123');

        // Assert
        expect(result, isTrue);
        expect(authService.isLoggedIn, isTrue);
        expect(authService.isAdminLoggedIn, isFalse);
        expect(authService.currentRole.value, equals(UserRole.doctor));
        expect(authService.currentUser.value?.nom, equals('Dupont'));
      },
    );

    test(
      'login devrait retourner false pour des identifiants médecin invalides',
      () async {
        // Arrange
        final testDoctor = Doctor(
          ObjectId(), // id
          'Dupont', // nom
          'Jean', // prenom
          'jdupont', // login
          'password123', // password
          true, // isAnesthesiste
          false, // isPediatrique
          true, // isSamu
          false, // isIntensiviste
          5, // maxGardesParMois
          2, // joursMinEntreGardes
        );
        mockDatabaseService.addDoctor(testDoctor);

        // Act
        final result = await authService.login('jdupont', 'mauvaisMotDePasse');

        // Assert
        expect(result, isFalse);
        expect(authService.isLoggedIn, isFalse);
      },
    );

    test('logout devrait effacer la session utilisateur', () async {
      // Arrange - D'abord connectons un utilisateur admin
      await authService.login('admin', 'admin123');
      expect(
        authService.isAdminLoggedIn,
        isTrue,
      ); // Vérification de la configuration de test

      // Act
      authService.logout();

      // Assert
      expect(authService.isLoggedIn, isFalse);
      expect(authService.isAdminLoggedIn, isFalse);
      expect(authService.currentUser.value, isNull);
      expect(
        authService.currentRole.value,
        equals(UserRole.doctor),
      ); // Retour au rôle par défaut
    });

    test(
      'méthodes de permission devraient fonctionner correctement pour admin',
      () async {
        // Arrange
        await authService.login('admin', 'admin123');

        // Assert
        expect(authService.canManageDoctors(), isTrue);
        expect(authService.canManageServices(), isTrue);
        expect(authService.canGenerateSchedules(), isTrue);
        expect(authService.canEditUnavailability(), isTrue);
        expect(authService.canViewSchedules(), isTrue);
      },
    );

    test(
      'méthodes de permission devraient fonctionner correctement pour médecin',
      () async {
        // Arrange
        final testDoctor = Doctor(
          ObjectId(), // id
          'Dupont', // nom
          'Jean', // prenom
          'jdupont', // login
          'password123', // password
          true, // isAnesthesiste
          false, // isPediatrique
          true, // isSamu
          false, // isIntensiviste
          5, // maxGardesParMois
          2, // joursMinEntreGardes
        );
        mockDatabaseService.addDoctor(testDoctor);
        await authService.login('jdupont', 'password123');

        // Assert
        expect(authService.canManageDoctors(), isFalse);
        expect(authService.canManageServices(), isFalse);
        expect(authService.canGenerateSchedules(), isFalse);
        expect(authService.canEditUnavailability(), isTrue);
        expect(authService.canViewSchedules(), isTrue);
      },
    );

    test(
      'méthodes de permission devraient retourner false lorsque non connecté',
      () {
        // Arrange - assurons-nous qu'aucun utilisateur n'est connecté
        authService.logout();
        expect(
          authService.isLoggedIn,
          isFalse,
        ); // Vérification de la configuration de test

        // Assert
        expect(authService.canManageDoctors(), isFalse);
        expect(authService.canManageServices(), isFalse);
        expect(authService.canGenerateSchedules(), isFalse);
        expect(authService.canEditUnavailability(), isFalse);
        expect(authService.canViewSchedules(), isFalse);
      },
    );
  });
}
