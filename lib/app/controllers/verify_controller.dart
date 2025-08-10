import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class VerifyController extends GetxController {
  final otpControllers = List.generate(4, (_) => TextEditingController());
  var isLoading = false.obs;
  var otp = ''.obs;
  var mobile = ''.obs;
  var deviceId = ''.obs;
  var userId = ''.obs;
  var name = ''.obs;
  var isNewUser = false; // Flag to decide navigation
  bool lastVerifySuccess = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      otp.value = args['otp']?.toString() ?? '';
      mobile.value = args['mobile']?.toString() ?? '';
      deviceId.value = args['deviceId']?.toString() ?? '';
      userId.value = args['userId']?.toString() ?? '';
      name.value = args['name']?.toString() ?? '';
      isNewUser = args['isNewUser'] ?? false;
    }

    // Always clear OTP fields for manual entry
    for (var c in otpControllers) {
      c.clear();
    }
  }

  String get enteredOtp => otpControllers.map((c) => c.text).join();

  Future<void> resendOtp() async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse('http://35.154.10.237:5000/api//resend-otp'),
      );
      request.body = json.encode({"mobile": mobile.value});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());
        if (data["message"] == "OTP resent") {
          otp.value = data["otp"]?.toString() ?? '';
          Get.snackbar('OTP Sent', 'New OTP: ${otp.value}');
        } else {
          Get.snackbar('Error', data["message"] ?? 'Failed to resend OTP');
        }
      } else {
        Get.snackbar('Error', response.reasonPhrase ?? 'Unknown error');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}');
    }
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;
    lastVerifySuccess = false;

    // Show alert dialog while verifying
    Get.defaultDialog(
      title: 'Verifying OTP',
      middleText: 'Please wait...',
      barrierDismissible: false,
    );

    await Future.delayed(Duration(seconds: 10));
    Get.back(); // Close the dialog

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('http://35.154.10.237:5000/api//verify-otp'),
    );
    request.body = json.encode({"mobile": mobile.value, "otp": enteredOtp});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    isLoading.value = false;

    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString());
      if (data["message"] == "Sign in successful") {
        lastVerifySuccess = true;
        Get.snackbar('Success', 'OTP verified successfully');
      } else {
        lastVerifySuccess = false;
        Get.snackbar('Error', data["message"] ?? 'Invalid OTP');
      }
    } else {
      lastVerifySuccess = false;
      Get.snackbar('Error', response.reasonPhrase ?? 'Unknown error');
    }
  }

  @override
  void onClose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    super.onClose();
  }
}
