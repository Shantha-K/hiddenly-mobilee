import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  var isLoading = false.obs;

  Future<void> signUp() async {
    isLoading.value = true;
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('http://35.154.10.237:5000/api//sign-up'),
    );
    request.body = json.encode({
      "mobile": mobileController.text,
      "name": nameController.text,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    isLoading.value = false;
    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString());
      if (data["otp"] != null) {
        // Store userId in local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data["userId"] ?? '');

        Get.snackbar('Success', 'OTP sent successfully: ${data["otp"]}');

        Get.toNamed(
          AppRoutes.VERIFY,
          arguments: {
            "otp": data["otp"],
            "deviceId": data["deviceId"],
            "userId": data["userId"],
            "name": data["name"],
            "mobile": mobileController.text,
            "isNewUser": true, // <- New user flag
          },
        );
      } else {
        Get.snackbar('Error', 'OTP not received');
      }
    } else {
      Get.snackbar('Error', response.reasonPhrase ?? 'Unknown error');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
