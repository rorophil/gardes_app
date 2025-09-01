/// Service de génération de plannings de garde
/// Gère la création automatique et optimisée des plannings mensuels
import 'package:get/get.dart';

import '../models/doctor_hive_model.dart';
import '../models/service_hive_model.dart';
import '../models/schedule_hive_model.dart';
import 'database_service.dart';

class ScheduleService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  /// Génère un planning mensuel pour un service spécifique
  /// [service] : Le service pour lequel générer le planning
  /// [year] : L'année du planning
  /// [month] : Le mois du planning (1-12)
  /// Retourne une liste des plannings générés
  Future<List<ScheduleHive>> generateMonthlySchedule(
    ServiceHive service,
    int year,
    int month,
  ) async {
    List<ScheduleHive> schedules = [];
    List<DoctorHive> eligibleDoctors = _getEligibleDoctors(service);

    if (eligibleDoctors.isEmpty) {
      return schedules;
    }

    // Trier les médecins par nombre de jours indisponibles (plus indisponible en premier)
    eligibleDoctors.sort(
      (a, b) =>
          b.joursIndisponibles.length.compareTo(a.joursIndisponibles.length),
    );

    // Create a list of dates for the month
    List<DateTime> dates = _getDatesInMonth(year, month);

    // Sort dates by priority (Fridays, weekends, then other days, with Thursdays last)
    dates.sort((a, b) {
      int priorityA = _getDatePriority(a);
      int priorityB = _getDatePriority(b);
      return priorityA.compareTo(priorityB);
    });

    // Try to assign doctors to dates
    for (DateTime date in dates) {
      // Skip if date is blocked for this service
      if (service.isDateBlocked(date)) {
        continue;
      }

      // Find eligible doctors for this date
      List<DoctorHive> availableDoctors = _getAvailableDoctorsForDate(
        eligibleDoctors,
        date,
        schedules,
      );

      if (availableDoctors.isNotEmpty) {
        // Sort by the number of shifts already assigned for this weekday (least first)
        availableDoctors.sort((a, b) {
          int shiftsA = _countShiftsByWeekday(a, date.weekday);
          int shiftsB = _countShiftsByWeekday(b, date.weekday);
          return shiftsA.compareTo(shiftsB);
        });

        // Assign first available doctor
        DoctorHive doctor = availableDoctors.first;
        ScheduleHive schedule = await _databaseService.createSchedule(
          doctorId: doctor.id,
          serviceId: service.id,
          date: date,
        );
        schedules.add(schedule);
      }
    }

    return schedules;
  }

  // =============== MÉTHODES AUXILIAIRES ===============

  /// Récupère les médecins éligibles pour un service
  /// [service] : Le service pour lequel filtrer les médecins
  /// Retourne une liste des médecins ayant les privilèges requis
  List<DoctorHive> _getEligibleDoctors(ServiceHive service) {
    List<DoctorHive> allDoctors = _databaseService.getAllDoctors();
    return allDoctors.where((doctor) => service.acceptsDoctor(doctor)).toList();
  }

  /// Génère la liste des dates d'un mois
  /// [year] : L'année
  /// [month] : Le mois (1-12)
  /// Retourne une liste des dates du mois
  List<DateTime> _getDatesInMonth(int year, int month) {
    List<DateTime> dates = [];

    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0); // Dernier jour du mois

    for (int i = 0; i < end.day; i++) {
      DateTime date = start.add(Duration(days: i));
      dates.add(date);
    }

    return dates;
  }

  /// Détermine la priorité d'une date pour l'assignation des gardes
  /// [date] : La date à évaluer
  /// Retourne un entier représentant la priorité (0 = priorité maximale)
  int _getDatePriority(DateTime date) {
    if (date.weekday == DateTime.friday) return 0; // Priorité maximale
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday)
      return 1;
    if (date.weekday == DateTime.thursday) return 3; // Priorité minimale
    return 2; // Autres jours de la semaine
  }

  /// Récupère les médecins disponibles pour une date donnée
  /// [doctors] : Liste des médecins éligibles
  /// [date] : Date pour laquelle vérifier la disponibilité
  /// [currentSchedules] : Plannings déjà assignés
  /// Retourne une liste des médecins disponibles
  List<DoctorHive> _getAvailableDoctorsForDate(
    List<DoctorHive> doctors,
    DateTime date,
    List<ScheduleHive> currentSchedules,
  ) {
    return doctors.where((doctor) {
      // Vérifier si le médecin est disponible à cette date
      if (!doctor.isAvailableOn(date)) return false;

      // Vérifier si le médecin a déjà une garde ce jour dans les plannings actuels
      bool hasShiftOnDay = currentSchedules.any(
        (schedule) =>
            schedule.doctorId == doctor.id &&
            schedule.date.year == date.year &&
            schedule.date.month == date.month &&
            schedule.date.day == date.day,
      );

      if (hasShiftOnDay) return false;

      // Check minimum days between shifts
      for (final schedule in currentSchedules.where(
        (s) => s.doctorId == doctor.id,
      )) {
        int daysBetween =
            (schedule.date.difference(date).inHours / 24).abs().round();
        if (daysBetween < doctor.joursMinEntreGardes) {
          return false;
        }
      }

      // Check if the doctor has reached maximum shifts for this month
      int shiftsInMonth =
          currentSchedules
              .where(
                (s) =>
                    s.doctorId == doctor.id &&
                    s.date.year == date.year &&
                    s.date.month == date.month,
              )
              .length;

      return shiftsInMonth < doctor.maxGardesParMois;
    }).toList();
  }

  int _countShiftsByWeekday(DoctorHive doctor, int weekday) {
    List<ScheduleHive> doctorSchedules = _databaseService.getSchedulesByDoctor(
      doctor,
    );
    return doctorSchedules.where((s) => s.date.weekday == weekday).length;
  }

  // Swap doctors between two schedules
  Future<void> swapDoctors(
    ScheduleHive schedule1,
    ScheduleHive schedule2,
  ) async {
    String tempDoctorId = schedule1.doctorId;

    schedule1.doctorId = schedule2.doctorId;
    await _databaseService.updateSchedule(schedule1);

    schedule2.doctorId = tempDoctorId;
    await _databaseService.updateSchedule(schedule2);
  }

  // Change doctor for a specific schedule
  Future<void> changeDoctor(ScheduleHive schedule, DoctorHive newDoctor) async {
    schedule.doctorId = newDoctor.id;
    await _databaseService.updateSchedule(schedule);
  }
}
