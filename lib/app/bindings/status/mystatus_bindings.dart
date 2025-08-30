import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:inochat/app/controllers/status/mystatus_controller.dart';

class MystatusBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MystatusController>(() => MystatusController());
  }
}
