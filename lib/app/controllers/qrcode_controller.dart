import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';

class QRCodeController extends GetxController {
  final qrTextController = TextEditingController();
  final emailController = TextEditingController();
  var qrBase64 = RxnString();
  var isLoading = false.obs;
  var saveSuccess = false.obs;

  final String androidServerClientId =
      '796190196521-bf7jaabnai769a3dn8qdak4qoihh6tb3.apps.googleusercontent.com';

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() async {
    GoogleSignIn(
      clientId: androidServerClientId,
      scopes: ['email', drive.DriveApi.driveFileScope],
    );
    debugPrint("Google Sign-In initialized");
  }

  Future<void> generateAndSaveQr(BuildContext context) async {
    final qrText = qrTextController.text.trim();
    final email = emailController.text.trim();

    if (qrText.isEmpty || email.isEmpty) {
      _showSnack(context, 'Please enter both QR Text and Email.');
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('http://35.154.10.237:5000/api/generate-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODk2ZTgxM2IxNDI0YTdhNGIxOWQ1NWYiLCJtb2JpbGUiOiI5ODc2NTQzNjYiLCJpYXQiOjE3NTQ3MjAzMzEsImV4cCI6MTc1NTMyNTEzMX0.8Y2X04qARp5WrKIDdeEqW19sRBsahujmeWD49rJtiec',
        },
        body: json.encode({"email": email, "qrText": qrText}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        qrBase64.value = data["qrCode"];
        final uploaded = await uploadQrToGoogleDrive(context);
        if (uploaded) {
          Get.offAllNamed('/account_created');
        } else {
          _showSnack(context, 'Failed to save QR to Google Drive');
        }
      } else {
        _showSnack(context, 'Failed to generate QR');
      }
    } catch (e) {
      _showSnack(context, 'Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadQrToGoogleDrive(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn(
        scopes: [drive.DriveApi.driveFileScope],
      );

      // Sign in the user
      final account = await googleSignIn.signIn();
      if (account == null) {
        _showSnack(context, 'Google sign-in cancelled.');
        return false;
      }

      // Get auth headers
      final headers = await account.authHeaders;
      final authClient = GoogleAuthClient(headers);
      final driveApi = drive.DriveApi(authClient);

      if (qrBase64.value == null || !qrBase64.value!.startsWith('data:image')) {
        _showSnack(context, 'Invalid QR code data');
        return false;
      }

      final base64Data = qrBase64.value!.split(',').last;
      final bytes = base64.decode(base64Data);

      final media = drive.Media(Stream.value(bytes), bytes.length);
      final driveFile = drive.File()
        ..name = 'inochat_qr_${DateTime.now().millisecondsSinceEpoch}.png'
        ..mimeType = 'image/png';

      await driveApi.files.create(driveFile, uploadMedia: media);
      return true;
    } catch (e) {
      print('Google Drive error: $e');
      _showSnack(context, 'Google Drive error: $e');
      return false;
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
