// lib/app/controllers/chat_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';

class ChatController extends GetxController {
  var chats = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final String apiUrl = "http://35.154.10.237:5000/api/chats";

  /// Fetch chats from API
  Future<void> fetchChats() async {
    try {
      isLoading.value = true;

      // Get mobile number dynamically from cache
      final String? mobileNumber = await CacheService().getMyMobileNumber();

      if (mobileNumber == null) {
        print("⚠️ No mobile number found in cache");
        isLoading.value = false;
        return;
      }

      var headers = {'Content-Type': 'application/json'};

      var request = http.Request('POST', Uri.parse(apiUrl));
      request.body = json.encode({"mobile": mobileNumber});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String data = await response.stream.bytesToString();
        final parsed = json.decode(data);

        if (parsed["chats"] != null) {
          chats.value = List<Map<String, dynamic>>.from(parsed["chats"]);
        }
      } else {
        print("❌ Error: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("❌ Exception while fetching chats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }
}
