// filepath: /Users/philipperobert/development/codage en flutter/gardes_app/test/app/data/models/schedule_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gardes_app/app/data/models/schedule_model.dart';
import 'package:realm/realm.dart';

void main() {
  group('Schedule Model Tests', () {
    late ObjectId scheduleId;
    late ObjectId doctorId;
    late ObjectId serviceId;
    late DateTime testDate;

    setUp(() {
      scheduleId = ObjectId();
      doctorId = ObjectId();
      serviceId = ObjectId();
      testDate = DateTime(2025, 5, 30); // Un vendredi
    });

    test('Schedule model should be correctly initialized', () {
      final schedule = Schedule(scheduleId, doctorId, serviceId, testDate);

      expect(schedule.id, scheduleId);
      expect(schedule.doctorId, doctorId);
      expect(schedule.serviceId, serviceId);
      expect(schedule.date, testDate);
    });

    test('isWeekend should correctly identify weekend days', () {
      // Tester pour un jour de semaine (vendredi)
      final weekdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 30), // Vendredi
      );
      expect(weekdaySchedule.isWeekend(), false);

      // Tester pour le samedi
      final saturdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 31), // Samedi
      );
      expect(saturdaySchedule.isWeekend(), true);

      // Tester pour le dimanche
      final sundaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 6, 1), // Dimanche
      );
      expect(sundaySchedule.isWeekend(), true);
    });

    test('isFriday should correctly identify Friday', () {
      // Tester pour un vendredi
      final fridaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 30), // Vendredi
      );
      expect(fridaySchedule.isFriday(), true);

      // Tester pour un autre jour
      final nonFridaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 29), // Jeudi
      );
      expect(nonFridaySchedule.isFriday(), false);
    });

    test('isThursday should correctly identify Thursday', () {
      // Tester pour un jeudi
      final thursdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 29), // Jeudi
      );
      expect(thursdaySchedule.isThursday(), true);

      // Tester pour un autre jour
      final nonThursdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 30), // Vendredi
      );
      expect(nonThursdaySchedule.isThursday(), false);
    });

    test('priority should return correct values based on day of week', () {
      // Vendredi (priorité 1 - la plus haute)
      final fridaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 30), // Vendredi
      );
      expect(fridaySchedule.priority, 1);

      // Week-end (priorité 2)
      final weekendSchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 31), // Samedi
      );
      expect(weekendSchedule.priority, 2);

      // Jour de semaine normal (priorité 3)
      final weekdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 28), // Mercredi
      );
      expect(weekdaySchedule.priority, 3);

      // Jeudi (priorité 4 - la plus basse)
      final thursdaySchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        DateTime(2025, 5, 29), // Jeudi
      );
      expect(thursdaySchedule.priority, 4);
    });

    test('copyWith should create a new instance with specified changes', () {
      final originalSchedule = Schedule(
        scheduleId,
        doctorId,
        serviceId,
        testDate,
      );

      // Créer une nouvelle instance avec un nouveau doctorId
      final newDoctorId = ObjectId();
      final modifiedSchedule = originalSchedule.copyWith(doctorId: newDoctorId);

      // Vérifier que les valeurs sont correctement copiées/modifiées
      expect(modifiedSchedule.id, scheduleId); // Inchangé
      expect(modifiedSchedule.doctorId, newDoctorId); // Modifié
      expect(modifiedSchedule.serviceId, serviceId); // Inchangé
      expect(modifiedSchedule.date, testDate); // Inchangé

      // Vérifier que l'instance originale n'est pas modifiée
      expect(originalSchedule.doctorId, doctorId);
    });
  });
}
