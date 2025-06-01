// Schedule generation controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/schedule_service.dart';
import '../../../data/models/service_model.dart';
//import '../../../data/models/schedule_model.dart';
import '../../../routes/app_routes.dart';

class ScheduleGenerationController extends GetxController {
  //final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final ScheduleService _scheduleService = Get.find<ScheduleService>();
  
  final RxList<Service> services = <Service>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGenerating = false.obs;
  
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxList<Service> selectedServices = <Service>[].obs;
  
  final RxString generationStatus = ''.obs;
  
  Function(int year, int month, List<Service> services)? navigateToScheduleView;
  
  @override
  void onInit() {
    super.onInit();
    loadServices();
  }
  
  Future<void> loadServices() async {
    isLoading.value = true;
    try {
      services.value = _databaseService.getAllServices();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les services: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void toggleServiceSelection(Service service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
  }
  
  void changeMonth(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
  }
  
  Future<void> generateSchedules() async {
    if (selectedServices.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner au moins un service',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isGenerating.value = true;
    generationStatus.value = 'Préparation de la génération...';
    
    try {
      int processedServices = 0;
      
      for (final service in selectedServices) {
        generationStatus.value = 'Génération pour ${service.nom} (${processedServices + 1}/${selectedServices.length})';
        
        await _scheduleService.generateMonthlySchedule(
          service, 
          selectedYear.value, 
          selectedMonth.value
        );
        
        processedServices++;
        generationStatus.value = 'Terminé: ${service.nom} ($processedServices/${selectedServices.length})';
        
        // Small delay to update the UI
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      Get.snackbar(
        'Succès',
        'Planning généré avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Navigate to schedule view
      if (navigateToScheduleView != null) {
        navigateToScheduleView!(selectedYear.value, selectedMonth.value, selectedServices.take(3).toList());
      } else {
        Get.toNamed(AppRoutes.SCHEDULE_VIEW, arguments: {
          'year': selectedYear.value,
          'month': selectedMonth.value,
          'services': selectedServices.take(3).toList(),
        });
      }
      
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de générer le planning: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }
  
  String getMonthName(int month) {
    switch (month) {
      case 1: return 'Janvier';
      case 2: return 'Février';
      case 3: return 'Mars';
      case 4: return 'Avril';
      case 5: return 'Mai';
      case 6: return 'Juin';
      case 7: return 'Juillet';
      case 8: return 'Août';
      case 9: return 'Septembre';
      case 10: return 'Octobre';
      case 11: return 'Novembre';
      case 12: return 'Décembre';
      default: return '';
    }
  }
}
