/// Contrôleur pour la gestion des médecins dans l'interface d'administration
/// Gère la liste, création, modification et suppression des médecins
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_hive_model.dart';
import '../../../routes/app_routes.dart';

class DoctorManagementController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Variables réactives pour l'état de la liste
  final RxList<DoctorHive> doctors = <DoctorHive>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  /// Charge la liste des médecins depuis la base de données
  /// Met à jour l'interface utilisateur avec les données récupérées
  Future<void> loadDoctors() async {
    isLoading.value = true;
    try {
      doctors.value = _databaseService.getAllDoctors();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger la liste des médecins: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigue vers le formulaire de création d'un nouveau médecin
  /// Recharge la liste au retour pour afficher les modifications
  void createDoctor() {
    Get.toNamed(AppRoutes.DOCTOR_FORM)?.then((_) => loadDoctors());
  }

  /// Navigue vers le formulaire d'édition d'un médecin existant
  /// [doctor] : Le médecin à modifier
  /// Recharge la liste au retour pour afficher les modifications
  void editDoctor(DoctorHive doctor) {
    Get.toNamed(
      AppRoutes.DOCTOR_FORM,
      arguments: doctor,
    )?.then((_) => loadDoctors());
  }

  /// Affiche une boîte de dialogue de confirmation pour supprimer un médecin
  /// [doctor] : Le médecin à supprimer
  void deleteDoctor(DoctorHive doctor) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous vraiment supprimer le médecin ${doctor.nom} ${doctor.prenom}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                _databaseService.deleteDoctor(doctor.id);
                Get.back();
                loadDoctors();
                Get.snackbar(
                  'Succès',
                  'Le médecin a été supprimé avec succès',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Erreur',
                  'Impossible de supprimer le médecin: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
