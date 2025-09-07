/// Liaison des dépendances pour le module d'authentification
/// Configure l'injection des contrôleurs nécessaires à l'authentification
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Injection paresseuse du contrôleur d'authentification
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
