/// Contrôleur pour la vue de visualisation et gestion des plannings
/// Gère l'affichage interactif des plannings avec drag & drop
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/schedule_service.dart';
import '../../../data/models/service_hive_model.dart';
import '../../../data/models/doctor_hive_model.dart';
import '../../../data/models/schedule_hive_model.dart';

class ScheduleViewController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  // Variables réactives pour les données affichées
  final RxList<ServiceHive> services = <ServiceHive>[].obs;
  final RxList<ServiceHive> displayedServices = <ServiceHive>[].obs;
  final RxList<DoctorHive> availableDoctors = <DoctorHive>[].obs;

  // Variables réactives pour la période sélectionnée
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  // Carte contenant les plannings pour chaque service
  final Rx<Map<String, List<ScheduleHive>>> schedulesByService =
      Rx<Map<String, List<ScheduleHive>>>({});

  // Drag and drop state
  final Rx<ScheduleHive?> draggedSchedule = Rx<ScheduleHive?>(null);
  final Rx<DoctorHive?> draggedDoctor = Rx<DoctorHive?>(null);

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('year')) {
        selectedYear.value = args['year'] as int;
      }
      if (args.containsKey('month')) {
        selectedMonth.value = args['month'] as int;
      }
      if (args.containsKey('services') &&
          args['services'] is List<ServiceHive>) {
        displayedServices.value =
            (args['services'] as List<ServiceHive>).toList();
      }
    }

    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      // Load all services
      services.value = _databaseService.getAllServices();

      // If no services are selected for display, use the first 3
      if (displayedServices.isEmpty) {
        displayedServices.value = services.take(3).toList();
      }

      await loadSchedules();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSchedules() async {
    final Map<String, List<ScheduleHive>> result = {};

    final startDate = DateTime(selectedYear.value, selectedMonth.value, 1);
    final endDate = DateTime(selectedYear.value, selectedMonth.value + 1, 0);

    for (final service in displayedServices) {
      final schedules = _databaseService.getSchedulesByService(
        service,
        startDate,
        endDate,
      );
      result[service.id] = schedules;
    }

    schedulesByService.value = result;

    // Load available doctors for the selected services
    loadAvailableDoctors();
  }

  void loadAvailableDoctors() {
    final List<DoctorHive> allDoctors = _databaseService.getAllDoctors();

    // If we have displayed services, filter doctors who can work in at least one of them
    if (displayedServices.isNotEmpty) {
      availableDoctors.value =
          allDoctors.where((doctor) {
            return displayedServices.any(
              (service) => _canDoctorWorkInService(doctor, service),
            );
          }).toList();
    } else {
      availableDoctors.value = allDoctors;
    }

    // Sort alphabetically by name
    availableDoctors.sort((a, b) => a.nom.compareTo(b.nom));
  }

  // Helper method to check if a doctor can work in a service
  bool _canDoctorWorkInService(DoctorHive doctor, ServiceHive service) {
    // Un docteur peut travailler dans un service s'il a au moins un des privilèges requis
    if (service.requiresAnesthesiste && doctor.isAnesthesiste) return true;
    if (service.requiresPediatrique && doctor.isPediatrique) return true;
    if (service.requiresSamu && doctor.isSamu) return true;
    if (service.requiresIntensiviste && doctor.isIntensiviste) return true;

    return false;
  }

  void changeDisplayedServices(List<ServiceHive> newServices) {
    displayedServices.value = newServices;
    loadSchedules();
  }

  void changeMonth(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
    loadSchedules();
  }

  // Find a schedule for a specific day in a service
  ScheduleHive? getScheduleForDay(ServiceHive service, int day) {
    final serviceSchedules = schedulesByService.value[service.id];
    if (serviceSchedules == null) return null;

    final date = DateTime(selectedYear.value, selectedMonth.value, day);

    return serviceSchedules.firstWhereOrNull(
      (schedule) =>
          schedule.date.year == date.year &&
          schedule.date.month == date.month &&
          schedule.date.day == date.day,
    );
  }

  // Récupérer un Doctor par son ID
  DoctorHive? getDoctorById(String doctorId) {
    // Rechercher d'abord dans la liste des médecins disponibles
    DoctorHive? doctor = availableDoctors.firstWhereOrNull(
      (d) => d.id == doctorId,
    );

    // Si non trouvé, rechercher dans la base de données
    doctor ??= _databaseService.getDoctorById(doctorId);

    return doctor;
  }

  // Handle drag and drop operations
  void startDragSchedule(ScheduleHive schedule) {
    draggedSchedule.value = schedule;
  }

  void startDragDoctor(DoctorHive doctor) {
    draggedDoctor.value = doctor;
  }

  void endDrag() {
    draggedSchedule.value = null;
    draggedDoctor.value = null;
  }

  bool acceptScheduleDrop(ServiceHive targetService, int day) {
    if (draggedSchedule.value == null) return false;

    //final date = DateTime(selectedYear.value, selectedMonth.value, day);

    // Check if the target date has a schedule
    final targetSchedule = getScheduleForDay(targetService, day);

    return targetSchedule != null;
  }

  void completeScheduleDrop(ServiceHive targetService, int day) {
    if (draggedSchedule.value == null) return;

    final sourceSchedule = draggedSchedule.value!;
    final targetSchedule = getScheduleForDay(targetService, day);

    if (targetSchedule != null) {
      // Swap doctors between schedules using the updated method
      _scheduleService.swapDoctors(sourceSchedule, targetSchedule);
      loadSchedules();
    }

    endDrag();
  }

  bool acceptDoctorDrop(ServiceHive targetService, int day) {
    if (draggedDoctor.value == null) return false;

    final doctor = draggedDoctor.value!;

    // Check if the doctor can work in this service using our helper
    if (!_canDoctorWorkInService(doctor, targetService)) return false;

    // Check if the target date has a schedule
    final targetSchedule = getScheduleForDay(targetService, day);

    // Simplified check - just check if there's a schedule
    return targetSchedule != null;
  }

  void completeDoctorDrop(ServiceHive targetService, int day) {
    if (draggedDoctor.value == null) return;

    final doctor = draggedDoctor.value!;
    final targetSchedule = getScheduleForDay(targetService, day);

    if (targetSchedule != null) {
      // Change the doctor in the schedule using the updated method
      _scheduleService.changeDoctor(targetSchedule, doctor);
      loadSchedules();
    }

    endDrag();
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Janvier';
      case 2:
        return 'Février';
      case 3:
        return 'Mars';
      case 4:
        return 'Avril';
      case 5:
        return 'Mai';
      case 6:
        return 'Juin';
      case 7:
        return 'Juillet';
      case 8:
        return 'Août';
      case 9:
        return 'Septembre';
      case 10:
        return 'Octobre';
      case 11:
        return 'Novembre';
      case 12:
        return 'Décembre';
      default:
        return '';
    }
  }

  String getDayOfWeek(int day) {
    final date = DateTime(selectedYear.value, selectedMonth.value, day);
    switch (date.weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mer';
      case DateTime.thursday:
        return 'Jeu';
      case DateTime.friday:
        return 'Ven';
      case DateTime.saturday:
        return 'Sam';
      case DateTime.sunday:
        return 'Dim';
      default:
        return '';
    }
  }
}
