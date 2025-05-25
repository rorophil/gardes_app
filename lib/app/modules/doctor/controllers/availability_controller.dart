// Doctor availability controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:realm/realm.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_model.dart';

class AvailabilityController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final Rx<Doctor?> currentDoctor = Rx<Doctor?>(null);
  
  final RxList<String> unavailableDays = <String>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  
  @override
  void onInit() {
    super.onInit();
    currentDoctor.value = _authService.currentUser.value;
    if (currentDoctor.value != null) {
      unavailableDays.value = currentDoctor.value!.joursIndisponibles.toList();
    }
  }
  
  void toggleDateAvailability(DateTime date) {
    if (currentDoctor.value == null) return;
    
    String dateString = _formatDateForStorage(date);
    List<String> updatedUnavailableDays = [...unavailableDays];
    
    // Mise à jour de la liste locale
    if (updatedUnavailableDays.contains(dateString)) {
      updatedUnavailableDays.remove(dateString);
    } else {
      updatedUnavailableDays.add(dateString);
    }
    
    // Création d'une nouvelle instance de Doctor avec les jours indisponibles mis à jour
    final doctor = currentDoctor.value!;
    final updatedDoctor = Doctor(
      doctor.id,
      doctor.nom,
      doctor.prenom,
      doctor.login,
      doctor.password,
      doctor.isAnesthesiste,
      doctor.isPediatrique,
      doctor.isSamu,
      doctor.isIntensiviste,
      doctor.maxGardesParMois,
      doctor.joursMinEntreGardes,
      joursIndisponibles: updatedUnavailableDays
    );
    
    // Mise à jour du docteur dans la base de données
    _databaseService.updateDoctor(updatedDoctor);
    
    // Mise à jour du docteur courant et de la liste locale
    currentDoctor.value = updatedDoctor;
    unavailableDays.value = updatedUnavailableDays;
    
    Get.snackbar(
      'Mise à jour',
      'Disponibilité mise à jour pour le ${_formatDateForDisplay(date)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
  
  bool isDateUnavailable(DateTime date) {
    String dateString = _formatDateForStorage(date);
    return unavailableDays.contains(dateString);
  }
  
  String _formatDateForStorage(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  String _formatDateForDisplay(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
  
  void changeMonth(int year, int month) {
    selectedYear.value = year;
    selectedMonth.value = month;
  }
}
