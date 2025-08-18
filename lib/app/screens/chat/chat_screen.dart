// lib/app/ui/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  ChatScreen({super.key});

  Future<void> _refreshChats() async {
    await controller.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.chats.isEmpty) {
          return const Center(child: Text("No chats available"));
        }

        return RefreshIndicator(
          onRefresh: _refreshChats,
          child: ListView.builder(
            itemCount: controller.chats.length,
            itemBuilder: (context, index) {
              final user = controller.chats[index];
              final lastMessage = user["lastMessage"] ?? {};
              final name = user["name"] ?? user["mobile"] ?? "";
              final content = lastMessage["content"] ?? "";
              final time = lastMessage["createdAt"] ?? "";

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.black54),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  time.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () {
                  Get.toNamed(
                    '/chat_detail',
                    arguments: {
                      'chatId': lastMessage['chatId'] ?? '',
                      'contact': user['mobile'] ?? '',
                      'name': name,
                    },
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
