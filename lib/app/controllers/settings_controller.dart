import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Example: You can add observable variables for settings here
  final RxBool notificationsEnabled = true.obs;

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }

  // Add navigation methods for each settings tile
  void onProfileTap() {
    // Navigate to profile screen
    // Get.toNamed('/profile');
  }

  void onAccountsTap() {
    // Navigate to accounts screen
    // Get.toNamed('/accounts');
  }

  void onNotificationsTap() {
    // Navigate to notifications settings
    // Get.toNamed('/notifications');
  }

  void onHelpTap() {
    // Navigate to help screen
    // Get.toNamed('/help');
  }
}
