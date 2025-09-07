// Schedule module binding
import 'package:get/get.dart';
import '../controllers/schedule_generation_controller.dart';
import '../controllers/schedule_view_controller.dart';

/// Liaison pour le module de planification
///
/// Cette classe configure l'injection de dépendances pour tous les contrôleurs
/// du module schedule. Elle initialise les contrôleurs de génération et de
/// visualisation des plannings de garde.
class ScheduleBinding extends Bindings {
  /// Configure l'injection de dépendances pour le module schedule
  ///
  /// Injecte paresseusement les contrôleurs suivants :
  /// - [ScheduleGenerationController] : génération des plannings
  /// - [ScheduleViewController] : affichage des plannings
  @override
  void dependencies() {
    Get.lazyPut<ScheduleGenerationController>(
      () => ScheduleGenerationController(),
      fenix: true,
    );
    Get.lazyPut<ScheduleViewController>(
      () => ScheduleViewController(),
      fenix: true,
    );
  }
}
