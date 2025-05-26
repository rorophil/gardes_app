// Admin binding
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/doctor_management_controller.dart';
import '../controllers/doctor_form_controller.dart';
import '../controllers/service_management_controller.dart';
import '../controllers/service_form_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(
      () => AdminController(),
      fenix: true,
    );
    Get.lazyPut<DoctorManagementController>(
      () => DoctorManagementController(),
      fenix: true,
    );
    Get.lazyPut<DoctorFormController>(
      () => DoctorFormController(),
      fenix: true,
    );
    Get.lazyPut<ServiceManagementController>(
      () => ServiceManagementController(),
      fenix: true,
    );
    Get.lazyPut<ServiceFormController>(
      () => ServiceFormController(),
      fenix: true,
    );
  }
}
