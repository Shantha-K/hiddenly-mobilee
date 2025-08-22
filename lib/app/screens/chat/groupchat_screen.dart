import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inochat/app/controllers/contacts/groupchat_controller.dart';
import 'package:inochat/app/widgets/message_modal.dart';

class GroupChatScreen extends GetWidget<GroupchatController> {
  GroupChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.group, color: Colors.black54, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.groupName.value,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    controller.selectedContacts.isNotEmpty
                        ? controller.selectedContacts
                              .map((c) => c)
                              .take(3)
                              .join(', ')
                        : "No members",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return const Center(child: Text("No messages yet"));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(message: controller.messages[index]);
                },
              );
            }),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey[600]),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF00BCD4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (controller.messageController.text.isNotEmpty) {
                    controller.sendMessage().then((_) {
                      controller.fetchMessages();
                    });
                    controller.messageController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.mic, color: Colors.grey[600]),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (message.showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: message.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFFDCF8C6)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isMe
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: message.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}
