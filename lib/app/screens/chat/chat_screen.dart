import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  ChatScreen({super.key});

  Future<void> _refreshContacts() async {
    await controller.chats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshContacts,
        child: Column(
          children: [
            ...controller.chats.map((user) {
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person),
                ),
                title: Text(
                  user['_id'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  user['lastMessage']['content'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  user['lastMessage']['createdAt'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Get.toNamed(
                    '/chat_detail',
                    arguments: {
                      'chatId': user['chatId'] ?? '',
                      'contact': user['receiverMobile'] ?? '',
                    },
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
