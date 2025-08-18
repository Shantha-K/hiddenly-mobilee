import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatDetailController extends GetxController {
  final CacheService _cacheService = CacheService();

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var chatId = ''.obs;
  var contact = ''.obs;
  String? myMobileNumber; 

  late IO.Socket socket;

  String get socketUrl => 'http://35.154.10.237:5000';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      contact.value = args['contact'] ?? '';
      chatId.value = args['chatId'] ?? '';
    } else {
      contact.value = 'unknown';
    }

    _loadMyNumberAndInit();
  }

  Future<void> _loadMyNumberAndInit() async {
    myMobileNumber = await _cacheService.getMyMobileNumber();
    _initSocket();
    fetchMessages();
  }

  void _initSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Socket connected: ${socket.id}');
      socket.emit('joinChat', {'chatId': chatId.value});
    });

    socket.on('newMessage', (data) {
      print('Received new message via socket: $data');

      Map<String, dynamic>? msg;
      if (data is Map<String, dynamic>) {
        msg = data;
      } else if (data is String) {
        try {
          msg = json.decode(data);
        } catch (_) {}
      }

      if (msg != null) {
        msg['isMe'] = (msg['senderMobile']?.toString() == myMobileNumber);
        messages.add(msg);
      }
    });

    socket.on('disconnect', (_) {
      print('Socket disconnected');
    });

    socket.on('connect_error', (err) {
      print('Socket connection error: $err');
    });
  }

  @override
  void onClose() {
    socket.disconnect();
    socket.dispose();
    super.onClose();
  }

  Future<void> fetchMessages() async {
    var headers = {'Content-Type': 'application/json'};
    try {
      isLoading.value = true;

      final resp = await http.post(
        Uri.parse('http://35.154.10.237:5000/api/chat/history'),
        headers: headers,
        body: json.encode({
          "chatId": chatId.value,
          "sender": myMobileNumber,
          "receiver": contact.value,
        }),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('Messages: $data');

        if (data['chathistory'] is List) {
          messages.value = List<Map<String, dynamic>>.from(
            data['chathistory'].map((msg) {
              msg['isMe'] = (msg['senderMobile']?.toString() == myMobileNumber);
              return msg;
            }),
          );
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

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final newMessage = {
      "chatId": chatId.value,
      "content": text,
      "senderMobile": myMobileNumber,
      "timestamp": DateTime.now().toIso8601String(),
      "isMe": true,
    };
    messages.add(newMessage);

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('http://35.154.10.237:5000/api/chat/instant-message'),
    );
    request.body = json.encode({
      "chatId": chatId.value,
      "content": text,
      "senderMobile": myMobileNumber,
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }

    socket.emit('sendMessage', newMessage);
  }
}
