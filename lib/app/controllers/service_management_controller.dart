// Service management controller
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/services/database_service.dart';
import '../data/models/service_model.dart';
import '../routes/app_routes.dart';

class ServiceManagementController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final RxList<Service> services = <Service>[].obs;
  final RxBool isLoading = true.obs;
  
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
        'Impossible de charger la liste des services: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void createService() {
    Get.toNamed(AppRoutes.SERVICE_FORM)?.then((_) => loadServices());
  }
  
  void editService(Service service) {
    Get.toNamed(
      AppRoutes.SERVICE_FORM,
      arguments: service,
    )?.then((_) => loadServices());
  }
  
  void deleteService(Service service) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Voulez-vous vraiment supprimer le service ${service.nom}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              try {
                _databaseService.deleteService(service);
                Get.back();
                loadServices();
                Get.snackbar(
                  'Succès',
                  'Le service a été supprimé avec succès',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  'Erreur',
                  'Impossible de supprimer le service: ${e.toString()}',
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
  
  void manageBlockedDays(Service service) {
    // This will be implemented in another view
    Get.toNamed(
      AppRoutes.SERVICE_FORM,
      arguments: {'service': service, 'blockedDays': true},
    )?.then((_) => loadServices());
  }
}
