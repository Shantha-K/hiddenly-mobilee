import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/contacts/chat_detail_controller.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatDetailController controller = Get.put(ChatDetailController());
  final TextEditingController textController = TextEditingController();

  ChatDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF6FF),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[700]),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          return Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 10),
              Text(
                controller.username.value ?? 'Unknown',
                style: TextStyle(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'IC',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.more_vert, color: Colors.blue[900]),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isMe = msg['isMe'] == true;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF1976D2)
                              : const Color(0xFFFFF9E5),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isMe ? 14 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['content'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  msg['time'] ?? '',
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                                if (isMe) const SizedBox(width: 4),
                                if (isMe)
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
                left: 12,
                right: 12,
                top: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onSubmitted: (v) {
                          controller.sendMessage(v);
                          textController.clear();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      controller.sendMessage(textController.text);
                      textController.clear();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      radius: 22,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
