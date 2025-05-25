// Admin controller
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
//import '../../../data/services/database_service.dart';
import '../../../routes/app_routes.dart';

class AdminController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  //final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  void logout() {
    _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
  
  void goToDoctorManagement() {
    Get.toNamed(AppRoutes.DOCTOR_MANAGEMENT);
  }
  
  void goToServiceManagement() {
    Get.toNamed(AppRoutes.SERVICE_MANAGEMENT);
  }
  
  void goToScheduleGeneration() {
    Get.toNamed(AppRoutes.SCHEDULE_GENERATION);
  }
  
  void goToScheduleView() {
    Get.toNamed(AppRoutes.SCHEDULE_VIEW);
  }
}
