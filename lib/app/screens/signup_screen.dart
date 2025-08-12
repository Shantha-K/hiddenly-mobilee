// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/signup_controller.dart';

// class SignupScreen extends StatelessWidget {
//   final SignupController controller = Get.put(SignupController());

// ignore_for_file: library_private_types_in_public_api

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 80,
//               width: 80,
//               decoration: BoxDecoration(
//                 color: Colors.blue[900],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Center(
//                 child: Text(
//                   'IC',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Inochat',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue[900],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Welcome To InoChat!',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 24),
//             TextField(
//               controller: controller.nameController,
//               decoration: InputDecoration(
//                 hintText: 'Name',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: controller.mobileController,
//               decoration: InputDecoration(
//                 hintText: 'Mobile Number',
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 24),
//             Obx(
//               () => ElevatedButton(
//                 onPressed: controller.isLoading.value
//                     ? null
//                     : controller.signUp,
//                 child: controller.isLoading.value
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text('Sign up'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 48),
//                   backgroundColor: Colors.blue[400],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextButton(
//               onPressed: () {
//                 Get.toNamed('/signin');
//               },
//               child: Text('Already have an account? Sign in'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final SignupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SignupController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFe0f7fa), Color(0xFF80deea)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'IC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Inochat',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome To Inochat!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.nameController,
                      onChanged: (val) => controller.name.value = val,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                        LengthLimitingTextInputFormatter(30),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Balji',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
                        hintText: '7759125826',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.signUp,
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap:
                          controller.isLoading.value ? null : () => Get.toNamed('/signin'),
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.black54),
                          children: [
                            TextSpan(
                              text: 'Sign in',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
