import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:inochat/app/controllers/settings_controller.dart';

class SettingsBindng extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
    
  }

}