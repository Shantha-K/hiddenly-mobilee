import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:inochat/app/widgets/message_modal.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupchatController extends GetxController {
  final CacheService _cacheService = CacheService();
  final TextEditingController messageController = TextEditingController();

  // Chat messages list
  var messages = <ChatMessage>[].obs;

  // UI state flags
  var isSending = false.obs;
  var isLoading = false.obs;

  // Group info
  var groupId = ''.obs;
  var groupName = ''.obs;
  var selectedContacts = <dynamic>[].obs;

  // User info
  String? myMobileNumber;

  // Socket.IO
  late IO.Socket socket;
  final String socketUrl = 'http://35.154.10.237:5000';

  // REST endpoints
  final String sendMessageUrl =
      "http://35.154.10.237:5000/api/group/sendMessage";
  final String getMessagesUrl =
      "http://35.154.10.237:5000/api/group/getGroupmessages";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    groupId.value = args['groupId'] ?? '';
    groupName.value = args['groupName'] ?? '';
    selectedContacts.value = args['selectedContacts'] ?? [];
    _initialize();
  }

  /// Load user info, fetch messages, and initialize socket
  Future<void> _initialize() async {
    myMobileNumber = await _cacheService.getMyMobileNumber();
    await fetchMessages();
    _initSocket();
  }

  /// Initialize Socket.IO connection
  void _initSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'callerId': myMobileNumber}, // backend expects callerId
    });

    socket.connect();

    // Connected
    socket.onConnect((_) {
      print('✅ Group socket connected: ${socket.id}');
      socket.emit('joinGroupRoom', groupId.value);
    });

    // Listen for group messages
    socket.off('groupMessage'); // prevent duplicate listeners
    socket.on('groupMessage', _handleIncomingMessage);

    socket.onDisconnect((_) => print('⚠️ Group socket disconnected'));
    socket.onConnectError((err) => print('❌ Group socket error: $err'));
  }

  /// Handle incoming group messages from socket
  void _handleIncomingMessage(dynamic data) {
    Map<String, dynamic>? raw;

    if (data is Map) {
      raw = Map<String, dynamic>.from(data);
    } else if (data is String) {
      try {
        raw = json.decode(data);
      } catch (_) {}
    }

    if (raw == null) return;

    final createdAtStr = raw['createdAt']?.toString() ?? '';
    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();

    final incoming = ChatMessage(
      id: raw['_id']?.toString() ?? '',
      text: raw['content']?.toString() ?? '',
      senderName: 'Unknown',
      senderMobile: raw['senderMobile']?.toString() ?? '',
      groupId: raw['groupId']?.toString() ?? groupId.value,
      timestamp: createdAt,
      isMe: (raw['senderMobile']?.toString() ?? '') == (myMobileNumber ?? ''),
      chatId: raw['groupId']?.toString() ?? groupId.value,
      content: raw['content']?.toString() ?? '',
      createdAt: createdAt.toIso8601String(),
    );

    // Prevent duplicate messages
    final exists = messages.any(
      (m) =>
          m.text == incoming.text &&
          m.senderMobile == incoming.senderMobile &&
          m.timestamp.isAtSameMomentAs(incoming.timestamp),
    );

    if (!exists) messages.add(incoming);
  }

  /// Fetch messages from REST API
  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final headers = {'Content-Type': 'application/json'};

      final request = http.Request('POST', Uri.parse(getMessagesUrl))
        ..headers.addAll(headers)
        ..body = json.encode({
          "groupId": groupId.value,
          "sender": myMobileNumber,
        });

      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);
        print("📜 Fetched group messages: $data");

        if (data["messages"] is List) {
          messages.value = List<ChatMessage>.from(
            (data["messages"] as List).map(
              (msg) => ChatMessage.fromJson(
                Map<String, dynamic>.from(msg),
                myMobileNumber ?? "",
              ),
            ),
          );
        }
      } else {
        print("❌ Error fetching messages: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("❌ Exception while fetching messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Send message with optimistic UI and socket emit
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Optimistic UI
    final now = DateTime.now();
    final optimistic = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      text: text,
      senderName: "Me",
      senderMobile: myMobileNumber ?? "",
      groupId: groupId.value,
      timestamp: now,
      isMe: true,
      chatId: groupId.value,
      content: text,
      createdAt: now.toIso8601String(),
    );
    messages.add(optimistic);

    isSending.value = true;
    try {
      final headers = {'Content-Type': 'application/json'};
      final payload = {
        "groupId": groupId.value,
        "sender": myMobileNumber,
        "content": text,
        "messageType": "text",
      };

      final request = http.Request('POST', Uri.parse(sendMessageUrl))
        ..headers.addAll(headers)
        ..body = json.encode(payload);

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = await response.stream.bytesToString();
        final data = json.decode(body);
        print("✅ Message saved: ${data['data']}");

        // Emit live event to socket
        socket.emit('sendGroupMessage', {
          "groupId": groupId.value,
          "senderMobile": myMobileNumber,
          "content": text,
        });

        messageController.clear();
      } else {
        print("❌ Error sending message: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("❌ Exception while sending message: $e");
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    try {
      socket.dispose();
    } catch (_) {}
    super.onClose();
  }
}
