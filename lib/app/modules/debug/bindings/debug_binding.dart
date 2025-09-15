/// Binding pour l'injection de dépendances du module de debug
import 'package:get/get.dart';
import '../controllers/hive_debug_controller.dart';

class DebugBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HiveDebugController>(() => HiveDebugController());
  }
}
