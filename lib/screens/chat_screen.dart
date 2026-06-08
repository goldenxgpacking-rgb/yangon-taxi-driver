import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = MessageService.getMessages(widget.conversation.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'driver',
          senderName: 'Driver',
          content: text,
          timestamp: DateTime.now(),
          isMe: true,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFFD700),
              radius: 16,
              child: Text(
                widget.conversation.passengerName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A1A2E),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.passengerName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.conversation.passengerPhone,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: msg.isMe
              ? const Color(0xFFFFD700)
              : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.poppins(
                color: msg.isMe ? const Color(0xFF1A1A2E) : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.timestamp),
              style: GoogleFonts.poppins(
                color: msg.isMe
                    ? const Color(0xFF1A1A2E).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF2A2A3E),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A2E),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Color(0xFF1A1A2E),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
