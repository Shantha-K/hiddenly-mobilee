// lib/app/controllers/chat_detail_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:inochat/app/core/cache_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatDetailController extends GetxController {
  final CacheService _cacheService = CacheService();

  // UI state
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final chatId = ''.obs;
  final contact = ''.obs; // receiver mobile
  final username = ''.obs;

  String? myMobileNumber;

  late IO.Socket socket;

  // --- API / Socket URLs ---
  String get baseUrl => 'http://35.154.10.237:5000';
  String get socketUrl => baseUrl;

  // Track message ids to avoid duplicates
  final Set<String> _seenIds = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      contact.value = (args['contact'] ?? '').toString();
      chatId.value = (args['chatId'] ?? '').toString();
      username.value = (args['name'] ?? '').toString();
    } else {
      contact.value = 'unknown';
    }
    _loadMyNumberAndInit();
  }

  Future<void> _loadMyNumberAndInit() async {
    myMobileNumber = await _cacheService.getMyMobileNumber();
    _initSocket();
    await fetchMessages();
  }

  void _initSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
      'timeout': 20000,
      'query': {'callerId': myMobileNumber},
    });

    // --- Listeners ---
    socket.onConnect((_) {
      print("✅ Connected to socket");
      socket.emit('joinRoom', chatId.value);
    });

    socket.on('disconnect', (_) {
      print("❌ Disconnected from socket");
    });

    socket.on('connect_error', (err) {
      print("⚠️ Socket connection error: $err");
    });

    socket.on('chatMessage', (data) {
      final msg = _asMap(data);
      if (msg == null) return;

      // Determine unique ID
      final id = (msg['id'] ?? msg['_id'] ?? _deriveId(msg)).toString();
      if (_seenIds.contains(id)) return;
      _seenIds.add(id);

      msg['isMe'] = (msg['senderMobile']?.toString() == myMobileNumber);
      _insertOrUpdate(msg);
    });

    socket.connect();
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  String _deriveId(Map<String, dynamic> m) {
    final s = m['senderMobile'] ?? '';
    final t = m['timestamp'] ?? DateTime.now().toIso8601String();
    final c = m['content'] ?? '';
    return '$s|$t|$c';
  }

  // Inserts or updates messages to avoid duplicates
  void _insertOrUpdate(Map<String, dynamic> msg) {
    final id = (msg['id'] ?? msg['_id'] ?? msg['localId'] ?? _deriveId(msg))
        .toString();
    if (_seenIds.contains(id)) return;
    _seenIds.add(id);

    final idx = messages.indexWhere((m) {
      final mid = (m['id'] ?? m['_id'] ?? m['localId'] ?? _deriveId(m))
          .toString();
      return mid == id;
    });

    if (idx == -1) {
      messages.add(msg);
    } else {
      messages[idx] = {...messages[idx], ...msg};
      messages.refresh();
    }
  }

  @override
  void onClose() {
    socket.off('chatMessage');
    socket.off('connect');
    socket.off('disconnect');
    socket.off('connect_error');
    socket.disconnect();
    socket.dispose();
    super.onClose();
  }

  // --- Fetch chat history ---
  Future<void> fetchMessages() async {
    isLoading.value = true;
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/api/chat/history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'chatId': chatId.value,
          'sender': myMobileNumber,
          'receiver': contact.value,
        }),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = (data['chathistory'] as List? ?? [])
            .cast<Map>()
            .map<Map<String, dynamic>>((e) {
              final m = Map<String, dynamic>.from(e);
              m['isMe'] = (m['senderMobile']?.toString() == myMobileNumber);
              final id = (m['id'] ?? m['_id'] ?? _deriveId(m)).toString();
              _seenIds.add(id);
              return m;
            })
            .toList();
        messages.assignAll(list);
      } else {
        Get.snackbar('Error', resp.reasonPhrase ?? 'Failed to load messages');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // --- Send message with ACK + fallback ---
  void sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final localId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = {
      'localId': localId,
      'chatId': chatId.value,
      'content': content,
      'senderMobile': myMobileNumber,
      'receiverMobile': contact.value,
      'timestamp': DateTime.now().toIso8601String(),
      'isMe': true,
      'status': 'sending',
    };

    // Insert optimistic message
    messages.add(optimistic);
    _seenIds.add(localId);

    bool acked = false;
    Timer? fallbackTimer;

    try {
      socket.emitWithAck(
        'sendMessage',
        {
          'chatId': chatId.value,
          'content': content,
          'senderMobile': myMobileNumber,
          'receiverMobile': contact.value,
        },
        ack: (resp) {
          acked = true;
          final msg = _asMap(resp) ?? {};
          msg['localId'] = localId;
          msg['isMe'] = true;
          msg['status'] = 'sent';

          final idx = messages.indexWhere((m) => m['localId'] == localId);
          if (idx != -1)
            messages[idx] = msg;
          else
            _insertOrUpdate(msg);

          _seenIds.add(localId);
        },
      );

      fallbackTimer = Timer(const Duration(seconds: 3), () async {
        if (acked) return;
        try {
          final r = await http.post(
            Uri.parse('$baseUrl/api/chat/instant-message'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'chatId': chatId.value,
              'content': content,
              'senderMobile': myMobileNumber,
              'receiverMobile': contact.value,
            }),
          );

          if (r.statusCode == 200) {
            final body = json.decode(r.body);
            final serverMsg = (body is Map<String, dynamic>)
                ? body
                : {'server': 'ok'};
            serverMsg['localId'] = localId;
            serverMsg['isMe'] = true;
            serverMsg['status'] = 'sent';

            final idx = messages.indexWhere((m) => m['localId'] == localId);
            if (idx != -1)
              messages[idx] = serverMsg;
            else
              _insertOrUpdate(serverMsg);

            _seenIds.add(localId);
          } else {
            final idx = messages.indexWhere((m) => m['localId'] == localId);
            if (idx != -1) messages[idx]['status'] = 'failed';
            Get.snackbar('Send failed', r.reasonPhrase ?? 'Unknown error');
          }
        } catch (_) {
          final idx = messages.indexWhere((m) => m['localId'] == localId);
          if (idx != -1) messages[idx]['status'] = 'failed';
          Get.snackbar('Send failed', 'Network error');
        }
      });
    } catch (_) {
      final idx = messages.indexWhere((m) => m['localId'] == localId);
      if (idx != -1) messages[idx]['status'] = 'failed';
    } finally {
      Future.delayed(const Duration(seconds: 5), () {
        fallbackTimer?.cancel();
      });
    }
  }
}
