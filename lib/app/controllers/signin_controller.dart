import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignInController extends GetxController {
  final mobileController = TextEditingController();
  var isLoading = false.obs;

  void signIn(BuildContext context) async {
    final mobile = mobileController.text.trim();
    if (mobile.isEmpty || mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid mobile number.')),
      );
      return;
    }
    isLoading.value = true;
    await Future.delayed(Duration(seconds: 1)); // Simulate API call
    isLoading.value = false;
    // Navigate to next screen (replace with your flow)
    Get.offAllNamed('/verify');
  }

  void goToSignUp() {
    Get.toNamed('/signup');
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
