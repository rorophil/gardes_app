import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:gardes_app/app/data/models/doctor_model.dart';

void main() {
  late Doctor testDoctor;

  setUp(() {
    testDoctor = Doctor(
      ObjectId(),
      'Nom',
      'Prénom',
      'login',
      'password',
      true, // anesthésiste
      true, // pédiatrique
      false, // pas SAMU
      false, // pas intensiviste
      10, // max gardes
      2, // jours min entre gardes
      joursIndisponibles: ['2023-10-15', '2023-10-25', '2023-11-05'],
    );
  });

  group('Doctor Model Tests', () {
    test('should correctly report privilege status', () {
      expect(testDoctor.hasPrivilege(Privilege.anesthesiste), isTrue);
      expect(testDoctor.hasPrivilege(Privilege.pediatrique), isTrue);
      expect(testDoctor.hasPrivilege(Privilege.samu), isFalse);
      expect(testDoctor.hasPrivilege(Privilege.intensiviste), isFalse);
    });

    test('should correctly list privileges', () {
      final privileges = testDoctor.privileges;

      expect(privileges.length, equals(2));
      expect(privileges, contains(Privilege.anesthesiste));
      expect(privileges, contains(Privilege.pediatrique));
      expect(privileges.contains(Privilege.samu), isFalse);
      expect(privileges.contains(Privilege.intensiviste), isFalse);
    });

    test('should correctly check availability on dates', () {
      // Doctor is unavailable on these days
      expect(testDoctor.isAvailableOn(DateTime(2023, 10, 15)), isFalse);
      expect(testDoctor.isAvailableOn(DateTime(2023, 10, 25)), isFalse);
      expect(testDoctor.isAvailableOn(DateTime(2023, 11, 5)), isFalse);

      // But available on others
      expect(testDoctor.isAvailableOn(DateTime(2023, 10, 16)), isTrue);
      expect(testDoctor.isAvailableOn(DateTime(2023, 10, 24)), isTrue);
      expect(testDoctor.isAvailableOn(DateTime(2023, 11, 6)), isTrue);
    });

    test('should correctly determine if doctor can take shift', () {
      // Doctor is unavailable on these days
      expect(testDoctor.canTakeShiftOn(DateTime(2023, 10, 15)), isFalse);

      // And available on others
      expect(testDoctor.canTakeShiftOn(DateTime(2023, 10, 16)), isTrue);
    });
  });
}
