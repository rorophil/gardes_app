// Doctor management controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_model.dart';
import '../../../routes/app_routes.dart';

class DoctorManagementController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }
  
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
  
  void createDoctor() {
    Get.toNamed(AppRoutes.DOCTOR_FORM)?.then((_) => loadDoctors());
  }
  
  void editDoctor(Doctor doctor) {
    Get.toNamed(
      AppRoutes.DOCTOR_FORM,
      arguments: doctor,
    )?.then((_) => loadDoctors());
  }
  
  void deleteDoctor(Doctor doctor) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer le médecin ${doctor.nom} ${doctor.prenom}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                _databaseService.deleteDoctor(doctor);
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
