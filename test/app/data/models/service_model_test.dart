// filepath: /Users/philipperobert/development/codage en flutter/gardes_app/test/app/data/models/service_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/models/service_model.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';

void main() {
  late Service testService;
  late Doctor anesthesisteDoctor;
  late Doctor pediatriqueDoctor;
  late Doctor samuDoctor;

  setUp(() {
    testService = Service(
      ObjectId(),
      'Service Test',
      true, // requires anesthésiste
      false, // ne requiert pas pédiatrique
      true, // requires SAMU
      false, // ne requiert pas intensiviste
      joursBloquees: ['2023-10-25', '2023-12-25'],
    );

    anesthesisteDoctor = Doctor(
      ObjectId(),
      'Anesthésiste',
      'Docteur',
      'login',
      'password',
      true, // anesthésiste
      false, // pas pédiatrique
      false, // pas SAMU
      false, // pas intensiviste
      10,
      2,
    );

    pediatriqueDoctor = Doctor(
      ObjectId(),
      'Pédiatrique',
      'Docteur',
      'login',
      'password',
      false, // pas anesthésiste
      true, // pédiatrique
      false, // pas SAMU
      false, // pas intensiviste
      10,
      2,
    );

    samuDoctor = Doctor(
      ObjectId(),
      'SAMU',
      'Docteur',
      'login',
      'password',
      false, // pas anesthésiste
      false, // pas pédiatrique
      true, // SAMU
      false, // pas intensiviste
      10,
      2,
    );
  });

  group('Service Model Tests', () {
    test('should correctly list required privileges', () {
      final privileges = testService.privileges;

      expect(privileges.length, equals(2));
      expect(privileges, contains(Privilege.anesthesiste));
      expect(privileges, contains(Privilege.samu));
      expect(privileges.contains(Privilege.pediatrique), isFalse);
      expect(privileges.contains(Privilege.intensiviste), isFalse);
    });

    test('should correctly check if a date is blocked', () {
      // These dates are blocked
      expect(testService.isDateBlocked(DateTime(2023, 10, 25)), isTrue);
      expect(testService.isDateBlocked(DateTime(2023, 12, 25)), isTrue);

      // These dates are not blocked
      expect(testService.isDateBlocked(DateTime(2023, 10, 26)), isFalse);
      expect(testService.isDateBlocked(DateTime(2023, 12, 24)), isFalse);
    });

    test('should correctly determine if a doctor can work in the service', () {
      // Anesthesiologist doctors can work in this service
      expect(testService.acceptsDoctor(anesthesisteDoctor), isTrue);

      // SAMU doctors can also work in this service
      expect(testService.acceptsDoctor(samuDoctor), isTrue);

      // Pediatric doctors cannot work in this service
      expect(testService.acceptsDoctor(pediatriqueDoctor), isFalse);
    });
  });
}
