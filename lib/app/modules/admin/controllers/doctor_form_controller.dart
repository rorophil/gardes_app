/// Contrôleur pour le formulaire de création/modification des médecins
/// Gère la validation des données et la sauvegarde
import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:realm/realm.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_hive_model.dart';

class DoctorFormController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Contrôleurs de formulaire
  final formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  // Variables réactives pour les privilèges
  final RxBool isAnesthesiste = false.obs;
  final RxBool isPediatrique = false.obs;
  final RxBool isSamu = false.obs;
  final RxBool isIntensiviste = false.obs;

  // Variables réactives pour les paramètres de garde
  final RxInt maxGardesParMois = 10.obs;
  final RxInt joursMinEntreGardes = 3.obs;
  final RxList<String> joursIndisponibles = <String>[].obs;

  // État du formulaire
  final RxBool isEditing = false.obs;
  late Rx<DoctorHive?> currentDoctor = Rx<DoctorHive?>(null);

  @override
  void onInit() {
    super.onInit();

    // Vérifier si on est en mode édition
    if (Get.arguments != null && Get.arguments is DoctorHive) {
      isEditing.value = true;
      currentDoctor.value = Get.arguments as DoctorHive;
      _loadDoctorData();
    }
  }

  /// Charge les données du médecin en mode édition
  /// Remplit les champs du formulaire avec les données existantes
  void _loadDoctorData() {
    final doctor = currentDoctor.value;
    if (doctor != null) {
      nomController.text = doctor.nom;
      prenomController.text = doctor.prenom;
      loginController.text = doctor.login;
      passwordController.text =
          '********'; // Don't show actual password for security

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
    // Nettoyer les contrôleurs
    nomController.dispose();
    prenomController.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Valide qu'un champ obligatoire n'est pas vide
  /// [value] : La valeur à valider
  /// Retourne un message d'erreur ou null si valide
  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  /// Sauvegarde le médecin (création ou modification)
  /// Valide le formulaire et effectue l'opération appropriée
  Future<void> saveDoctor() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      if (isEditing.value && currentDoctor.value != null) {
        // Mode édition - mettre à jour le médecin existant
        final doctor = currentDoctor.value!;

        // Mise à jour des propriétés du docteur
        final updatedDoctor = DoctorHive(
          id: doctor.id,
          nom: nomController.text.trim(),
          prenom: prenomController.text.trim(),
          login: loginController.text.trim(),
          // Only update password if it was changed (not stars)
          password:
              passwordController.text != '********'
                  ? passwordController.text
                  : doctor.password,
          isAnesthesiste: isAnesthesiste.value,
          isPediatrique: isPediatrique.value,
          isSamu: isSamu.value,
          isIntensiviste: isIntensiviste.value,
          maxGardesParMois: maxGardesParMois.value,
          joursMinEntreGardes: joursMinEntreGardes.value,
          joursIndisponibles: joursIndisponibles,
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
          joursIndisponibles: joursIndisponibles,
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
