// lib/app/controllers/contacts/chat_detail_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;

class ChatDetailController extends GetxController {
  // Keep Contact object directly
  var contact = Rxn<Contact>();

  // messages is a list of maps returned by server or locally added
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // API details (token from your snippet)
  final String messagesApi = 'http://35.154.10.237:5000/api/chat/message';
  final Map<String, String> headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4OTcyMWI1NzNlYWQ1OWMxMDUxNWYyNSIsIm1vYmlsZSI6IjcyODM4NjM1MDMiLCJuYW1lIjoiU2hhbnRoYSBWZW51Z29wYWxhcGEiLCJpYXQiOjE3NTQ3MzUwNjQsImV4cCI6MTc1NzMyNzA2NH0.W9u_s2J6V68zbwxlkQ2VzWWcu5olQYubcC7mTOesTwg',
  };

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Contact) {
      contact.value = arg;
    } else {
      contact.value = Contact(displayName: 'Unknown');
    }

    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final resp = await http.get(Uri.parse(messagesApi), headers: headers);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);

        // Expecting data['messages'] to be a list of objects/maps
        if (data != null && data['messages'] is List) {
          // normalize to list<Map<String,dynamic>>
          messages.value = List<Map<String, dynamic>>.from(data['messages']);
        } else {
          messages.clear();
        }
      } else {
        Get.snackbar('Error', resp.reasonPhrase ?? 'Failed to load messages');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add local message instantly (you can extend to POST to server)
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add({'text': text, 'isMe': true, 'time': _nowString()});
  }

  Future<void> refreshMessages() async {
    await fetchMessages();
  }

  String _nowString() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }
}
