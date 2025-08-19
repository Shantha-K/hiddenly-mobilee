import 'package:get/get.dart';

class PrivacyController extends GetxController {
  var lastSeen = "Everyone".obs;
  var profilePhoto = "Everyone".obs;
  var about = "Everyone".obs;
  var status = "My contacts".obs;
  var groups = "Everyone".obs;
  var blockedContacts = "None".obs;

  void updateOption(String key, String value) {
    switch (key) {
      case "Last seen":
        lastSeen.value = value;
        break;
      case "Profile photo":
        profilePhoto.value = value;
        break;
      case "About":
        about.value = value;
        break;
      case "Status":
        status.value = value;
        break;
      case "Groups":
        groups.value = value;
        break;
      case "Blocked contacts":
        blockedContacts.value = value;
        break;
    }
  }
}
