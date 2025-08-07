import 'package:get/get.dart';
import '../controllers/account_created_controller.dart';

class AccountCreatedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountCreatedController>(() => AccountCreatedController());
  }
}
