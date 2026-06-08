import '../models/message.dart';

class MessageService {
  // Mock conversations
  static List<Conversation> getConversations() {
    return [
      Conversation(
        id: 'conv_001',
        passengerName: 'Aung Aung',
        passengerPhone: '+95 9123456789',
        lastMessage: 'I am waiting at the pickup point.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        orderId: 'ORD001',
      ),
      Conversation(
        id: 'conv_002',
        passengerName: 'Min Min',
        passengerPhone: '+95 9876543210',
        lastMessage: 'Can you arrive faster?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 0,
        orderId: 'ORD002',
      ),
      Conversation(
        id: 'conv_003',
        passengerName: 'Su Su',
        passengerPhone: '+95 9988776655',
        lastMessage: 'Thank you for the ride!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        orderId: 'ORD003',
      ),
    ];
  }

  // Mock chat messages for a conversation
  static List<ChatMessage> getMessages(String conversationId) {
    return [
      ChatMessage(
        id: 'msg_001',
        senderId: 'passenger',
        senderName: 'Aung Aung',
        content: 'Hello, are you nearby?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isMe: false,
      ),
      ChatMessage(
        id: 'msg_002',
        senderId: 'driver',
        senderName: 'Driver',
        content: 'Yes, I am about 5 minutes away.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        isMe: true,
      ),
      ChatMessage(
        id: 'msg_003',
        senderId: 'passenger',
        senderName: 'Aung Aung',
        content: 'Okay, I am waiting at the pickup point.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    ];
  }
}
