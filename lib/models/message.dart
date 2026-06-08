class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });
}

class Conversation {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String orderId;

  Conversation({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.orderId,
  });
}
