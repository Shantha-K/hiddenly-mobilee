import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/chat_controller.dart';
import 'chat_controller.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inochat"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.chats.isEmpty) {
          return const Center(child: Text("No chats available"));
        }

        return ListView.builder(
          itemCount: controller.chats.length,
          itemBuilder: (context, index) {
            var chat = controller.chats[index];
            var lastMessage = chat['lastMessage'] ?? {};
            var unreadCount = chat['unreadCount'] ?? 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(chat['name'][0].toUpperCase()),
              ),
              title: Text(chat['name']),
              subtitle: Text(
                lastMessage['content'] ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
