import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../services/user_session.dart';

class RealTimeChatScreen extends StatefulWidget {
  final Map<String, dynamic>? tutor;
  const RealTimeChatScreen({super.key, this.tutor});

  @override
  State<RealTimeChatScreen> createState() => _RealTimeChatScreenState();
}

class _RealTimeChatScreenState extends State<RealTimeChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    // If testing on a physical device, replace 'localhost' with your computer's IP address
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      if (mounted) setState(() => _isConnected = true);
      // Join the unique room for this booking
      socket.emit('join_chat', widget.tutor?['bookingId']);
    });

    socket.onDisconnect((_) {
      if (mounted) setState(() => _isConnected = false);
    });

    // Listen for incoming messages
    socket.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            'text': data['text'],
            'senderId': data['senderId'],
            'isMe': data['senderId'] == UserSession.currentUser?['_id'],
            'time': DateTime.now(),
          });
        });
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || !_isConnected) return;

    final messageData = {
      'bookingId': widget.tutor?['bookingId'],
      'senderId': UserSession.currentUser?['_id'],
      'text': text,
    };

    socket.emit('send_message', messageData);
    _messageController.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutor?['name'] ?? "Chat", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.circle, 
              color: _isConnected ? Colors.greenAccent : Colors.redAccent, 
              size: 12
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Shows newest messages at the bottom
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  message: msg['text'],
                  isMe: msg['isMe'],
                  time: msg['time'],
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25), 
                  borderSide: BorderSide.none
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20), 
              onPressed: _sendMessage
            ),
          ),
        ],
      ),
    );
  }
}

// --- MISSING CLASS DEFINITION BELOW ---
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const _ChatBubble({
    required this.message, 
    required this.isMe, 
    required this.time
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isMe ? 15 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.poppins(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 10, 
                color: isMe ? Colors.white70 : Colors.black54
              ),
            ),
          ],
        ),
      ),
    );
  }
}