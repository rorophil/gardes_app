// Schedule module binding
import 'package:get/get.dart';
import '../controllers/schedule_generation_controller.dart';
import '../controllers/schedule_view_controller.dart';

class ScheduleBinding extends Bindings {
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
