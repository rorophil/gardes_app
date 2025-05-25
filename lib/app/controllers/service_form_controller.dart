// Service form controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:realm/realm.dart';
import '../data/services/database_service.dart';
import '../data/models/service_model.dart';
//import '../data/models/doctor_model.dart';

class ServiceFormController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  
  final RxBool requiresAnesthesiste = false.obs;
  final RxBool requiresPediatrique = false.obs;
  final RxBool requiresSamu = false.obs;
  final RxBool requiresIntensiviste = false.obs;
  
  final RxBool isEditing = false.obs;
  final RxBool isBlockedDaysMode = false.obs;
  
  late Rx<Service?> currentService = Rx<Service?>(null);
  
  // For blocked days
  final RxList<String> blockedDays = <String>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      if (Get.arguments is Service) {
        isEditing.value = true;
        currentService.value = Get.arguments as Service;
        _loadServiceData();
      } else if (Get.arguments is Map) {
        final args = Get.arguments as Map;
        if (args.containsKey('service')) {
          isEditing.value = true;
          currentService.value = args['service'] as Service;
          _loadServiceData();
          
          if (args.containsKey('blockedDays') && args['blockedDays'] == true) {
            isBlockedDaysMode.value = true;
          }
        }
      }
    }
  }
  
  void _loadServiceData() {
    final service = currentService.value;
    if (service != null) {
      nomController.text = service.nom;
      
      requiresAnesthesiste.value = service.requiresAnesthesiste;
      requiresPediatrique.value = service.requiresPediatrique;
      requiresSamu.value = service.requiresSamu;
      requiresIntensiviste.value = service.requiresIntensiviste;
      
      blockedDays.value = service.joursBloquees.toList();
    }
  }
  
  @override
  void onClose() {
    nomController.dispose();
    super.onClose();
  }
  
  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }
  
  Future<void> saveService() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      if (isEditing.value && currentService.value != null) {
        // Update service
        final service = currentService.value!;
        
        // Création d'un nouvel objet Service avec les valeurs mises à jour
        final updatedService = Service(
          service.id,
          nomController.text.trim(),
          requiresAnesthesiste.value,
          requiresPediatrique.value,
          requiresSamu.value,
          requiresIntensiviste.value,
          joursBloquees: blockedDays
        );
        
        // Mise à jour du service dans la base de données
        _databaseService.updateService(updatedService);
        
        Get.back();
        Get.snackbar(
          'Succès',
          'Service mis à jour avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new service
        _databaseService.createService(
          nom: nomController.text.trim(),
          requiresAnesthesiste: requiresAnesthesiste.value,
          requiresPediatrique: requiresPediatrique.value,
          requiresSamu: requiresSamu.value,
          requiresIntensiviste: requiresIntensiviste.value,
          joursBloquees: blockedDays
        );
        
        Get.back();
        Get.snackbar(
          'Succès',
          'Service créé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le service: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Methods for blocked days management
  void toggleDateBlock(DateTime date) {
    String dateString = _formatDateForBlocking(date);
    
    if (blockedDays.contains(dateString)) {
      blockedDays.remove(dateString);
    } else {
      blockedDays.add(dateString);
    }
    
    // Si on est en mode édition, mettre à jour la liste de jours bloqués immédiatement
    if (isEditing.value && currentService.value != null) {
      final updatedService = Service(
        currentService.value!.id,
        currentService.value!.nom,
        currentService.value!.requiresAnesthesiste,
        currentService.value!.requiresPediatrique,
        currentService.value!.requiresSamu,
        currentService.value!.requiresIntensiviste,
        joursBloquees: blockedDays
      );
      
      _databaseService.updateService(updatedService);
    }
  }
  
  bool isDateBlocked(DateTime date) {
    return blockedDays.contains(_formatDateForBlocking(date));
  }
  
  String _formatDateForBlocking(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  void changeMonth(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
  }
}
