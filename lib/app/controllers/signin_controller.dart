import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignInController extends GetxController {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  var isLoading = false.obs;
  String? userId;
  String? serverOtp;

  void signIn(BuildContext context) async {
    final mobile = mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid mobile number.')),
      );
      return;
    }
    isLoading.value = true;
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse('http://35.154.10.237:5000/api/sign-in'),
      );
      request.body = json.encode({"mobile": mobile});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = json.decode(respStr);

        if (data['message'] == "OTP sent for login" && data['userId'] != null) {
          userId = data['userId'];
          serverOtp = data['otp']?.toString();

          Get.toNamed(
            '/verify',
            arguments: {
              'mobile': mobile,
              'userId': userId,
              'otp': serverOtp,
              'isNewUser': false, // <- Existing user
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign in failed. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignUp() {
    Get.toNamed('/signup');
  }

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
