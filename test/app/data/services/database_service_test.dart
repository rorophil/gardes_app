// filepath: /Users/philipperobert/development/codage en flutter/gardes_app/test/app/data/services/database_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';
import 'package:gardes_app/app/data/models/service_model.dart';

// Mock Realm for testing
class MockRealm extends Mock implements Realm {
  final List<Doctor> doctors = [];
  final List<Service> services = [];

  void addDoctor(Doctor doctor) {
    doctors.add(doctor);
  }

  void addService(Service service) {
    services.add(service);
  }
}

void main() {
  // Tests pour DatabaseService utilizing a mocked Realm instance

  // Note: These tests are minimal since we can't easily mock Realm
  // For better testing, we'd need dependency injection for the Realm instance

  test('DatabaseService helper functions should create objects correctly', () {
    // We can test at least the helper methods and factory functions

    final doctorId = ObjectId();
    final serviceId = ObjectId();

    // Create instances with the factory methods
    final doctor = Doctor(
      doctorId,
      'Nom',
      'Prénom',
      'login',
      'password',
      true,
      false,
      false,
      false,
      10,
      2,
    );

    final service = Service(
      serviceId,
      'Service Test',
      true,
      false,
      false,
      false,
    );

    // Verify properties were set correctly
    expect(doctor.id, equals(doctorId));
    expect(doctor.nom, equals('Nom'));
    expect(doctor.prenom, equals('Prénom'));
    expect(doctor.login, equals('login'));
    expect(doctor.password, equals('password'));
    expect(doctor.isAnesthesiste, isTrue);
    expect(doctor.isPediatrique, isFalse);

    expect(service.id, equals(serviceId));
    expect(service.nom, equals('Service Test'));
    expect(service.requiresAnesthesiste, isTrue);
    expect(service.requiresPediatrique, isFalse);
  });

  test('canDoctorWorkInService should correctly determine compatibility', () {
    // Create test objects
    final doctor = Doctor(
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

    final compatibleService = Service(
      ObjectId(),
      'Service Compatible',
      true, // requires anesthésiste
      false,
      false,
      false,
    );

    final incompatibleService = Service(
      ObjectId(),
      'Service Incompatible',
      false,
      true, // requires pédiatrique
      false,
      false,
    );

    // We can still test the helper function without a full DatabaseService instance
    final result1 = compatibleService.acceptsDoctor(doctor);
    final result2 = incompatibleService.acceptsDoctor(doctor);

    expect(result1, isTrue);
    expect(result2, isFalse);
  });
}
