import 'package:get/get.dart';
import 'package:inochat/app/controllers/contacts/group_controller.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
