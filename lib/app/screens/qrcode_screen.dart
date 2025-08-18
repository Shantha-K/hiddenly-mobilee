import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../controllers/qrcode_controller.dart';

class QRCodeScreen extends StatelessWidget {
  final QRCodeController controller = Get.put(QRCodeController());

  QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                SizedBox(height: 8),
                Text(
                  'QR CODE',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Please write any text or word to create your QR Code.'),
                SizedBox(height: 24),
                TextField(
                  controller: controller.qrTextController,
                  decoration: InputDecoration(
                    hintText: 'QR Text',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    hintText: 'Email ID',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          // Show loading indicator immediately
                          controller.isLoading.value = true;

                          try {
                            await controller.generateAndSaveQr(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          } finally {
                            controller.isLoading.value = false;
                          }
                        },
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Submit'),
                ),
                if (controller.qrBase64.value != null) ...[
                  SizedBox(height: 32),
                  Text(
                    'Your QR Code:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Image.memory(
                    base64Decode(controller.qrBase64.value!.split(',').last),
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ],
                if (controller.saveSuccess.value) ...[
                  SizedBox(height: 16),
                  Text(
                    'QR code image saved to Google Drive!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
