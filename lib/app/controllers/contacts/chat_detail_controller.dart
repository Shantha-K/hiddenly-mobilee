// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:inochat/app/core/cache_service.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChatDetailController extends GetxController {
//   final CacheService _cacheService = CacheService();

//   var messages = <Map<String, dynamic>>[].obs;
//   var isLoading = false.obs;
//   var chatId = ''.obs;
//   var contact = ''.obs;
//   var username = ''.obs;
//   String? myMobileNumber;

//   late IO.Socket socket;
//   String get socketUrl => 'http://35.154.10.237:5000';

//   @override
//   void onInit() {
//     super.onInit();
//     final args = Get.arguments;

//     if (args is Map<String, dynamic>) {
//       contact.value = args['contact'] ?? '';
//       chatId.value = args['chatId'] ?? '';
//       username.value = args['name'] ?? '';
//     } else {
//       contact.value = 'unknown';
//     }

//     _loadMyNumberAndInit();
//   }

//   Future<void> _loadMyNumberAndInit() async {
//     myMobileNumber = await _cacheService.getMyMobileNumber();
//     await fetchMessages();
//     _initSocket();
//   }

//   void _initSocket() {
//     socket = IO.io(socketUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//       'query': {'mobile': myMobileNumber},
//     });

//     socket.onConnect((_) {
//       print('Socket connected: ${socket.id}');
//       socket.emit('joinRoom', {'chatId': chatId.value});
//     });

//     socket.on('newMessage', (data) {
//       final msg = _normalizeMessage(data);
//       if (msg != null) {
//         // Avoid adding duplicate messages
//         if (!messages.any((m) => m['timestamp'] == msg['timestamp'])) {
//           messages.add(msg);
//         }
//       }
//     });

//     socket.onDisconnect((_) => print('Socket disconnected'));
//     socket.onConnectError((err) => print('Socket connection error: $err'));
//   }

//   Map<String, dynamic>? _normalizeMessage(dynamic data) {
//     Map<String, dynamic>? msg;
//     if (data is Map) {
//       msg = Map<String, dynamic>.from(data);
//     } else if (data is String) {
//       try {
//         msg = json.decode(data);
//       } catch (_) {}
//     }

//     if (msg != null) {
//       msg['isMe'] = (msg['senderMobile']?.toString() == myMobileNumber);
//     }

//     return msg;
//   }

//   Future<void> fetchMessages() async {
//     try {
//       isLoading.value = true;

//       final resp = await http.post(
//         Uri.parse('http://35.154.10.237:5000/api/chat/history'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           "chatId": chatId.value,
//           "sender": myMobileNumber,
//           "receiver": contact.value,
//         }),
//       );

//       if (resp.statusCode == 200) {
//         final data = json.decode(resp.body);
//         if (data['chathistory'] is List) {
//           messages.value = List<Map<String, dynamic>>.from(
//             data['chathistory'].map((msg) {
//               msg['isMe'] = (msg['senderMobile']?.toString() == myMobileNumber);
//               return msg;
//             }),
//           );
//         } else {
//           messages.clear();
//         }
//       } else {
//         Get.snackbar('Error', resp.reasonPhrase ?? 'Failed to load messages');
//       }
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void sendMessage(String text) async {
//     if (text.trim().isEmpty) return;

//     final timestamp = DateTime.now().toIso8601String();
//     final newMessage = {
//       "chatId": chatId.value,
//       "content": text,
//       "senderMobile": myMobileNumber,
//       "timestamp": timestamp,
//       "isMe": true,
//     };

//     messages.add(newMessage); // Optimistic UI update

//     final request =
//         http.Request(
//             'POST',
//             Uri.parse('http://35.154.10.237:5000/api/chat/instant-message'),
//           )
//           ..headers.addAll({'Content-Type': 'application/json'})
//           ..body = json.encode({
//             "chatId": chatId.value,
//             "content": text,
//             "senderMobile": myMobileNumber,
//           });

//     final response = await request.send();
//     if (response.statusCode == 201) {
//       print(await response.stream.bytesToString());
//       socket.emit('sendMessage', newMessage);
//     } else {
//       print('Send message failed: ${response.reasonPhrase}');
//     }
//   }

//   @override
//   void onClose() {
//     socket.dispose();
//     super.onClose();
//   }
// }

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
  var username = ''.obs;
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
      username.value = args['name'] ?? '';
    } else {
      contact.value = 'unknown';
    }

    _loadMyNumberAndInit();
  }

  Future<void> _loadMyNumberAndInit() async {
    myMobileNumber = await _cacheService.getMyMobileNumber();
    await fetchMessages();
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {
        'callerId': myMobileNumber, // ✅ backend expects callerId
      },
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected: ${socket.id}');
      socket.emit('joinRoom', chatId.value); // ✅ backend expects string
    });

    // 🔥 Prevent duplicate listeners
    socket.off('chatMessage');
    socket.on('chatMessage', (data) {
      print('📩 Chat message received: $data');

      Map<String, dynamic>? msg;
      if (data is Map) {
        msg = Map<String, dynamic>.from(data);
      } else if (data is String) {
        try {
          msg = json.decode(data);
        } catch (_) {}
      }

      if (msg != null) {
        msg['isMe'] = msg['senderMobile'] == myMobileNumber;
        messages.add(msg);
      }
    });

    socket.onDisconnect((_) => print('⚠️ Socket disconnected'));
    socket.onConnectError((err) => print('❌ Socket connection error: $err'));
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;

      final resp = await http.post(
        Uri.parse('$socketUrl/api/chat/history'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "chatId": chatId.value,
          "sender": myMobileNumber,
          "receiver": contact.value,
        }),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('📜 Fetched messages: ${data['chathistory']}');

        if (data['chathistory'] is List) {
          messages.value = List<Map<String, dynamic>>.from(
            data['chathistory'].map((m) {
              m['isMe'] = m['senderMobile'] == myMobileNumber;
              return m;
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

    final newMessagePayload = {
      "chatId": chatId.value,
      "content": text,
      "senderMobile": myMobileNumber,
    };

    // ✅ Optimistic UI update
    messages.add({...newMessagePayload, "isMe": true, "localTemp": true});

    try {
      final request =
          http.Request('POST', Uri.parse('$socketUrl/api/chat/instant-message'))
            ..headers.addAll({'Content-Type': 'application/json'})
            ..body = json.encode(newMessagePayload);

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final respJson = json.decode(respStr);

        print('✅ Message saved: ${respJson['data']}');

        // Replace localTemp with actual server response
        messages.removeWhere((m) => m['localTemp'] == true);
        final savedMsg = Map<String, dynamic>.from(respJson['data']);
        savedMsg['isMe'] = true;
        // messages.add(savedMsg);

        // ✅ Emit only once
        socket.emit('sendMessage', newMessagePayload);
      } else {
        print('❌ Send message failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Exception while sending: $e');
    }
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
