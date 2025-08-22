import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:inochat/app/widgets/message_modal.dart';

class GroupchatController extends GetxController {
  final CacheService _cacheService = CacheService();
  final TextEditingController messageController = TextEditingController();

  var messages = <ChatMessage>[].obs;
  var isSending = false.obs;
  var isLoading = false.obs;

  var groupId = ''.obs;
  var groupName = ''.obs;
  var selectedContacts = <dynamic>[].obs;

  String? myMobileNumber;

  final String sendMessageUrl =
      "http://35.154.10.237:5000/api/group/sendMessage";
  final String getMessagesUrl =
      "http://35.154.10.237:5000/api/group/getGroupmessages";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    groupId.value = args['groupId'];
    groupName.value = args['groupName'];
    selectedContacts.value = args['selectedContacts'] ?? [];
    _loadMyNumber();
    fetchMessages();

    
  }

  Future<void> _loadMyNumber() async {
    myMobileNumber = await _cacheService.getMyMobileNumber();
  }

  /// Fetch messages
  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(getMessagesUrl));
      request.body = json.encode({
        "groupId": groupId.value,
        "sender": myMobileNumber,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var data = json.decode(body);
        print("Fetched messages: $data");
        if (data["messages"] != null) {
          messages.value = List<ChatMessage>.from(
            data["messages"].map(
              (msg) => ChatMessage.fromJson(msg, myMobileNumber ?? ""),
            ),
          );
        }
      } else {
        print("Error fetching messages: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception while fetching messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Send message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    isSending.value = true;
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST', Uri.parse(sendMessageUrl));
      request.body = json.encode({
        "groupId": groupId.value,
        "sender": myMobileNumber,
        "content": messageController.text,
        "messageType": "text",
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        var body = await response.stream.bytesToString();
        var data = json.decode(body);
        print("Message sent successfully: ${data['data']}");
      } else {
        print("Error sending message: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception while sending message: $e");
    } finally {
      isSending.value = false;
    }
  }
}
