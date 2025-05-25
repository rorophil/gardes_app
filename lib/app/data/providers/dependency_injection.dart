// Dependency initialization
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/schedule_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize services
    await Get.putAsync(() => DatabaseService().init());
    Get.put(AuthService());
    Get.put(ScheduleService());
  }
}
