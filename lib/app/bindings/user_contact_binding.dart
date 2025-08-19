// lib/app/bindings/user_contacts_binding.dart

import 'package:get/get.dart';
import 'package:inochat/app/controllers/user_contact_controller.dart';

class UserContactsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserContactsController>(() => UserContactsController());
  }
}
