// Doctor form controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:realm/realm.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_model.dart';

class DoctorFormController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  
  final RxBool isAnesthesiste = false.obs;
  final RxBool isPediatrique = false.obs;
  final RxBool isSamu = false.obs;
  final RxBool isIntensiviste = false.obs;
  
  final RxInt maxGardesParMois = 10.obs;
  final RxInt joursMinEntreGardes = 3.obs;
  final RxList<String> joursIndisponibles = <String>[].obs;
  
  final RxBool isEditing = false.obs;
  late Rx<Doctor?> currentDoctor = Rx<Doctor?>(null);
  
  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null && Get.arguments is Doctor) {
      isEditing.value = true;
      currentDoctor.value = Get.arguments as Doctor;
      _loadDoctorData();
    }
  }
  
  void _loadDoctorData() {
    final doctor = currentDoctor.value;
    if (doctor != null) {
      nomController.text = doctor.nom;
      prenomController.text = doctor.prenom;
      loginController.text = doctor.login;
      passwordController.text = '********'; // Don't show actual password for security
      
      isAnesthesiste.value = doctor.isAnesthesiste;
      isPediatrique.value = doctor.isPediatrique;
      isSamu.value = doctor.isSamu;
      isIntensiviste.value = doctor.isIntensiviste;
      
      maxGardesParMois.value = doctor.maxGardesParMois;
      joursMinEntreGardes.value = doctor.joursMinEntreGardes;
      joursIndisponibles.value = doctor.joursIndisponibles.toList();
    }
  }
  
  @override
  void onClose() {
    nomController.dispose();
    prenomController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }
  
  Future<void> saveDoctor() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      if (isEditing.value && currentDoctor.value != null) {
        // Update doctor
        final doctor = currentDoctor.value!;
        
        // Mise à jour des propriétés du docteur
        final updatedDoctor = Doctor(
          doctor.id,
          nomController.text.trim(),
          prenomController.text.trim(),
          loginController.text.trim(),
          // Only update password if it was changed (not stars)
          passwordController.text != '********' ? passwordController.text : doctor.password,
          isAnesthesiste.value,
          isPediatrique.value,
          isSamu.value,
          isIntensiviste.value,
          maxGardesParMois.value,
          joursMinEntreGardes.value,
          joursIndisponibles: joursIndisponibles
        );
        
        _databaseService.updateDoctor(updatedDoctor);
        
        Get.back();
        Get.snackbar(
          'Succès',
          'Médecin mis à jour avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Create new doctor
        _databaseService.createDoctor(
          nom: nomController.text.trim(),
          prenom: prenomController.text.trim(),
          login: loginController.text.trim(),
          password: passwordController.text,
          isAnesthesiste: isAnesthesiste.value,
          isPediatrique: isPediatrique.value,
          isSamu: isSamu.value,
          isIntensiviste: isIntensiviste.value,
          maxGardesParMois: maxGardesParMois.value,
          joursMinEntreGardes: joursMinEntreGardes.value,
          joursIndisponibles: joursIndisponibles
        );
        
        Get.back();
        Get.snackbar(
          'Succès',
          'Médecin créé avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le médecin: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
