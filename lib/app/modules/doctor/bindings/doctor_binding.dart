/// Liaison des dépendances pour le module médecin
/// Configure l'injection des contrôleurs nécessaires aux fonctionnalités médecin
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/availability_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    // Contrôleur principal du module médecin
    Get.lazyPut<DoctorController>(() => DoctorController());
    // Contrôleur de gestion des disponibilités (réutilisable avec fenix)
    Get.lazyPut<AvailabilityController>(
      () => AvailabilityController(),
      fenix: true,
    );
  }
}
