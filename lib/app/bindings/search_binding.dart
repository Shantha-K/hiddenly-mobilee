// lib/app/bindings/user_contacts_binding.dart

import 'package:get/get.dart';
import 'package:inochat/app/controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}
