import 'package:get/get.dart';
import 'package:inochat/app/core/cache_service.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    final CacheService _cacheService = CacheService();

    String? userId = await _cacheService.getUserId();

    print('User ID: $userId');

    if (userId != null && userId.isNotEmpty) {
      await Future.delayed(Duration(seconds: 3));
      //Get.offNamed(AppRoutes.HOME);
      Get.offNamed(AppRoutes.HOME);
    } else {
      await Future.delayed(Duration(seconds: 3));
      Get.offNamed(AppRoutes.SIGNIN);
    }
  }
}
