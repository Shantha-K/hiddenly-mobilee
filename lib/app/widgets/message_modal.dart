class ChatMessage {
  final String id;
  final String text;
  final String senderName;
  final String senderMobile;
  final String groupId;
  final DateTime timestamp;
  final bool isMe;
  final bool showTimestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderName,
    required this.senderMobile,
    required this.groupId,
    required this.timestamp,
    required this.isMe,
    this.showTimestamp = false,
    required String chatId,
    required String content,
    required String createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myMobile) {
    return ChatMessage(
      id: json["_id"] ?? "",
      text: json["content"] ?? "",
      senderName: json["sender"]?["name"] ?? "Unknown",
      senderMobile: json["sender"]?["mobile"] ?? "",
      groupId: json["groupId"] ?? "",
      timestamp: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      isMe: json["sender"]?["mobile"] == myMobile,
      chatId: '',
      content: '',
      createdAt: '',
    );
  }
}
