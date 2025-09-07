/// Liaison des dépendances pour le module d'administration
/// Configure l'injection de tous les contrôleurs nécessaires à l'administration
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/doctor_management_controller.dart';
import '../controllers/doctor_form_controller.dart';
import '../controllers/service_management_controller.dart';
import '../controllers/service_form_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Contrôleur principal d'administration (réutilisable avec fenix)
    Get.lazyPut<AdminController>(() => AdminController(), fenix: true);
    // Contrôleur de gestion des médecins (réutilisable avec fenix)
    Get.lazyPut<DoctorManagementController>(
      () => DoctorManagementController(),
      fenix: true,
    );
    // Contrôleur de formulaire médecin
    Get.lazyPut<DoctorFormController>(
      () => DoctorFormController(),
      fenix: true,
    );
    // Contrôleur de gestion des services (réutilisable avec fenix)
    Get.lazyPut<ServiceManagementController>(
      () => ServiceManagementController(),
      fenix: true,
    );
    // Contrôleur de formulaire service
    Get.lazyPut<ServiceFormController>(
      () => ServiceFormController(),
      fenix: true,
    );
  }
}
