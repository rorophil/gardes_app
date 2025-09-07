/// Contrôleur principal du module d'administration
/// Gère la navigation et les actions principales du tableau de bord admin
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
//import '../../../data/services/database_service.dart';
import '../../../routes/app_routes.dart';

class AdminController extends GetxController {
  final AuthService _authService;
  //final DatabaseService _databaseService = Get.find<DatabaseService>();

  /// Constructeur avec injection de dépendance pour AuthService
  /// [authService] : Service d'authentification (optionnel, utilise Get.find par défaut)
  AdminController({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>();

  /// Déconnecte l'administrateur et redirige vers la page de connexion
  void logout() {
    _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  /// Navigue vers la page de gestion des médecins
  void goToDoctorManagement() {
    Get.toNamed(AppRoutes.DOCTOR_MANAGEMENT);
  }

  /// Navigue vers la page de gestion des services
  void goToServiceManagement() {
    Get.toNamed(AppRoutes.SERVICE_MANAGEMENT);
  }

  /// Navigue vers la page de génération des plannings
  void goToScheduleGeneration() {
    Get.toNamed(AppRoutes.SCHEDULE_GENERATION);
  }

  /// Navigue vers la page de visualisation des plannings
  void goToScheduleView() {
    Get.toNamed(AppRoutes.SCHEDULE_VIEW);
  }
}
