// ignore: dangling_library_doc_comments
/// Gestionnaire d'injection de dépendances pour l'application
/// Initialise et configure tous les services nécessaires au démarrage
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/schedule_service.dart';

class DependencyInjection {
  /// Initialise tous les services de l'application
  /// Doit être appelée au démarrage de l'application avant l'affichage de l'UI
  static Future<void> init() async {
    // Initialiser les services dans l'ordre de dépendance
    await Get.putAsync(
      () => DatabaseService().init(),
    ); // Service base de données (asynchrone)
    Get.put(AuthService()); // Service d'authentification
    Get.put(ScheduleService()); // Service de planification
  }
}
