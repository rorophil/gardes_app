// Doctor module controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/schedule_model.dart';
import '../../../data/models/service_model.dart';
import '../../../routes/app_routes.dart';

class DoctorController extends GetxController {
  final AuthService _authService;
  final DatabaseService _databaseService;

  final Rx<Doctor?> currentDoctor = Rx<Doctor?>(null);
  final RxList<Schedule> schedules = <Schedule>[].obs;

  DoctorController({AuthService? authService, DatabaseService? databaseService})
    : _authService = authService ?? Get.find<AuthService>(),
      _databaseService = databaseService ?? Get.find<DatabaseService>();
  // Cache des services pour affichage
  final RxMap<ObjectId, Service> servicesCache = RxMap<ObjectId, Service>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentDoctor.value = _authService.currentUser.value;
    loadServices();
    loadSchedules();
  }

  // Chargement des services pour les plannings
  Future<void> loadServices() async {
    final allServices = _databaseService.getAllServices();
    for (final service in allServices) {
      servicesCache[service.id] = service;
    }
  }

  Future<void> loadSchedules() async {
    if (currentDoctor.value == null) return;

    isLoading.value = true;
    try {
      // Utilisation de la méthode getSchedulesByDoctor au lieu de getDoctorSchedules
      schedules.value = _databaseService.getSchedulesByDoctor(
        currentDoctor.value!,
      );
      // S'assurer que les services sont chargés
      if (servicesCache.isEmpty) {
        await loadServices();
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les gardes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer un service par son ID
  Service? getServiceById(ObjectId serviceId) {
    if (servicesCache.containsKey(serviceId)) {
      return servicesCache[serviceId];
    }
    // Si non trouvé dans le cache, charger depuis la base de données
    final service = _databaseService.getService(serviceId);
    if (service != null) {
      servicesCache[serviceId] = service;
    }
    return service;
  }

  void goToAvailability() {
    Get.toNamed(AppRoutes.DOCTOR_AVAILABILITY);
  }

  void logout() {
    _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  // Group schedules by month for display
  Map<String, List<Schedule>> getSchedulesByMonth() {
    Map<String, List<Schedule>> result = {};

    for (final schedule in schedules) {
      final key = '${schedule.date.year}-${schedule.date.month}';
      if (!result.containsKey(key)) {
        result[key] = [];
      }
      result[key]!.add(schedule);
    }

    return result;
  }

  // Format month for display
  String formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);

    String monthName;
    switch (month) {
      case 1:
        monthName = 'Janvier';
        break;
      case 2:
        monthName = 'Février';
        break;
      case 3:
        monthName = 'Mars';
        break;
      case 4:
        monthName = 'Avril';
        break;
      case 5:
        monthName = 'Mai';
        break;
      case 6:
        monthName = 'Juin';
        break;
      case 7:
        monthName = 'Juillet';
        break;
      case 8:
        monthName = 'Août';
        break;
      case 9:
        monthName = 'Septembre';
        break;
      case 10:
        monthName = 'Octobre';
        break;
      case 11:
        monthName = 'Novembre';
        break;
      case 12:
        monthName = 'Décembre';
        break;
      default:
        monthName = 'Inconnu';
    }

    return '$monthName $year';
  }
}
