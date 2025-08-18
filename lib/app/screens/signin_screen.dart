// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/signin_controller.dart';

// ignore: use_key_in_widget_constructors
class SignInScreen extends StatelessWidget {
  final SignInController controller = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF6FF), Color(0xFFB6E0FE)],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 24),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.grey[700],
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'IC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Inochat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Welcome To Inochat!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.7),
                  //     borderRadius: BorderRadius.circular(8),
                  //     border: Border.all(color: Colors.blue[100]!, width: 2),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.only(left: 12, top: 8),
                  //         child: Text(
                  //           textAlign: TextAlign.center,
                  //           'Mobile Number',
                  //           style: TextStyle(
                  //             color: Colors.grey[700],
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ),
                  //       TextField(
                  //         controller: controller.mobileController,
                  //         keyboardType: TextInputType.phone,
                  //         decoration: InputDecoration(
                  //           border: InputBorder.none,
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //             vertical: 8,
                  //           ),
                  //           hintText: 'enter your mobile number',
                  //         ),
                  //       ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller.mobileController,
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => controller.mobile.value = val,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.blueAccent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.signIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Do't have an account? ",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      GestureDetector(
                        onTap: () => controller.goToSignUp(),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
