import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class QRCodeController extends GetxController {
  final qrTextController = TextEditingController();
  final emailController = TextEditingController();
  var qrBase64 = RxnString();
  var isLoading = false.obs;
  var saveSuccess = false.obs;

  Future<void> generateAndSaveQr(BuildContext context) async {
    final qrText = qrTextController.text.trim();
    final email = emailController.text.trim();
    if (qrText.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both QR Text and Email.')),
      );
      return;
    }
    isLoading.value = true;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODk1OTg0NTQ5Y2VlNGE4ZTIwMzBmOGQiLCJtb2JpbGUiOiI3ODc2NTU2Nzg5IiwiaWF0IjoxNzU0NjM0MzMyLCJleHAiOjE3NTUyMzkxMzJ9.FQcacRUYFQbFDBuXPSEs9m-lFx74MIjKPrkvBkJ6LRk',
    };
    var request = http.Request(
      'POST',
      Uri.parse('http://35.154.10.237:5000/api/generate-qr'),
    );
    request.body = json.encode({"email": email, "qrText": qrText});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var data = json.decode(await response.stream.bytesToString());
      qrBase64.value = data["qrCode"];
      // Now upload to Google Drive
      final uploadResult = await uploadQrToGoogleDrive(context);
      saveSuccess.value = uploadResult;
      if (uploadResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR code image saved to Google Drive!')),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/account_created');
        });
      }
    } else {
      qrBase64.value = null;
      saveSuccess.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.reasonPhrase}')),
      );
    }
    isLoading.value = false;
  }

  Future<bool> uploadQrToGoogleDrive(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "362120589511-nlbum7u5tucsivuf37153vh0bp47hivq.apps.googleusercontent.com",
        scopes: [drive.DriveApi.driveFileScope],
      );

      final account = await googleSignIn.signIn();
      if (account == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google sign-in cancelled.')));
        return false;
      }
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Prepare QR image bytes
      final base64Str = qrBase64.value;
      if (base64Str == null) return false;
      final bytes = base64Decode(base64Str.split(',').last);

      final media = drive.Media(Stream.value(bytes), bytes.length);
      final driveFile = drive.File();
      driveFile.name =
          'inochat_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      driveFile.mimeType = 'image/png';

      await driveApi.files.create(driveFile, uploadMedia: media);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Drive upload failed: $e')));
      return false;
    }
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
