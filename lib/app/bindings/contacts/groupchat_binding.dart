import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:inochat/app/controllers/contacts/groupchat_controller.dart';

class GroupchatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupchatController>(() => GroupchatController());
  }
}
