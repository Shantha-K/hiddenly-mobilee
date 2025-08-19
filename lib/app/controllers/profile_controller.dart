import 'dart:typed_data';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // Dummy values (replace with API integration)
  var name = "Balaji Govindaraj".obs;
  var about = "Life is about continuous learning and grow".obs;
  var phone = "+91 9876543210".obs;
  var photo = Rx<Uint8List?>(null);

  void updateName(String newName) {
    name.value = newName;
  }

  void updateAbout(String newAbout) {
    about.value = newAbout;
  }

  void updatePhoto(Uint8List? newPhoto) {
    photo.value = newPhoto;
  }

  void deleteAccount() {
    // Call API for account deletion
    Get.snackbar("Deleted", "Your account has been deleted.");
  }
}
