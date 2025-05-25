// Doctor binding
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/availability_controller.dart';

class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorController>(
      () => DoctorController(),
    );
    Get.lazyPut<AvailabilityController>(
      () => AvailabilityController(),
      fenix: true,
    );
  }
}
